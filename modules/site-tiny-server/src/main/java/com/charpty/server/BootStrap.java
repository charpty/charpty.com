package com.charpty.server;

import java.io.IOException;
import java.lang.management.ManagementFactory;
import java.net.InetSocketAddress;
import java.nio.ByteBuffer;
import java.nio.channels.SelectionKey;
import java.nio.channels.Selector;
import java.nio.channels.ServerSocketChannel;
import java.nio.channels.SocketChannel;
import java.util.Iterator;
import java.util.Set;
import java.util.concurrent.ExecutorService;

/**
 * @author caibo
 * @version $Id$
 * @since 2017/10/10 下午9:08
 */
public final class BootStrap {

    private static final String RESPONSE_LINE = "HTTP/1.1 200 OK\r\n";
    private static final String RESPONSE_HEADER = "Content-Type:application/json;charset=UTF-8\r\n";
    private static final String START_INFO_FORMAT = "Server listen on: %d, Started in: %dms";
    private static String apiPath;
    private static int apiPathLen;

    private static final ExecutorService ES = new BootExecutor();

    private BootStrap() {
        super();
    }

    public static final void listen(BootContext context) throws IOException {
        ServerSocketChannel ssc = ServerSocketChannel.open();
        ssc.bind(new InetSocketAddress(context.getPort()));
        ssc.configureBlocking(false);
        Selector selector = Selector.open();
        ssc.register(selector, SelectionKey.OP_ACCEPT);

        apiPath = context.getApiPath();
        apiPathLen = apiPath.length();

        long consume = System.currentTimeMillis() - ManagementFactory.getRuntimeMXBean().getStartTime();
        LogUtil.info(BootStrap.class, START_INFO_FORMAT, context.getPort(), consume);
        while (true) {
            try {
                aeMain(selector, context);
            } catch (Exception e) {
                LogUtil.error(BootStrap.class, e, "请求处理异常FF");
            }
        }
    }

    private static final void aeMain(Selector selector, BootContext context) throws IOException {
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
                handleRequest(context, it, next);
            }
        }
    }

    private static void handleRequest(BootContext context, Iterator<SelectionKey> it, SelectionKey next)
            throws IOException {
        SocketChannel channel = (SocketChannel)next.channel();
        ByteBuffer buffer = (ByteBuffer)next.attachment();
        if (buffer == null) {
            buffer = ByteBuffer.allocate(128);
            next.attach(buffer);
        }
        int read = channel.read(buffer);
        if (read < 0) {
            it.remove();
            return;
        }
        if (read == 0 && buffer.position() == buffer.capacity()) {
            // buffer不够
            if (buffer.capacity() < 256) {
                ByteBuffer tmp = ByteBuffer.allocate(buffer.capacity() * 2);
                tmp.put(buffer);
                next.attach(buffer);
                return;
            }
            // 按理应继续扩容，但当读超过256时应该已经读完了URL部分
            // do nothing
        }
        String tmp = new String(buffer.array(), 0, buffer.position());
        // 我的博客服务器只有GET请求
        if (!tmp.startsWith("GET")) {
            it.remove();
            return;
        }
        int i = tmp.indexOf("\n");
        if (i < 0) {
            // 不太可能还没读到
            it.remove();
            return;
        }
        int s = tmp.indexOf(" ", 4);
        String fullPath = tmp.substring(4, s);
        if (fullPath.startsWith(apiPath)) {
            fullPath = fullPath.substring(apiPathLen);
        }
        if (fullPath.endsWith("\r")) {
            fullPath = fullPath.substring(0, fullPath.length() - 1);
        }
        buffer.clear();
        buffer = null;
        String responseBody = processRequest(context, new HTTPRequest(context, fullPath));

        if (responseBody == null) {
            writeError(channel);
            it.remove();
            return;
        }
        StringBuffer sb = new StringBuffer(responseBody.length() + 256);
        // header
        sb.append(RESPONSE_LINE);
        sb.append(RESPONSE_HEADER);
        sb.append("Content-Length: ");
        sb.append(responseBody.getBytes().length);
        // content
        sb.append("\r\n\r\n").append(responseBody);
        sb.append("\r\n\r\n\r\n");

        byte[] bytes = sb.toString().getBytes();
        int n = 0;
        ByteBuffer out = ByteBuffer.allocate(4096);
        out.clear();
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
        channel.close();
    }

    private static String processRequest(BootContext context, HTTPRequest request) {
        for (RequestHandler handler : context.getHandlers()) {
            String body = handler.handle(request);
            if (body != null) {
                return body;
            }
        }
        return null;
    }

    private static void writeError(SocketChannel channel) throws IOException {
        // 所有错误统一响应422
        ByteBuffer out = ByteBuffer.allocate(256);
        out.clear();
        out.put("HTTP/1.1 422 422\r\n\r\n\r\n".getBytes());
        out.flip();
        channel.write(out);
        channel.close();
    }
}
