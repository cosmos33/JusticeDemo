package com.momo.justicecenter.utils;

import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.os.Build;
import android.text.TextUtils;

import com.momo.justicecenter.JusticeCenter;

import java.net.URLEncoder;
import java.security.MessageDigest;
import java.util.Locale;

public class SDKUtils {
    /**
     * 所有UA字段如有变更，如新增，请往最后一位加，不要随意改动其他位置
     */
    public static String getUserAgent() {
        //MomoChat/6.6.1_alpha_0315 Android/670 (Nexus 5; Android 6.0; Gapps 1; zh_CN; android; Manufacturer)
        StringBuffer sb = new StringBuffer();
        sb.append("CosmosVideo/").append(JusticeCenter.SDK_VERSION_NAME).append(" ")
                .append("Android/").append(JusticeCenter.SDK_VERSION_CODE).append(" ")
                .append("(").append(getModle() + ";").append(" ")
                .append("Android " + Build.VERSION.RELEASE + ";").append(" ")
                .append("Gapps " + (hasGoogleMap() ? 1 : 0) + ";").append(" ")
          .append(Locale.getDefault().getLanguage() + "_" + Locale.getDefault().getCountry() + ";").append(" ").append(1 + ";").append(" ").append(getManufacturer()).append(")");

        try {
            return new String(sb.toString().getBytes(), "UTF-8");
        } catch (Exception e) {
            return sb.toString();
        }
    }

    /**
     * 判断系统是否带有谷歌地图
     */
    public static boolean hasGoogleMap() {
        // return
        // getContext().getPackageManager().hasSystemFeature("com.google.android.maps.MapActivity");
        try {
            Class.forName("com.google.android.maps.MapActivity");
        } catch (Throwable e) {
            return false;
        }
        return true;
    }

    /**
     * 获得手机型号
     */
    public static String getModle() {
        if (TextUtils.isEmpty(Build.MODEL)) {
            return "unknown";
        }
        return needEncode(Build.MODEL) ? getUTF8String(Build.MODEL) : Build.MODEL;
    }

    public static String getManufacturer() {
        String manu = Build.MANUFACTURER;
        if (TextUtils.isEmpty(manu)) {
            manu = "unknow manufacturer";
        }
        return needEncode(manu) ? getUTF8String(manu) : manu;
    }

    private static String getUTF8String(String content) {
        try {
            return URLEncoder.encode(content, "UTF-8");
        } catch (Exception e) {
            return "unknown";
        }
    }

    /**
     * 是否需要编码,包含特殊字符时,需要编码
     *
     * @return
     */
    private static boolean needEncode(String content) {
        boolean needEncode = false;
        if (!TextUtils.isEmpty(content)) {
            char contents[] = content.toCharArray();
            for (char c : contents) {
                if (c <= '\u001f' || c >= '\u007f') {
                    needEncode = true;
                    break;
                }
            }
        }
        return needEncode;
    }

    public static String getAppSHA1() throws Exception {
        Context context = JusticeCenter.getContext();
        PackageInfo info = context.getPackageManager().getPackageInfo(context.getPackageName(), PackageManager.GET_SIGNATURES);
        byte[] cert = info.signatures[0].toByteArray();
        MessageDigest md = MessageDigest.getInstance("SHA1");
        byte[] publicKey = md.digest(cert);
        StringBuilder hexString = new StringBuilder();
        for (int i = 0; i < publicKey.length; i++) {
            String appendString = Integer.toHexString(0xFF&publicKey[i]).toUpperCase(Locale.US);
            if (appendString.length() == 1) {
                hexString.append("0");
            }
            hexString.append(appendString);
            hexString.append(":");
        }
        String result = hexString.toString();
        return result.substring(0, result.length() - 1);
    }

}
