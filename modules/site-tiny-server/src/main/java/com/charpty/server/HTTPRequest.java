package com.charpty.server;

import java.util.HashMap;
import java.util.Map;

/**
 * @author charpty
 * @version $Id$
 * @since Feb 04, 2019 22:24
 */
public class HTTPRequest {

    private final BootContext context;
    // 请求路径
    private final String path;
    // 目前仅有GET请求，无请求体
    private Map<String, String> params;

    public HTTPRequest(BootContext context, String fullPath) {
        this.context = context;
        int i = fullPath.indexOf("?");
        this.path = i < 0 ? fullPath : fullPath.substring(0, i);
        if (i > 0) {
            String[] queryParams = fullPath.substring(i + 1).split("&");
            params = new HashMap<>(16);
            for (String param : queryParams) {
                String[] pair = param.split(";");
                params.put(pair[0], pair[1]);
            }
        }
    }

    public BootContext getContext() {
        return context;
    }

    public String getPath() {
        return path;
    }

    public Map<String, String> getParams() {
        return params;
    }

}
