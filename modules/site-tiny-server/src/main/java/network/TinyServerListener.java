package network;

import java.io.IOException;
import java.net.InetSocketAddress;
import java.net.SocketAddress;
import java.nio.channels.SelectionKey;
import java.nio.channels.Selector;
import java.nio.channels.ServerSocketChannel;
import java.util.Iterator;
import java.util.Set;
import boot.BootOption;

/**
 * @author caibo
 * @version $Id$
 * @since 2017/10/10 下午9:24
 */
public class TinyServerListener {

	public TinyServerListener(int port) {

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
			if ((key.readyOps() & SelectionKey.OP_ACCEPT) == 1) {
				// TODO Service Thread
			}
		}
	}

}
