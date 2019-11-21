package com.momo.justicecenter.utils;

import android.os.Handler;
import android.os.Looper;

import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.RejectedExecutionHandler;
import java.util.concurrent.ThreadFactory;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;

public class ThreadHelper {
    private final ThreadPoolExecutor mThreadPoolExecutor;
    private final static String TAG = "ThreadHelper";
    private int mThreadIndex;
    private Handler mMainHandler;
    private static class Holder {
        private final static ThreadHelper sInstance = new ThreadHelper();
    }

    private ThreadHelper() {
        mThreadPoolExecutor = new ThreadPoolExecutor(5, 5, 10,
                TimeUnit.SECONDS, new LinkedBlockingQueue<Runnable>(), new ThreadFactory() {
            @Override
            public Thread newThread(Runnable r) {
                Thread thread = new Thread(r);
                thread.setPriority(Thread.MAX_PRIORITY);
                thread.setName("ThreadHelper_" + String.valueOf(mThreadIndex++));
                MLogger.d(TAG, "thread create :" + thread.getName());
                return thread;
            }
        }, new RejectedExecutionHandler() {
            @Override
            public void rejectedExecution(Runnable r, ThreadPoolExecutor executor) {
                MLogger.e(TAG, "Rejected Execution", r);
            }
        });
        mThreadPoolExecutor.allowCoreThreadTimeOut(true);
    }

    public static ThreadHelper getInstance() {
        return Holder.sInstance;
    }

    public void execute(Runnable runnable) {
        mThreadPoolExecutor.execute(runnable);
    }

    public void executeInMain(Runnable runnable) {
        if (mMainHandler == null) {
            mMainHandler = new Handler(Looper.getMainLooper());
        }
        mMainHandler.post(runnable);
    }

}
