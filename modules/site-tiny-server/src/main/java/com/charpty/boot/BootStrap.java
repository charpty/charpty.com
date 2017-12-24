package com.charpty.boot;

import java.io.IOException;
import java.net.InetSocketAddress;
import java.nio.ByteBuffer;
import java.nio.channels.SelectionKey;
import java.nio.channels.Selector;
import java.nio.channels.ServerSocketChannel;
import java.nio.channels.SocketChannel;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.Callable;
import java.util.function.Consumer;
import java.util.function.Function;
import com.charpty.query.DailyWordQuery;

/**
 * @author caibo
 * @version $Id$
 * @since 2017/10/10 下午9:08
 */
public final class BootStrap {

	private BootStrap() {
		super();
	}

	public static final Selector listen(BootOption option) throws IOException {
		ServerSocketChannel ssc = ServerSocketChannel.open();
		ssc.bind(new InetSocketAddress(option.getPort()));
		ssc.configureBlocking(false);
		Selector selector = Selector.open();
		ssc.register(selector, SelectionKey.OP_ACCEPT);
		return selector;
	}

	public static final Map<String, Callable<String>> getServerControllers(BootOption option) {
		Map<String, Callable<String>> result = new HashMap<>();
		result.put("/s/api/word/random", new DailyWordQuery()::random);
		return result;
	}

	public static final void aeMain(Selector selector, BootOption option) throws IOException {
		Map<String, Callable<String>> controllers = option.getControllers();
		while (true) {
			aeMain(selector, controllers);
		}
	}

	private static final void aeMain(Selector selector, Map<String, Callable<String>> controllers) throws IOException {
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
					buffer = ByteBuffer.allocate(128);
					next.attach(buffer);
				}
				int read = channel.read(buffer);
				if (read < 0) {
					it.remove();
					continue;
				}
				if (read == 0 && buffer.position() == buffer.capacity()) {
					// buffer不够
					if (buffer.capacity() < 256) {
						ByteBuffer tmp = ByteBuffer.allocate(buffer.capacity() * 2);
						tmp.put(buffer);
						next.attach(buffer);
						continue;
					}
					// 按理应继续扩容，但当读超过256时应该已经读完了URL部分
					// do nothing
				}
				String tmp = new String(buffer.array(), 0, buffer.position());
				// 我的博客服务器只有GET请求
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
				Callable<String> action = controllers.get(path);
				if (action != null) {
					String content = null;
					try {
						content = action.call();
					} catch (Exception e) {
						e.printStackTrace();
					}
					ByteBuffer out = ByteBuffer.allocate(256);
					out.clear();
					StringBuffer sb = new StringBuffer(1024);
					// header
					sb.append("HTTP/1.1 200 OK\r\n" + "Content-Type:application/json;charset=UTF-8\r\n" + "Content-Length: ");
					sb.append(content.getBytes().length);
					// content
					sb.append("\r\n\r\n").append(content);
					sb.append("\r\n\r\n\r\n");

					byte[] bytes = sb.toString().getBytes();
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
