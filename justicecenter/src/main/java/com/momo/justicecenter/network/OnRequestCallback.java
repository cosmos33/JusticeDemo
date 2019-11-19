package com.momo.justicecenter.network;

import com.momo.justicecenter.config.ResourceConfig;

public interface OnRequestCallback {
    void onSuccess(String resultStr);

    void onFailed(int code, String msg);
}
