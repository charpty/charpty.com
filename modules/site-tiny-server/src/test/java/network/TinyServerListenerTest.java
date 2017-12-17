package network;

import java.net.InetSocketAddress;
import java.net.ServerSocket;
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
		while (true) {
			int select = selector.select();
			Set<SelectionKey> keys = selector.selectedKeys();
			Iterator<SelectionKey> it = keys.iterator();
			while (it.hasNext()) {
				SelectionKey next = it.next();
				// 并发删除测试
				it.remove();
				if (next.isAcceptable()) {
					ServerSocketChannel channel = (ServerSocketChannel) next.channel();
					SocketChannel socket = channel.accept();
					socket.configureBlocking(false);
					socket.register(selector, SelectionKey.OP_READ);
				} else if (next.isReadable()) {
					// ab测试10W
					SocketChannel channel = (SocketChannel) next.channel();
					ByteBuffer bb = ByteBuffer.allocate(128);
					int read = channel.read(bb);
					byte[] arr = new byte[read];
					// 大量读与溢出测试
					System.arraycopy(bb.array(), 0, arr, 0, read);
					System.out.println(new String(arr));
					// 尾部换行
					bb.clear();
					bb.put(arr);
					bb.flip();
					channel.write(bb);
				}

			}
		}
	}

}
