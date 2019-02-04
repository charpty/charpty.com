package com.charpty.server;

/**
 * @author charpty
 * @version $Id$
 * @since Feb 04, 2019 22:29
 */
@FunctionalInterface
public interface RequestHandler {

    /**
     * 目前我们仅处理HTTP请求
     *
     * @param request
     *
     * @return
     */
    String handle(HTTPRequest request);

}
