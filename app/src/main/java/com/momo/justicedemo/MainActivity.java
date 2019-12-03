package com.momo.justicedemo;

import android.Manifest;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.nfc.Tag;
import android.os.Bundle;
import android.support.v4.app.ActivityCompat;
import android.support.v7.app.AppCompatActivity;
import android.view.View;

import com.immomo.justice.Justice;
import com.momo.justicecenter.JusticeCenter;
import com.momo.justicecenter.callback.OnAsyncJusticeCallback;
import com.momo.justicecenter.callback.OnPreloadCallback;
import com.momo.justicecenter.resource.ResResult;
import com.momo.justicecenter.utils.MLogger;
import com.momo.justicecenter.utils.SDKUtils;

import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class MainActivity extends AppCompatActivity {

    private static final String TAG = "MainActivity...";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        JusticeCenter.init(getApplication(), "ed908f89453ca1793dc7da5fb32e1b30");
        ActivityCompat.requestPermissions(this, new String[]{
                Manifest.permission.WRITE_EXTERNAL_STORAGE,
                Manifest.permission.READ_EXTERNAL_STORAGE}, 1);
        MLogger.setEnable(true);
    }

    public void loadResource(View view) {
        try {
            String appSHA1 = SDKUtils.getAppSHA1();
        } catch (Exception e) {
            e.printStackTrace();
        }
        Set<String> business = new HashSet<>();
        business.add("AntiSpam");
        business.add("AntiPorn");
        JusticeCenter.preload("live", new OnPreloadCallback() {
            @Override
            public void onPreloadCallback(Map<String, ResResult> resultMap) {
                MLogger.d(TAG, "success",resultMap);
            }

            @Override
            public void onFailed(String msg) {
                MLogger.d(TAG, "onFailed", msg);

            }
        });
    }

    public void asyncConstruct(View view) {
        Set<String> businesses = new HashSet<>();
        businesses.add("AntiSpam");
        businesses.add("AntiPorn");
        JusticeCenter.asyncNewJustice("live", new OnAsyncJusticeCallback() {
            @Override
            public void onCreated(Justice justice, List<String> successBusiness) {
                Bitmap image = BitmapFactory.decodeFile("/sdcard/ht.jpg");
                String predict = justice.predict(image);
                MLogger.d(TAG, "predict result:", predict);
            }

            @Override
            public void onFailed(String em) {
                MLogger.e(TAG, "asyncConstruct", em);
            }
        });
    }

    public void clearCache(View view) {
        JusticeCenter.clearCache();
    }
}
