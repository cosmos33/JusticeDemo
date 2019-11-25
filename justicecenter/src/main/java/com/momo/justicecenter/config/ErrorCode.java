package com.momo.justicecenter.config;

public interface ErrorCode {
    int OK = 0;
    /**
     * config解析出错
     */
    int CONFIG_ERROR = -1;
    /**
     * 下载失败
     */
    int DOWNLOAD_ERROR = -2;
    /**
     * 文件问题可能被篡改
     */
    int FILE_ERROR = -3;
    /**
     * sd卡权限问题
     */
    int PERMISSION_ERROR = -4;
    int UNZIP_ERROR = -5;

}
