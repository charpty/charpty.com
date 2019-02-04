package com.charpty.server;

import java.util.Map;

/**
 * @author charpty
 * @version $Id$
 * @since Feb 04, 2019 22:24
 */
public class HTTPRequest {

    // 请求路径
    private String path;
    // 目前仅有GET请求，无请求体
    private Map<String, String> params;

    public String getPath() {
        return path;
    }

    public void setPath(String path) {
        this.path = path;
    }

    public Map<String, String> getParams() {
        return params;
    }

    public void setParams(Map<String, String> params) {
        this.params = params;
    }

}
