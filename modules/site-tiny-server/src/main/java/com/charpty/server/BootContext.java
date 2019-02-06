package com.charpty.server;

import java.util.List;

/**
 * @author caibo
 * @version $Id$
 * @since 2017/10/10 下午9:05
 */
public class BootContext {

    private int port = 5566;
    // 所有请求均范围JSON格式数据
    private List<RequestHandler> handlers;
    private BootDataSource dataSource;

    public static BootContext buildBootContext(String[] args) {
        BootContext context = new BootContext();
        return context;
    }

    public int getPort() {
        return port;
    }

    public void setPort(int port) {
        this.port = port;
    }

    public List<RequestHandler> getHandlers() {
        return handlers;
    }

    public void setHandlers(List<RequestHandler> handlers) {
        this.handlers = handlers;
    }

    public BootDataSource getDataSource() {
        return dataSource;
    }

    public void setDataSource(BootDataSource dataSource) {
        this.dataSource = dataSource;
    }
}
