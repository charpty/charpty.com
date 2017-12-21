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
import java.util.function.Consumer;
import java.util.function.Function;

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

	public static final Map<String, Runnable> getServerControllers(BootOption option) {
		Map<String, Runnable> result = new HashMap<>();
		return result;
	}

	public static final void aeMain(Selector selector, BootOption option) throws IOException {
		while (true) {
			aeMain(selector);
		}
	}

	private static final void aeMain(Selector selector) throws IOException {
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
				// 扩容测试
				if (read == 0 && buffer.position() == buffer.capacity()) {
					ByteBuffer tmp = ByteBuffer.allocate(buffer.capacity() * 2);
					tmp.put(buffer);
					buffer = tmp;
					next.attach(buffer);
					continue;
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
				ByteBuffer out = ByteBuffer.allocate(256);
				out.clear();
				String res = "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nContent-Length: 0" + "\r\n\r\n\r\n";
				out.put(res.getBytes());
				out.flip();
				channel.write(out);
				channel.close();
				out = null;
				it.remove();
			}
		}
	}
}
