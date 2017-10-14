package com.charpty.config;

import java.sql.SQLException;
import java.util.Properties;
import javax.sql.DataSource;
import org.apache.ibatis.mapping.VendorDatabaseIdProvider;
import org.apache.ibatis.session.ExecutorType;
import org.apache.ibatis.session.SqlSessionFactory;
import org.mybatis.spring.SqlSessionFactoryBean;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.support.PathMatchingResourcePatternResolver;
import org.springframework.jdbc.datasource.DriverManagerDataSource;
import org.springframework.jndi.JndiTemplate;

/**
 * @author caibo
 * @version $Id$
 * @since 2017/10/14 下午9:57
 */
@Configuration
public class DataSourceConfig {

	@Autowired
	private DataSource dataSource;

	@Bean
	public JndiTemplate jndiTemplate() {
		return new JndiTemplate();
	}

	@Bean
	public DataSource dataSource() throws SQLException {
		DriverManagerDataSource ds = new DriverManagerDataSource();
		ds.setDriverClassName("com.mysql.jdbc.Driver");
		ds.setUrl(System.getProperty("db.url"));
		ds.setUsername(System.getProperty("db.username"));
		ds.setPassword(System.getProperty("db.password"));
		return ds;
	}

	@Bean
	public SqlSessionFactory sqlSessionFactory() throws Exception {
		SqlSessionFactoryBean sqlSessionFactoryBean = new SqlSessionFactoryBean();
		// 配置数据库
		sqlSessionFactoryBean.setDataSource(dataSource);
		// 配置MapperConfig
		org.apache.ibatis.session.Configuration configuration = new org.apache.ibatis.session.Configuration();
		// 这个配置使全局的映射器启用或禁用缓存
		configuration.setCacheEnabled(true);
		// 允许 JDBC 支持生成的键，需要适合的驱动（如MySQL，SQL Server，Sybase ASE）。
		// 如果设置为 true 则这个设置强制生成的键被使用，尽管一些驱动拒绝兼容但仍然有效（比如 Derby）。
		// 但是在 Oracle 中一般不需要它，而且容易带来其它问题，比如对创建同义词DBLINK表插入时发生以下错误：
		// "ORA-22816: unsupported feature with RETURNING clause" 在 Oracle 中应明确使用 selectKey 方法
		configuration.setUseGeneratedKeys(false);
		// 配置默认的执行器。SIMPLE 执行器没有什么特别之处；REUSE 执行器重用预处理语句；BATCH 执行器重用语句和批量更新
		configuration.setDefaultExecutorType(ExecutorType.REUSE);
		// 全局启用或禁用延迟加载，禁用时所有关联对象都会即时加载
		configuration.setLazyLoadingEnabled(false);
		// 设置SQL语句执行超时时间缺省值，具体SQL语句仍可以单独设置
		configuration.setDefaultStatementTimeout(5000);

		sqlSessionFactoryBean.setConfiguration(configuration);
		// 使用 databaseId 以支持不同数据库类型的 SQL 语句
		VendorDatabaseIdProvider databaseIdProvider = new VendorDatabaseIdProvider();
		Properties vendorProperties = new Properties();
		vendorProperties.setProperty("MySQL", "mysql");
		databaseIdProvider.setProperties(vendorProperties);
		sqlSessionFactoryBean.setDatabaseIdProvider(databaseIdProvider);
		// 匹配多个 MapperConfig.xml, 使用mappingLocation属性
		PathMatchingResourcePatternResolver resolver = new PathMatchingResourcePatternResolver();
		sqlSessionFactoryBean.setMapperLocations(resolver.getResources("classpath*:com/charpty/**/*Mapper.xml"));

		return sqlSessionFactoryBean.getObject();
	}
}
