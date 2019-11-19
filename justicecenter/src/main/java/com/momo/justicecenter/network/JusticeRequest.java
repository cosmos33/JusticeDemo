package com.momo.justicecenter.network;

import android.support.annotation.Nullable;

import com.google.gson.Gson;
import com.momo.justicecenter.JusticeCenter;
import com.momo.justicecenter.config.ResourceConfig;

import java.util.HashMap;
import java.util.Map;

public class JusticeRequest {
    private static final String CONFIG_URL = "";
    private static JusticeRequest sJusticeRequest;
    private NetworkUtil mNetworkUtil;
    private ThreadLocal<Gson> mGsonThreadLocal;

    private JusticeRequest() {
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
        void onSuccess(ResourceConfig config);

        void onFailed(int code, String msg);
    }

    public void configRequst(final OnConfigRequestListener listener) {
        Map<String, String> map = new HashMap<>();
        map.put("sdk_version", String.valueOf(JusticeCenter.SDK_VERSION));
        mNetworkUtil.request(CONFIG_URL, map, new OnRequestCallback() {
            @Override
            public void onSuccess(String resultStr) {
                Gson gson = mGsonThreadLocal.get();
                if (gson != null) {
                    try {
                        ResourceConfig resourceConfig = gson.fromJson(resultStr, ResourceConfig.class);
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

}
