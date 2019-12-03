package com.momo.justicecenter.config;

import com.momo.justicecenter.network.JusticeRequest;

import java.util.ArrayList;
import java.util.List;

public class ConfigManager {
    private List<OnConfigLoadedListener> mOnConfigLoadedListeners = new ArrayList<>();
    private boolean isLoading;
    private Config mResourceConfig;

    private static class Holder {
        private static final ConfigManager RES_CONFIG_LOADER = new ConfigManager();
    }

    public static ConfigManager getInstance() {
        return Holder.RES_CONFIG_LOADER;
    }

    public synchronized boolean isConfigLoaded() {
        return mResourceConfig != null;
    }

    public synchronized boolean isLoadingConfig() {
        return isLoading;
    }

    public synchronized void loadConfig(OnConfigLoadedListener listener) {
        if (isConfigLoaded()) {
            listener.onConfigLoaded(mResourceConfig);
        } else {
            mOnConfigLoadedListeners.add(listener);
            if (!isLoadingConfig()) {
                isLoading = true;
                load();
            }
        }
    }

    public synchronized void clearCache() {
        mResourceConfig = null;
    }

    private void load() {
        JusticeRequest.getInstance().configRequst(new JusticeRequest.OnConfigRequestListener() {
            @Override
            public void onSuccess(Config config) {
                successCallback(config);
            }

            @Override
            public void onFailed(int code, String msg) {
                failCallback(code, msg);
            }
        });
    }

    private synchronized void failCallback(int code, String msg) {
        for (OnConfigLoadedListener onConfigLoadedListener : mOnConfigLoadedListeners) {
            onConfigLoadedListener.onConfigFailed(code, msg);
        }
        mOnConfigLoadedListeners.clear();
        isLoading = false;
    }

    private synchronized void successCallback(Config config) {
        mResourceConfig = config;
        for (OnConfigLoadedListener onConfigLoadedListener : mOnConfigLoadedListeners) {
            onConfigLoadedListener.onConfigLoaded(mResourceConfig);
        }
        mOnConfigLoadedListeners.clear();
        isLoading = false;
    }

    public interface OnConfigLoadedListener {
        void onConfigLoaded(Config resourceConfig);

        void onConfigFailed(int code, String msg);
    }
}
