package com.charpty.network;

import java.net.InetSocketAddress;
import java.nio.ByteBuffer;
import java.nio.channels.SelectionKey;
import java.nio.channels.Selector;
import java.nio.channels.ServerSocketChannel;
import java.nio.channels.SocketChannel;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.Iterator;
import java.util.Set;

/**
 * @author caibo
 * @version $Id$
 * @since 2017/10/10 下午9:47
 */
public class ServerResponseTimeTest {

	public static void main(String[] args) throws Exception {
		ServerSocketChannel ssc = ServerSocketChannel.open();
		ssc.bind(new InetSocketAddress(8833));
		ssc.configureBlocking(false);
		Selector selector = Selector.open();
		ssc.register(selector, SelectionKey.OP_ACCEPT);
		Class.forName("com.mysql.jdbc.Driver");
		String url = "jdbc:mysql://localhost:33066/charptysite?characterEncoding=utf8&useSSL=false&user=charptysite&password=rap1bpm2ifm3qrm";
		Connection con = DriverManager.getConnection(url);
		Statement statement = con.createStatement();
		while (true) {
			int select = selector.select();
			Set<SelectionKey> keys = selector.selectedKeys();
			Iterator<SelectionKey> it = keys.iterator();
			while (it.hasNext()) {
				SelectionKey next = it.next();
				if (next.isAcceptable()) {
					ServerSocketChannel channel = (ServerSocketChannel) next.channel();
					SocketChannel socket = channel.accept();
					socket.configureBlocking(false);
					socket.register(selector, SelectionKey.OP_READ);
					it.remove();
				} else if (next.isReadable()) {
					SocketChannel channel = (SocketChannel) next.channel();
					ByteBuffer buffer = (ByteBuffer) next.attachment();
					if (buffer == null) {
						buffer = ByteBuffer.allocate(64);
						next.attach(buffer);
					}
					int read = channel.read(buffer);
					if (read < 0) {
						it.remove();
						continue;
					}
					if (read == 0 && buffer.position() == buffer.capacity()) {
						it.remove();
						continue;
					}
					String tmp = new String(buffer.array(), 0, buffer.position());
					if (!tmp.startsWith("GET")) {
						it.remove();
						continue;
					}
					int i = tmp.indexOf("\n");
					if (i < 0) {
						// 不太可能还没读到
						it.remove();
						continue;
					}
					int s = tmp.indexOf(" ", 4);
					String path = tmp.substring(4, s);
					if (path.endsWith("\r")) {
						path = path.substring(0, path.length() - 1);
					}
					buffer.clear();
					buffer = null;
					if (!path.startsWith("/articles")) {
						it.remove();
						continue;
					}
					String sql = "SELECT ID,NAME,TITLE,SUMMARY FROM ARTICLE";
					ResultSet rs = statement.executeQuery(sql);
					StringBuffer sb = new StringBuffer(6144);
					sb.append('[');
					while (rs.next()) {
						sb.append("{\"id\":").append(rs.getInt(1));
						sb.append(",\"name\":\"").append(rs.getString(2));
						sb.append("\",\"title\":\"").append(rs.getString(3));
						sb.append("\",\"summary\":\"").append(rs.getString(4));
						sb.append('}');
					}
					sb.append(']');
					ByteBuffer out = ByteBuffer.allocate(1024);
					out.clear();
					String res = "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nContent-Length: " + sb.toString().getBytes().length //
							+ "\r\nContent-Type:application/json;charset=UTF-8" //
							+ "\r\n\r\n" + sb.toString() + "\r\n\r\n\r\n";
					byte[] bytes = res.getBytes();
					int n = 0;
					while (n < bytes.length) {
						out.clear();
						int x = n + 1024 > bytes.length ? (bytes.length - n) : 1024;
						out.put(bytes, n, x);
						out.flip();
						channel.write(out);
						n = n + x;
					}
					out = null;
					it.remove();
				}
			}
		}
	}

}
