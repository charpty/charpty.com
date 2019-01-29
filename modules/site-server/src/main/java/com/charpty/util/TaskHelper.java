package com.charpty.util;

import java.util.concurrent.Executor;
import java.util.concurrent.Executors;

/**
 * @author charpty
 * @version $Id$
 * @since Jan 29, 2019 20:24
 */
public class TaskHelper {

    public static final Executor executor;

    static {
        executor = Executors.newSingleThreadExecutor();
    }

    public static void execute(Runnable task) {
        executor.execute(task);
    }

}
