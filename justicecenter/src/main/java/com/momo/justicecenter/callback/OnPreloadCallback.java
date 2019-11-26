package com.momo.justicecenter.callback;

import com.momo.justicecenter.resource.ResResult;

import java.util.Map;

public interface OnPreloadCallback {
    void onPreloadCallback(Map<String, ResResult> resultMap);
}
