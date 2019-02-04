package com.charpty.server;

import java.io.IOException;
import java.net.InetSocketAddress;
import java.nio.ByteBuffer;
import java.nio.channels.SelectionKey;
import java.nio.channels.Selector;
import java.nio.channels.ServerSocketChannel;
import java.nio.channels.SocketChannel;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

/**
 * @author caibo
 * @version $Id$
 * @since 2017/10/10 下午9:08
 */
public final class BootStrap {

    private static final String RESPONSE_LINE = "HTTP/1.1 200 OK\r\n";
    private static final String RESPONSE_HEADER = "Content-Type:application/json;charset=UTF-8\r\n";

    private BootStrap() {
        super();
    }

    public static final void listen(BootContext context) throws IOException {
        ServerSocketChannel ssc = ServerSocketChannel.open();
        ssc.bind(new InetSocketAddress(context.getPort()));
        ssc.configureBlocking(false);
        Selector selector = Selector.open();
        ssc.register(selector, SelectionKey.OP_ACCEPT);

        aeMain(selector, context.getHandlerMap());
    }

    private static RequestHandler getRequestHandler(Map<String, RequestHandler> handlerMap, HTTPRequest request) {
        return handlerMap.get("");
    }

    private static void writeError(ByteBuffer out) {
        // 所有错误统一响应404
        out.put("HTTP/1.1 422 422".getBytes());
    }

    private static final void aeMain(Selector selector, Map<String, RequestHandler> handlerMap) throws IOException {
        selector.select();
        Set<SelectionKey> keys = selector.selectedKeys();
        Iterator<SelectionKey> it = keys.iterator();
        while (it.hasNext()) {
            SelectionKey next = it.next();
            if (next.isAcceptable()) {
                ServerSocketChannel channel = (ServerSocketChannel)next.channel();
                SocketChannel socket = channel.accept();
                socket.configureBlocking(false);
                socket.register(selector, SelectionKey.OP_READ);
                it.remove();
            } else if (next.isReadable()) {
                SocketChannel channel = (SocketChannel)next.channel();
                ByteBuffer buffer = (ByteBuffer)next.attachment();
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
                HTTPRequest request = new HTTPRequest();
                RequestHandler handler = getRequestHandler(handlerMap, request);
                ByteBuffer out = ByteBuffer.allocate(256);
                out.clear();
                if (handler == null) {
                    writeError(out);
                    it.remove();
                    continue;
                }
                String content = null;
                content = handler.handle(request);
                StringBuffer sb = new StringBuffer(1024);
                // header
                sb.append(RESPONSE_LINE);
                sb.append(RESPONSE_HEADER);
                sb.append("Content-Length: ");
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
