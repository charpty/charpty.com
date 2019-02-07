package com.charpty.server;

import java.beans.BeanInfo;
import java.beans.IntrospectionException;
import java.beans.Introspector;
import java.beans.PropertyDescriptor;
import java.lang.reflect.Method;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.ReentrantLock;

/**
 * @author charpty
 * @since 2017/12/24
 */
public class BootDataSource {

    private static final long MAX_IDLE = 3 * 3600 * 1000;
    private static final long MAX_LIVE = 7 * 3600 * 1000;
    private static final long MAX_ALIVE = 15;

    private final String jdbcUrl;

    private static final Map<String, Map<Integer, WritableProperty>> WRITABLE_CACHE = new ConcurrentHashMap<>();
    private final ThreadLocal<ConnectionHolder> cache = ThreadLocal.withInitial(() -> null);
    private final ReentrantLock mainLock = new ReentrantLock();
    private final Condition notEmpty = mainLock.newCondition();
    private final LinkedList<ConnectionHolder> ideaConnections;
    private final LinkedList<ConnectionHolder> usedConnections;
    private int total;

    public BootDataSource(String url) {
        Connection conn = null;
        try {
            Class.forName("com.mysql.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("加载MySQL驱动失败", e);
        }
        try {
            conn = DriverManager.getConnection(url);
        } catch (SQLException e) {
            throw new RuntimeException("与MySQL数据库建立连接失败", e);
        }
        jdbcUrl = url;
        ideaConnections = new LinkedList();
        usedConnections = new LinkedList();

        ideaConnections.add(new ConnectionHolder(this, conn));
    }

    public PreparedStatementWrapper preparedStatement(String sql) {
        ConnectionHolder holder = getConnection();
        PreparedStatement statement = holder.statements.get(sql);
        if (statement == null) {
            try {
                statement = holder.connection.prepareStatement(sql);
            } catch (SQLException e) {
                throw new RuntimeException(e);
            }
            holder.statements.put(sql, statement);
        }
        return new PreparedStatementWrapper(sql, statement, holder);
    }

    public ConnectionHolder getConnection() {
        ConnectionHolder holder = cache.get();
        if (holder != null && !holder.inUse && testConnection(holder)) {
            mainLock.lock();
            try {
                if (holder.thread == null || holder.thread == Thread.currentThread()) {
                    holder.thread = Thread.currentThread();
                    return holder;
                }
            } finally {
                mainLock.unlock();
            }
        }
        try {
            holder = getConnection0();
        } catch (InterruptedException e) {
            throw new RuntimeException(e);
        }
        holder.thread = Thread.currentThread();
        holder.last = System.currentTimeMillis();
        cache.set(holder);
        return holder;
    }

    private ConnectionHolder getConnection0() throws InterruptedException {
        ConnectionHolder result;
        mainLock.lock();
        while (true) {
            if (ideaConnections.size() == 0) {
                if (total < MAX_ALIVE) {
                    result = createConnection();
                    total++;
                    usedConnections.add(result);
                    return result;
                } else {
                    notEmpty.await();
                }
            } else {
                return getIdleConnection();
            }
        }
    }

    private ConnectionHolder getIdleConnection() {
        ConnectionHolder result = ideaConnections.pop();
        usedConnections.add(result);
        return result;
    }

    private ConnectionHolder createConnection() {
        Connection conn = null;
        try {
            conn = DriverManager.getConnection(jdbcUrl);
        } catch (SQLException e) {
            throw new RuntimeException("与MySQL数据库建立连接失败", e);
        }
        ConnectionHolder result = new ConnectionHolder(this, conn);
        return result;
    }

    private boolean testConnection(ConnectionHolder holder) {
        long current = System.currentTimeMillis();
        long live = current - holder.create;
        long idea = current - holder.last;
        if (idea < MAX_IDLE && live < MAX_LIVE) {
            return true;
        }
        return false;
    }

    void close(ConnectionHolder holder) {
        usedConnections.remove(holder);
        ideaConnections.add(holder);
        notEmpty.signal();
    }

    void discard(ConnectionHolder holder) {
        usedConnections.remove(holder);
        try {
            holder.connection.close();
        } catch (SQLException ignore) {
        }
        mainLock.lock();
        total--;
        mainLock.unlock();
    }

    static class ConnectionHolder {
        private final String id;
        private final Connection connection;
        private final BootDataSource dataSource;
        private volatile boolean inUse = false;
        // 上一个使用该连接的线程
        private Thread thread;
        private long last = System.currentTimeMillis();
        private long create = System.currentTimeMillis();
        Map<String, PreparedStatement> statements = new HashMap<>();

        public ConnectionHolder(BootDataSource dataSource, Connection connection) {
            this.dataSource = dataSource;
            this.connection = connection;
            this.id = UUID.randomUUID().toString();
        }

        public void close() {
            dataSource.close(this);
        }

        public void discard() {
            dataSource.discard(this);
        }
    }

    public static class PreparedStatementWrapper {
        private final String sql;
        private final PreparedStatement statement;
        private final BootDataSource.ConnectionHolder connectionHolder;

        public PreparedStatementWrapper(String sql, PreparedStatement statement,
                BootDataSource.ConnectionHolder holder) {
            this.sql = sql;
            this.statement = statement;
            this.connectionHolder = holder;
        }

        public void close() {
            connectionHolder.close();
        }

        public void setString(int index, String value) {
            try {
                statement.setString(index, value);
            } catch (SQLException e) {
                throw new RuntimeException(e);
            }
        }

        public void setInt(int index, int value) {
            try {
                statement.setInt(index, value);
            } catch (SQLException e) {
                throw new RuntimeException(e);
            }
        }

        public ResultSetWrapper executeQuery() {
            LogUtil.debug(this, "Execute SQL: %s", sql);
            try {
                return new ResultSetWrapper(sql, statement.executeQuery(), this);
            } catch (SQLException e) {
                connectionHolder.discard();
                throw new RuntimeException(e);
            }
        }
    }

    public static class ResultSetWrapper {
        private final String sql;
        private final ResultSet rs;
        private final PreparedStatementWrapper statement;

        public ResultSetWrapper(String sql, ResultSet resultSet, PreparedStatementWrapper statement) {
            this.sql = sql;
            this.rs = resultSet;
            this.statement = statement;
        }

        public int toInt() {
            try {
                rs.next();
                int i = rs.getInt(1);
                rs.close();
                statement.close();
                return i;
            } catch (SQLException e) {
                throw new RuntimeException(e);
            }
        }

        public <T> T toBean(Class<T> type) {
            try {
                Map<Integer, WritableProperty> wps = getWritableProperty(sql, type, rs.getMetaData());
                T bean = type.newInstance();
                rs.next();
                fillObject(wps, bean, rs);
                rs.close();
                statement.close();
                return bean;
            } catch (SQLException e) {
                throw new RuntimeException(e);
            } catch (IllegalAccessException e) {
                throw new RuntimeException(e);
            } catch (InstantiationException e) {
                throw new RuntimeException(e);
            }
        }

        public <T> List<T> toList(Class<T> itemType) {
            List<T> result = new ArrayList<>();
            try {
                Map<Integer, WritableProperty> wps = getWritableProperty(sql, itemType, rs.getMetaData());
                while (rs.next()) {
                    T bean = itemType.newInstance();
                    fillObject(wps, bean, rs);
                    result.add(bean);
                }
                rs.close();
                statement.close();
                return result;
            } catch (SQLException e) {
                throw new RuntimeException(e);
            } catch (IllegalAccessException e) {
                throw new RuntimeException(e);
            } catch (InstantiationException e) {
                throw new RuntimeException(e);
            }
        }

        public ResultSet getResultSet() {
            return rs;
        }
    }

    static <T> T fillObject(Map<Integer, WritableProperty> wps, T bean, ResultSet rs) {
        WritableProperty wp;
        for (Map.Entry<Integer, WritableProperty> entry : wps.entrySet()) {
            wp = entry.getValue();
            Object value;
            try {
                value = rs.getObject(entry.getKey());
            } catch (SQLException e) {
                throw new RuntimeException(e);
            }
            if (null == value && wp.isPrimitive()) {
                continue;
            }
            Class<?> propType = wp.getPropType();
            if (!propType.isInstance(value)) {
                if (value instanceof Long && propType.isPrimitive() && propType.getName() == "int") {
                    value = Integer.valueOf(String.valueOf(value));
                }
            }
            try {
                wp.getSetter().invoke(bean, value);
            } catch (Exception e) {
                throw new RuntimeException(e);
            }
        }
        return bean;
    }

    static Map<Integer, WritableProperty> getWritableProperty(String sql, Class<?> type, ResultSetMetaData meta) {
        Map<Integer, WritableProperty> result = new HashMap<>();
        Map<String, WritableProperty> wps = new HashMap<>();

        BeanInfo beanInfo;
        try {
            beanInfo = Introspector.getBeanInfo(type);
        } catch (IntrospectionException e) {
            throw new RuntimeException(e);
        }
        PropertyDescriptor[] pds = beanInfo.getPropertyDescriptors();
        for (PropertyDescriptor pd : pds) {
            Method setter = pd.getWriteMethod();
            if (null != setter) {
                String name = pd.getName();
                Class<?> propType = pd.getPropertyType();
                WritableProperty wp = new WritableProperty(name, setter, propType);
                wps.put(name.toLowerCase(), wp);
            }
        }

        int columnCount = 0;
        try {
            columnCount = meta.getColumnCount();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        for (int i = 1; i <= columnCount; i++) {
            String column;
            try {
                column = meta.getColumnLabel(i);
            } catch (SQLException e) {
                throw new RuntimeException(e);
            }
            if (column == null) {
                continue;
            }
            String key = column.toLowerCase();
            WritableProperty wp = wps.get(key);
            if (wp != null) {
                result.put(i, wp);
            } else {
                char[] keyArr = key.toCharArray();
                char[] x = new char[keyArr.length];
                int c = 0;
                boolean noise = false;
                for (int j = 0; j < keyArr.length; j++) {
                    if (keyArr[j] == '_') {
                        noise = true;
                        continue;
                    }
                    x[c++] = keyArr[j];
                }
                if (noise) {
                    key = new String(x, 0, c);
                    wp = wps.get(key);
                    if (wp != null) {
                        result.put(i, wp);
                    }
                }

            }
        }
        return result;
    }

    static class WritableProperty {
        private final String name;
        private final Method setter;
        private final Class<?> propType;
        private final boolean primitive;

        public WritableProperty(String name, Method setter, Class<?> propType) {
            this.name = name;
            this.setter = setter;
            this.propType = propType;
            this.primitive = propType.isPrimitive();
        }

        public String getName() {
            return name;
        }

        public Method getSetter() {
            return setter;
        }

        public Class<?> getPropType() {
            return propType;
        }

        public boolean isPrimitive() {
            return primitive;
        }
    }
}
