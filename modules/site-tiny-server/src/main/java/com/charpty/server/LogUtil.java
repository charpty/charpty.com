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

    public static void info(Class<?> clazz, String format, Object... args) {
        System.out.println(String.format(format, args));
    }

    public static void info(Object object, String format, Object... args) {
        System.out.println(String.format(format, args));
    }

    public static void warn(Class<?> clazz, String format, Object... args) {
        System.out.println(String.format(format, args));
    }

    public static void warn(Object object, String format, Object... args) {
        System.out.println(String.format(format, args));
    }

    public static void error(Class<?> clazz, Throwable e, String format, Object... args) {
        System.out.println(String.format(format, args));
    }

    public static void error(Object object, Throwable e, String format, Object... args) {
        System.out.println(String.format(format, args));
    }

}
