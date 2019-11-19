package com.momo.justicecenter.utils;

import android.util.Log;


public class MLogger {
    private static final String TAG = "JUSTICE_CENTER_";
    private static boolean enable = false;

    public static void setEnable(boolean enable) {
        MLogger.enable = enable;
    }


    public static void d(Object... args) {
        if (enable) {
            Log.i(TAG + "_debug_", appendStr(args));
        }
    }

    public static void e(Object... args) {
        Log.e(TAG + "_error_", appendStr(args));
    }

    public static void printStakeTrace(Throwable e) {
        if (enable) {
            if (e != null) {
                e.printStackTrace();
            }
        }
    }

    private static String appendStr(Object... args) {
        StringBuilder sb = new StringBuilder();
        sb.append("-");
        if (args == null) {
            sb.append("null ");
            return sb.toString();
        }

        for (Object arg : args) {
            sb.append(arg == null ? "null" : arg.toString()).append(" ");
        }
        return sb.toString();
    }
}
