package com.momo.justicecenter.encode;

import android.support.annotation.Keep;

@Keep
public class MMRequestEncoder {
    private String mAesKey;

    public MMRequestEncoder() {
        mAesKey = ENCUtils.random(12);
    }

    public String getAesKeyEncoded() {
        try {
            byte[] encryptedBytes = ENCUtils.RSAEncode(mAesKey.getBytes());
            return Base64.encode(encryptedBytes);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "";
    }

    public String getAesKey() {
        return mAesKey;
    }

    public String getZippedJson(String jsonParams) {
        try {
            return ENCUtils.getInstance().encrypt(Base64.encode(jsonParams.getBytes()), mAesKey);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "";
    }

    public String getUnzippedJson(String mzip) {
        try {
            return ENCUtils.getInstance().decrypt(mzip, mAesKey);
        } catch (Exception e) {
            return "";
        }
    }
}
