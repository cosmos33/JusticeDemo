package com.momo.justicecenter.callback;

import com.immomo.justice.Justice;

import java.util.List;

public interface OnAsyncJusticeCallback {
    void onCreated(Justice justice, List<String> successBusiness);

    void onFailed(String em);
}
