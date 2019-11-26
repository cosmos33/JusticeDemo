package com.momo.justicecenter;

import android.app.Application;
import android.content.Context;
import android.util.Pair;

import com.immomo.justice.Justice;
import com.momo.justicecenter.callback.OnAsyncJusticeCallback;
import com.momo.justicecenter.callback.OnPreloadCallback;
import com.momo.justicecenter.resource.ResResult;
import com.momo.justicecenter.resource.ResourceManager;
import com.momo.justicecenter.utils.FileHelper;
import com.momo.justicecenter.utils.MLogger;
import com.momo.justicecenter.utils.ThreadHelper;

import java.io.File;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class JusticeCenter {
    public static final String SDK_VERSION_NAME = "1.0.0";
    public static final int SDK_VERSION_CODE = 10000;
    private static final String TAG = "JusticeCenter...";
    private static String sAPPID;
    private static Context sContext;

    public static void init(Application application, String appId) {
        sContext = application;
        sAPPID = appId;
    }

    public static Context getContext() {
        return sContext;
    }

    public static String getAPPID() {
        return sAPPID;
    }

    public static void preload(Set<String> bussiness, final OnPreloadCallback listener) {
        if (bussiness == null || bussiness.size() == 0) {
            throw new IllegalArgumentException("business must be not empty");
        }
        ResourceManager sResourceManager = new ResourceManager();
        loadResource(bussiness, listener, sResourceManager);
    }

    private static void loadResource(final Set<String> bussiness, final OnPreloadCallback listener, final ResourceManager sResourceManager) {
        sResourceManager.loadResource(bussiness, new ResourceManager.OnResourceLoadedListener() {
            @Override
            public void onResourceLoadResult(Map<String, ResResult> result) {
                boolean isAllSuccess = true;
                for (Map.Entry<String, ResResult> entry : result.entrySet()) {
                    String key = entry.getKey();
                    ResResult value = entry.getValue();
                    MLogger.d(key, "-", value);
                    isAllSuccess &= value.isOK;
                }
                if (!isAllSuccess && sResourceManager.currentRetryTime < ResourceManager.RETRY_TIME) {
                    sResourceManager.currentRetryTime++;
                    ThreadHelper.getInstance().execute(new Runnable() {
                        @Override
                        public void run() {
                            try {
                                MLogger.d(TAG, "正在准备重试", sResourceManager.currentRetryTime);
                                Thread.sleep(ResourceManager.RETRY_DELAY);
                            } catch (InterruptedException e) {
                            }
                            MLogger.d(TAG, "正在重试", sResourceManager.currentRetryTime);
                            loadResource(bussiness, listener, sResourceManager);
                        }
                    });
                } else {
                    MLogger.d(TAG, "结果回调 ", sResourceManager.currentRetryTime);
                    if (listener != null) {
                        listener.onPreloadCallback(result);
                    }
                }
            }
        });
    }

    public static void asyncNewJustice(Set<String> bussiness, final OnAsyncJusticeCallback callback) {
        preload(bussiness, new OnPreloadCallback() {
            @Override
            public void onPreloadCallback(Map<String, ResResult> result) {
                MLogger.d(TAG, " resources preload callback ,current thread ", Thread.currentThread().getName());
                final List<Pair<String, String>> businessesWithDirs = new ArrayList<>();
                final List<String> successedBusiness = new ArrayList<>();
                for (Map.Entry<String, ResResult> entry : result.entrySet()) {
                    if (entry.getValue().isOK) {
                        File resource = FileHelper.getResource(entry.getKey(), null);
                        if (resource != null) {
                            successedBusiness.add(entry.getKey());
                            businessesWithDirs.add(Pair.create(entry.getKey(), resource.getAbsolutePath())); // 色情识别
                        }
                    }
                }
                constuctAndCallback(businessesWithDirs, successedBusiness, callback);
            }
        });
    }

    private static void constuctAndCallback(final List<Pair<String, String>> businessesWithDirs, final List<String> successedBusiness, final OnAsyncJusticeCallback callback) {
        ThreadHelper.getInstance().execute(new Runnable() {
            @Override
            public void run() {
                if (businessesWithDirs.isEmpty()) {
                    if (callback != null) {
                        callback.onFailed("no business resource is available!");
                    }
                    return;
                }
                try {
                    Justice justice = new Justice(businessesWithDirs);
                    if (callback != null) {
                        callback.onCreated(justice, successedBusiness);
                    }
                } catch (Exception e) {
                    if (callback != null) {
                        callback.onFailed(e.getLocalizedMessage());
                    }
                }
            }
        });
    }
}
