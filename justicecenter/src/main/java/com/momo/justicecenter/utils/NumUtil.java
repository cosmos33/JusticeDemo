package com.momo.justicecenter.utils;

public class NumUtil {
    public static int parseInt(String s) {
        try {
            return Integer.parseInt(s);
        } catch (Exception e) {
            return 0;
        }
    }
}
