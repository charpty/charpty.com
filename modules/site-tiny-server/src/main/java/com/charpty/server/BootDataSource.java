package com.charpty.server;

import java.beans.BeanInfo;
import java.beans.IntrospectionException;
import java.beans.Introspector;
import java.beans.PropertyDescriptor;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
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

    private static final Map<Class<?>, Map<Integer, WritableProperty>> WRITABLE_CACHE = new ConcurrentHashMap<>();
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
                e.printStackTrace();
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
            e.printStackTrace();
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
                e.printStackTrace();
            }
        }

        public void setInt(int index, int value) {
            try {
                statement.setInt(index, value);
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }

        public ResultSetWrapper executeQuery() {
            try {
                return new ResultSetWrapper(sql, statement.executeQuery());
            } catch (SQLException e) {
                throw new RuntimeException(e);
            }
        }
    }

    public static class ResultSetWrapper {
        private final String sql;
        private final ResultSet resultSet;

        public ResultSetWrapper(String sql, ResultSet resultSet) {
            this.sql = sql;
            this.resultSet = resultSet;
        }

        public int toInt() {
            try {
                resultSet.next();
                return resultSet.getInt(1);
            } catch (SQLException e) {
                throw new RuntimeException(e);
            }
        }

        public <T> T toBean(Class<T> type) {
            try {
                Map<Integer, WritableProperty> wps = getWritableProperty(sql, type, resultSet.getMetaData());

            } catch (SQLException e) {
                e.printStackTrace();
            }
            return null;
        }

        public <T> List<T> toList(Class itemType) {
            return null;
        }

        public ResultSet getResultSet() {
            return resultSet;
        }
    }

    public static <T> T toBean(Map<Integer, WritableProperty> wps, T bean, ResultSet rs) {
        WritableProperty wp;
        for (Map.Entry<Integer, WritableProperty> entry : wps.entrySet()) {
            wp = entry.getValue();
            Object value = null;
            try {
                value = rs.getObject(entry.getKey());
            } catch (SQLException e) {
                e.printStackTrace();
            }
            if (null == value && wp.isPrimitive()) {
                continue;
            }
            try {
                wp.getSetter().invoke(bean, value);
            } catch (IllegalAccessException e) {
                e.printStackTrace();
            } catch (InvocationTargetException e) {
                e.printStackTrace();
            }
        }
        return bean;
    }

    public static Map<Integer, WritableProperty> getWritableProperty(String sql, Class<?> type,
            ResultSetMetaData meta) {
        Map<Integer, WritableProperty> result = new HashMap<>();
        Map<String, WritableProperty> wps = new HashMap<>();

        BeanInfo beanInfo = null;
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
                WritableProperty wp = new WritableProperty(name, setter, propType.isPrimitive());
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
            String column = null;
            try {
                column = meta.getColumnLabel(i);
            } catch (SQLException e) {
                throw new RuntimeException(e);
            }
            if (null != column) {
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
                        key = new String(keyArr, 0, c);
                        wp = wps.get(key);
                        if (wp != null) {
                            result.put(i, wp);
                        }
                    }

                }
            }
        }
        return result;
    }

    static class WritableProperty {
        private final String name;
        private final Method setter;
        private final boolean primitive;

        public WritableProperty(String name, Method setter, boolean primitive) {
            this.name = name;
            this.setter = setter;
            this.primitive = primitive;
        }

        public String getName() {
            return name;
        }

        public Method getSetter() {
            return setter;
        }

        public boolean isPrimitive() {
            return primitive;
        }
    }
}
