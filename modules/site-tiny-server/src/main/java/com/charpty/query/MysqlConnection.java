package com.charpty.query;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;

/**
 * @author charpty
 * @since 2017/12/24
 */
public class MysqlConnection {

	public MysqlConnection(String url, String username, String password) {
		try {
			Class.forName("com.mysql.jdbc.Driver");
		} catch (ClassNotFoundException e) {
			throw new RuntimeException("加载Mysql驱动失败", e);
		}
		// TODO 连接池
		Connection con = null;
		try {
			con = DriverManager.getConnection(url);
		} catch (SQLException e) {
			throw new RuntimeException("与Mysql数据库建立连接失败", e);
		}
	}
}
