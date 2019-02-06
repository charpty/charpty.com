package com.charpty.server;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

/**
 * @author charpty
 * @version $Id$
 * @since Feb 06, 2019 21:36
 */
public class ResponseUtil {

    private static final Gson FORMAT;

    private ResponseUtil() {
        super();
    }

    static {
        GsonBuilder builder = new GsonBuilder();
        builder.setDateFormat("yyyy-MM-dd");
        FORMAT = builder.create();
    }

    public static String toResponse(Object response) {
        return FORMAT.toJson(response);
    }

}
