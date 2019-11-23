package com.momo.justicecenter;

import android.app.Application;
import android.content.Context;

import com.momo.justicecenter.resource.ResResult;
import com.momo.justicecenter.resource.ResourceManager;
import com.momo.justicecenter.utils.MLogger;

import java.io.File;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class JusticeCenter {
    public static final String SDK_VERSION_NAME = "1.0.0";
    public static final int SDK_VERSION_CODE = 10000;
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

    public static void preload(Set<String> bussiness, final ResourceManager.OnResourceLoadedListener listener) {
        new ResourceManager().loadResource(bussiness, new ResourceManager.OnResourceLoadedListener() {
            @Override
            public void onResourceLoadResult(Map<String, ResResult> result) {
                for (Map.Entry<String, ResResult> entry : result.entrySet()) {
                    String key = entry.getKey();
                    ResResult value = entry.getValue();
                    MLogger.d(key, "-", value);
                }
                if (listener != null) {
                    listener.onResourceLoadResult(result);
                }
            }
        });
    }

    public static void asyncNewJustice() {

    }
}
