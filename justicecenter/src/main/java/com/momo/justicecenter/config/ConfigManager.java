package com.momo.justicecenter.config;

import com.momo.justicecenter.network.JusticeRequest;

import java.util.ArrayList;
import java.util.List;

public class ConfigManager {
    private List<OnConfigLoadedListener> mOnConfigLoadedListeners = new ArrayList<>();
    private boolean isLoading;
    private ResourceConfig mResourceConfig;

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

    public synchronized void loadConfig(int sdkVersion, String avatarStyle, OnConfigLoadedListener listener) {
        if (isConfigLoaded()) {
            listener.onConfigLoaded(mResourceConfig);
        } else {
            mOnConfigLoadedListeners.add(listener);
            if (!isLoadingConfig()) {
                isLoading = true;
                load(sdkVersion, avatarStyle);
            }
        }
    }

    private void load(int sdkVersion, String avatarStyle) {
        JusticeRequest.getInstance().configRequst(new JusticeRequest.OnConfigRequestListener() {
            @Override
            public void onSuccess(ResourceConfig config) {
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

    private synchronized void successCallback(ResourceConfig config) {
        mResourceConfig = config;
        for (OnConfigLoadedListener onConfigLoadedListener : mOnConfigLoadedListeners) {
            onConfigLoadedListener.onConfigLoaded(mResourceConfig);
        }
        mOnConfigLoadedListeners.clear();
        isLoading = false;
    }

    public interface OnConfigLoadedListener {
        void onConfigLoaded(ResourceConfig resourceConfig);

        void onConfigFailed(int code, String msg);
    }
}
