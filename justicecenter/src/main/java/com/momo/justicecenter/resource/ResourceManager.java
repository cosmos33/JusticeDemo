package com.momo.justicecenter.resource;

import com.momo.justicecenter.config.ConfigManager;
import com.momo.justicecenter.config.ResourceConfig;
import com.momo.justicecenter.network.JusticeRequest;
import com.momo.justicecenter.utils.FileHelper;
import com.momo.justicecenter.utils.MLogger;
import com.momo.justicecenter.utils.NumUtil;
import com.momo.justicecenter.utils.ThreadHelper;

import java.io.File;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;


public class ResourceManager {
    private static final String TAG = "ResourceManager...";

    public interface OnResourceLoadedListener {
        void onResourceLoadResult(Map<String, Boolean> result);
    }

    public void loadResource(final Set<String> bussiness, final OnResourceLoadedListener listener) {
        final Map<String, Boolean> result = new HashMap<>();
        final int size = bussiness.size();
        for (final String b : bussiness) {
            ConfigManager.getInstance().loadConfig(new ConfigManager.OnConfigLoadedListener() {
                @Override
                public void onConfigLoaded(final Map<String, Map<String, ResourceConfig>> resourceConfig) {
                    ResourceConfig config = getBestResourceConfig(b, resourceConfig);
                    if (config == null) {
                        configFailed(b, size, result, listener);
                        return;
                    }
                    if (isLocalAvailable(b, config)) {
                        MLogger.d(TAG, b + " 配置拉取成功，使用本地素材");
                        markResult(size, result, b, true, listener);
                    } else {
                        download(b, config, size, result, listener);
                    }
                }

                @Override
                public void onConfigFailed(int code, String msg) {
                    configFailed(b, size, result, listener);
                }
            });
        }
    }

    private void configFailed(String b, int size, Map<String, Boolean> result, OnResourceLoadedListener listener) {
        if (FileHelper.isResourceAvailable(b, null)) {
            MLogger.d(TAG, b + " 配置拉取失败，使用之前版本的素材");
            markResult(size, result, b, true, listener);
        } else {
            MLogger.e(TAG, b + " 配置拉取失败，本地没有可用素材");
            markResult(size, result, b, false, listener);
        }
    }

    public synchronized void markResult(int size, Map<String, Boolean> resultMap, String business, boolean success, OnResourceLoadedListener listener) {
        resultMap.put(business, success);
        if (resultMap.size() == size) {
            if (listener != null) {
                listener.onResourceLoadResult(resultMap);
            }
        }
    }

    private void download(final String bussiness, ResourceConfig bestResourceConfig, final int size, final Map<String, Boolean> result, final OnResourceLoadedListener listener) {
        String url = bestResourceConfig.getUrl();
        final File destDir = FileHelper.getResource(bussiness, bestResourceConfig.getMaterialVersion());
        File zipFile = FileHelper.getTempZipResource(bussiness, bestResourceConfig.getMaterialVersion());
        JusticeRequest.getInstance().download(url, zipFile.getPath(), new JusticeRequest.OnDownloadListener() {
            @Override
            public void onSuccess(final File file) {
                ThreadHelper.getInstance().execute(new Runnable() {
                    @Override
                    public void run() {
                        try {
                            FileHelper.deleteFiles(destDir);
                            boolean unzipResult = FileHelper.unzip(file.getAbsolutePath(), destDir.getAbsolutePath());
                            file.delete();
                            checkLocal(bussiness, destDir);
                            MLogger.d(TAG, bussiness + " 下载成功");
                            markResult(size, result, bussiness, true, listener);
                        } catch (Exception e) {
                            markResult(size, result, bussiness, false, listener);
                        }
                    }
                });

            }

            @Override
            public void onProgress(int progress) {

            }

            @Override
            public void onFailed(int code, String msg) {
                if (FileHelper.isResourceAvailable(bussiness, null)) {
                    MLogger.d(TAG, bussiness + " 下载失败，使用本地素材");
                    markResult(size, result, bussiness, true, listener);
                } else {
                    MLogger.e(TAG, bussiness + " 下载失败，本地素材不可用");
                    markResult(size, result, bussiness, false, listener);
                }
            }
        });
    }

    /**
     * 删掉本地该业务下的其他资源
     *
     * @param bussiness 业务类型
     * @param file      当前资源
     */
    private void checkLocal(String bussiness, File file) {
        String businessDir = FileHelper.getBusinessDir(bussiness);
        File bussinessFile = new File(businessDir);
        File[] files = bussinessFile.listFiles();
        for (File f : files) {
            if (!f.getName().equals(file.getName())) {
                FileHelper.deleteFiles(f);
            }
        }
    }

    private synchronized boolean isLocalAvailable(String bussiness, ResourceConfig config) {
        if (config != null) {
            return FileHelper.isResourceAvailable(bussiness, config.getMaterialVersion());
        }
        return false;
    }

    private ResourceConfig getBestResourceConfig(String bussiness, Map<String, Map<String, ResourceConfig>> resourceConfig) {
        Map<String, ResourceConfig> map = resourceConfig.get(bussiness);
        ResourceConfig config = null;
        for (Map.Entry<String, ResourceConfig> entry : map.entrySet()) {
            if (config == null) {
                config = entry.getValue();
            } else {
                int i = NumUtil.parseInt(config.getMaterialVersion());
                int i2 = NumUtil.parseInt(entry.getValue().getMaterialVersion());
                if (i2 > i) {
                    config = entry.getValue();
                }
            }
        }
        return config;
    }

}
