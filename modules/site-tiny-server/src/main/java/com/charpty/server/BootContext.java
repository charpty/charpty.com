package com.charpty.server;

import java.util.Map;

/**
 * @author caibo
 * @version $Id$
 * @since 2017/10/10 下午9:05
 */
public class BootContext {

    private int port = 5566;
    // 所有请求均范围JSON格式数据
    private Map<String, RequestHandler> handlerMap;

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

    public Map<String, RequestHandler> getHandlerMap() {
        return handlerMap;
    }

    public void setHandlerMap(Map<String, RequestHandler> handlerMap) {
        this.handlerMap = handlerMap;
    }
}
