package com.charpty.network;

import java.net.InetSocketAddress;
import java.nio.ByteBuffer;
import java.nio.channels.SelectionKey;
import java.nio.channels.Selector;
import java.nio.channels.ServerSocketChannel;
import java.nio.channels.SocketChannel;
import java.util.Iterator;
import java.util.Set;

/**
 * @author caibo
 * @version $Id$
 * @since 2017/10/10 下午9:47
 */
public class TinyServerListenerTest {

	public static void main(String[] args) throws Exception {
		ServerSocketChannel ssc = ServerSocketChannel.open();
		ssc.bind(new InetSocketAddress(8822));
		ssc.configureBlocking(false);
		Selector selector = Selector.open();
		// 写事件注册，持续可写时可以攻击客户端
		ssc.register(selector, SelectionKey.OP_ACCEPT);
		outer:
		while (true) {
			long t1 = System.nanoTime();
			int select = selector.select();
			Set<SelectionKey> keys = selector.selectedKeys();
			Iterator<SelectionKey> it = keys.iterator();
			while (it.hasNext()) {
				SelectionKey next = it.next();
				// 并发删除测试
				if (next.isAcceptable()) {
					ServerSocketChannel channel = (ServerSocketChannel) next.channel();
					SocketChannel socket = channel.accept();
					socket.configureBlocking(false);
					socket.register(selector, SelectionKey.OP_READ);
					it.remove();
				} else if (next.isReadable()) {
					// ab测试10W
					SocketChannel channel = (SocketChannel) next.channel();
					ByteBuffer bb = (ByteBuffer) next.attachment();
					if (bb == null) {
						bb = ByteBuffer.allocate(128);
						next.attach(bb);
					}
					int read = channel.read(bb);
					if (read < 0) {
						continue;
					}
					// 扩容测试
					if (read == 0 && bb.position() == bb.capacity()) {
						ByteBuffer tmp = ByteBuffer.allocate(bb.capacity() * 2);
						tmp.put(bb);
						bb = tmp;
						next.attach(bb);
						continue;
					}
					String tmp = new String(bb.array(), 0, bb.position());
					System.out.println(tmp);
					if (tmp.lastIndexOf("\r\n\r\n") < 0 && tmp.lastIndexOf("\n\n") < 0) {
						continue;
					}
					// byte[] arr = new byte[read];
					// 大量读与溢出测试
					// System.arraycopy(bb.array(), 0, arr, 0, read);
					// System.out.println(new String(arr));

					// 尾部换行
					bb.clear();
					String res = "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nContent-Length: 4" + "\r\n\r\n123456789" + "\r\n\r\n\r\n";
					bb.put(res.getBytes());
					bb.flip();
					channel.write(bb);
					channel.close();
					it.remove();
				}
				System.out.println("处理" + select + "个耗时:" + (System.nanoTime() - t1));
			}
		}
	}

}
