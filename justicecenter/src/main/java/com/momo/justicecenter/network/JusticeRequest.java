package com.momo.justicecenter.network;

import android.support.annotation.Nullable;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.momo.justicecenter.JusticeCenter;
import com.momo.justicecenter.config.ResourceConfig;
import com.momo.justicecenter.utils.MLogger;

import java.io.File;
import java.util.HashMap;
import java.util.Map;

public class JusticeRequest {
    private static final String CONFIG_URL = "https://cosmos-video-api.immomo.com/video/index/mulResource";
    private static String mDefaultBusiness;
    private static JusticeRequest sJusticeRequest;
    private NetworkUtil mNetworkUtil;
    private ThreadLocal<Gson> mGsonThreadLocal;

    private JusticeRequest() {
        mDefaultBusiness =
                "spam_4," +
                        "spam_1," +
                        "AntiSpam," +
                        "AntiPorn";
        mNetworkUtil = NetworkUtil.getInstance();
        mGsonThreadLocal = new ThreadLocal<Gson>() {
            @Nullable
            @Override
            protected Gson initialValue() {
                return new Gson();
            }
        };
    }

    public synchronized static JusticeRequest getInstance() {
        if (sJusticeRequest == null) {
            sJusticeRequest = new JusticeRequest();
        }
        return sJusticeRequest;
    }

    public interface OnConfigRequestListener {
        void onSuccess(Map<String, Map<String, ResourceConfig>> config);

        void onFailed(int code, String msg);
    }

    public interface OnDownloadListener {
        void onSuccess(File file);

        void onProgress(int progress);

        void onFailed(int code, String msg);
    }

    public void configRequst(final OnConfigRequestListener listener) {
        Map<String, String> map = new HashMap<>();
//        map.put("resourceName", String.valueOf(JusticeCenter.SDK_VERSION_CODE));
        map.put("resourceMark", mDefaultBusiness);
        map.put("appId", String.valueOf(JusticeCenter.getAPPID()));
        mNetworkUtil.request(CONFIG_URL, map, new OnRequestCallback() {
            @Override
            public void onSuccess(String resultStr) {
                Gson gson = mGsonThreadLocal.get();
                if (gson != null) {
                    try {
                        Map<String, Map<String, ResourceConfig>> resourceConfig = gson.fromJson(resultStr,
                                new TypeToken<Map<String, Map<String, ResourceConfig>>>() {
                                }.getType());
                        listener.onSuccess(resourceConfig);
                    } catch (Exception e) {
                        listener.onFailed(-1, "解析失败");
                    }
                }
            }

            @Override
            public void onFailed(int code, String msg) {
                listener.onFailed(-2, msg);
            }
        });
    }

    public void download(String url, String targetFilePath, final OnDownloadListener listener) {
        mNetworkUtil.download(url, targetFilePath, new OnDownloadCallback() {
            @Override
            public void onSuccess(File desFile) {

                if (listener != null) {
                    listener.onSuccess(desFile);
                }
            }

            @Override
            public void onProgrogress(int progress) {
                if (listener != null) {
                    listener.onProgress(progress);
                }
            }

            @Override
            public void onFailed(String error) {
                if (listener != null) {
                    listener.onFailed(-1, error);
                }
            }
        });
    }

}
