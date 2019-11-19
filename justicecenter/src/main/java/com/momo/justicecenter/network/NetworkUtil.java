package com.momo.justicecenter.network;

import android.text.TextUtils;

import com.momo.justicecenter.utils.MLogger;

import java.io.CharArrayReader;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.FormBody;
import okhttp3.Interceptor;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;

public class NetworkUtil {
    private static final String TAG = "NET_WORK_UTIL...";
    private static NetworkUtil sNetworkUtil;
    private OkHttpClient mOkHttpClient;
    private Map<String, List<OnDownloadCallback>> mCallbackMap = new ConcurrentHashMap<>();

    /**
     * 重试拦截器
     */
    static class RetryIntercepter implements Interceptor {

        int maxRetry;//最大重试次数
        private int retryNum = 0;//假如设置为3次重试的话，则最大可能请求4次（默认1次+3次重试）

        RetryIntercepter(int maxRetry) {
            this.maxRetry = maxRetry;
        }

        @Override
        public Response intercept(Chain chain) throws IOException {
            Request request = chain.request();
            Response response = chain.proceed(request);
            while (!response.isSuccessful() && retryNum < maxRetry) {
                retryNum++;
                response = chain.proceed(request);
            }
            return response;
        }
    }

    private NetworkUtil() {
        mOkHttpClient = new OkHttpClient.Builder()
                .addInterceptor(new RetryIntercepter(3))//重试
                .build();
    }

    public synchronized static NetworkUtil getInstance() {
        if (sNetworkUtil == null) {
            sNetworkUtil = new NetworkUtil();
        }
        return sNetworkUtil;
    }

    public void request(String url, Map<String, String> params, final OnRequestCallback callback) {
        FormBody.Builder builder = new FormBody.Builder();
        if (params != null) {
            for (Map.Entry<String, String> entry : params.entrySet()) {
                builder.add(entry.getKey(), entry.getValue());
            }
        }
        Request request = new Request.Builder().post(builder.build()).url(url).build();

        mOkHttpClient.newCall(request).enqueue(new Callback() {
            @Override
            public void onFailure(Call call, IOException e) {
                if (callback != null) {
                    callback.onFailed(-1, e.getLocalizedMessage());
                }
            }

            @Override
            public void onResponse(Call call, Response response) {
                try {
                    byte[] result = response.body().bytes();
                    String resultStr = new String(result, "UTF-8");
                    callback.onSuccess(resultStr);
                } catch (Exception e) {
                    callback.onFailed(-2, e.getLocalizedMessage());
                }

            }
        });
    }

    public void download(final String url, Map<String, String> params, final String savePath, final OnDownloadCallback callback) {
        if (hasTask(url, callback)) {
            return;
        }
        FormBody.Builder builder = new FormBody.Builder();
        if (params != null) {
            for (Map.Entry<String, String> entry : params.entrySet()) {
                builder.add(entry.getKey(), entry.getValue());
            }
        }
        Request request = new Request.Builder().post(builder.build()).url(url).build();
        mOkHttpClient.newCall(request).enqueue(new Callback() {
            @Override
            public void onFailure(Call call, IOException e) {
                // 下载失败
                errorCallback(url, "onFailure，error:" + (e == null ? "null" : e.getLocalizedMessage()));
            }

            @Override
            public void onResponse(Call call, Response response) throws IOException {
                InputStream is = null;
                byte[] buf = new byte[2048];
                int len = 0;
                FileOutputStream fos = null;
                // 储存下载文件的目录
                try {
                    is = response.body().byteStream();
                    long total = response.body().contentLength();
                    File tmpFile = new File(savePath + "_tmp");
                    fos = new FileOutputStream(tmpFile);
                    long sum = 0;
                    while ((len = is.read(buf)) != -1) {
                        fos.write(buf, 0, len);
                        sum += len;
                        int progress = (int) (sum * 1.0f / total * 100);
                        // 下载中
                        progressCallback(url, progress);
                    }
                    fos.flush();
                    // 下载完成
                    File desFile = new File(savePath);
                    if (desFile.exists()) {
                        desFile.delete();
                    }
                    tmpFile.renameTo(desFile);
                    successCallback(url, desFile);
                } catch (Exception e) {
                    errorCallback(url, "onResponse ,error:" + e.getLocalizedMessage());
                } finally {
                    mCallbackMap.remove(url);
                    try {
                        if (is != null)
                            is.close();
                        if (fos != null)
                            fos.close();
                    } catch (IOException e) {
                        MLogger.e(e);
                    }
                }
            }
        });
    }

    private synchronized boolean hasTask(String taskKey, OnDownloadCallback callback) {
        List<OnDownloadCallback> onFileRequestCallbacks = mCallbackMap.get(taskKey);
        boolean hasTask = false;
        if (onFileRequestCallbacks != null) {
            if (onFileRequestCallbacks.size() > 0) {
                hasTask = true;
            }
        } else {
            onFileRequestCallbacks = new ArrayList<>();
            mCallbackMap.put(taskKey, onFileRequestCallbacks);
        }
        onFileRequestCallbacks.add(callback);
        MLogger.d(TAG, "添加一个callback,此时size（）->", onFileRequestCallbacks.size());
        return hasTask;
    }

    private synchronized void errorCallback(String taskKey, String msg) {
        List<OnDownloadCallback> onFileRequestCallbacks = mCallbackMap.get(taskKey);
        if (onFileRequestCallbacks != null) {
            for (OnDownloadCallback onFileRequestCallback : onFileRequestCallbacks) {
                onFileRequestCallback.onFailed(msg);
            }
        }
        mCallbackMap.remove(taskKey);
    }

    private void progressCallback(String taskKey, int progress) {

        List<OnDownloadCallback> onFileRequestCallbacks = mCallbackMap.get(taskKey);

        if (onFileRequestCallbacks != null) {
            for (int i = 0; i < onFileRequestCallbacks.size(); i++) {
                OnDownloadCallback onFileRequestCallback = onFileRequestCallbacks.get(i);
                onFileRequestCallback.onProgrogress(progress);
            }
        } else {
            MLogger.d(TAG, "onFileRequestCallbacks is null----");
        }
    }

    private synchronized void successCallback(String taskKey, File file) {
        List<OnDownloadCallback> onFileRequestCallbacks = mCallbackMap.get(taskKey);
        if (onFileRequestCallbacks != null) {
            for (OnDownloadCallback onFileRequestCallback : onFileRequestCallbacks) {
                onFileRequestCallback.onSuccess(file);
            }
        }
        mCallbackMap.remove(taskKey);
    }

}
