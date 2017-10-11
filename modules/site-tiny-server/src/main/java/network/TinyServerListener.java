package network;

import java.io.IOException;
import java.net.InetSocketAddress;
import java.nio.channels.SelectableChannel;
import java.nio.channels.SelectionKey;
import java.nio.channels.Selector;
import java.nio.channels.ServerSocketChannel;
import java.nio.channels.SocketChannel;
import java.util.Iterator;
import java.util.Set;
import java.util.concurrent.Executors;
import server.ServiceThreadPool;

/**
 * @author caibo
 * @version $Id$
 * @since 2017/10/10 下午9:24
 */
public class TinyServerListener {

	private final ServiceThreadPool serviceThreadPool;

	public TinyServerListener(int port, ServiceThreadPool serviceThreadPool) {
		this.serviceThreadPool = serviceThreadPool;
	}

	public void init(int port) throws IOException {
		ServerSocketChannel ssc = ServerSocketChannel.open();
		InetSocketAddress isa = new InetSocketAddress(port);
		ssc.bind(isa);

		Selector selector = Selector.open();
		ssc.register(selector, SelectionKey.OP_ACCEPT);
		Set<SelectionKey> keys = selector.selectedKeys();
		Iterator<SelectionKey> it = keys.iterator();
		while (it.hasNext()) {
			SelectionKey key = it.next();
			if (key.isAcceptable()) {
				// 有连接建立开始处理，这样是不是大量连接建立销毁？
				// 专门处理HTTP的服务器是这种处理办法吗？
				ServerSocketChannel server = (ServerSocketChannel) key.channel();
				SocketChannel channel = server.accept();
				channel.configureBlocking(false);
				channel.register(selector, SelectionKey.OP_READ);
			} else if (key.isReadable()) {
				// TODO 在这里读取数据并处理
			}
			it.remove();
		}
	}

}
