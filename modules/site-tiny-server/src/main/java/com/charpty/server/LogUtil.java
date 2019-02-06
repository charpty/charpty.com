package com.charpty.server;

/**
 * @author charpty
 * @version $Id$
 * @since Feb 06, 2019 10:40
 */
public class LogUtil {

    public static void debug(Class<?> clazz, String format, Object... args) {
        System.out.println(String.format(format, args));
    }

    public static void debug(Object object, String format, Object... args) {
        System.out.println(String.format(format, args));
    }

}
