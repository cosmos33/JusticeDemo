package com.momo.justicecenter.network;

import java.io.File;

public interface OnDownloadCallback {
    void onSuccess(File desFile);

    void onProgrogress(int progress);

    void onFailed(String error);

}
