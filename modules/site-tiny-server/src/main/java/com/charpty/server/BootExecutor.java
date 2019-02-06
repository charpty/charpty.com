package com.charpty.server;

import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.RejectedExecutionHandler;
import java.util.concurrent.ThreadFactory;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;

/**
 * @author caibo
 * @version $Id$
 * @since 2017/10/10 下午9:14
 */
public class BootExecutor extends ThreadPoolExecutor {

    public BootExecutor() {
        super(5, 30, 1800, TimeUnit.SECONDS, new ArrayBlockingQueue<Runnable>(32), (r) -> new Thread(),
                (r, executor) -> {
                    throw new RuntimeException("queue is full");
                });
    }

    public BootExecutor(int corePoolSize, int maximumPoolSize, long keepAliveTime, TimeUnit unit,
            BlockingQueue<Runnable> workQueue, ThreadFactory threadFactory, RejectedExecutionHandler handler) {
        super(corePoolSize, maximumPoolSize, keepAliveTime, unit, workQueue, threadFactory, handler);
    }
}
