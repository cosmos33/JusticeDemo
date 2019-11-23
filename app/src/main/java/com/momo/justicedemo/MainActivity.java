package com.momo.justicedemo;

import android.Manifest;
import android.support.v4.app.ActivityCompat;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;

import com.momo.justicecenter.JusticeCenter;
import com.momo.justicecenter.resource.ResResult;
import com.momo.justicecenter.resource.ResourceManager;
import com.momo.justicecenter.utils.MLogger;
import com.momo.justicecenter.utils.SDKUtils;

import java.io.File;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

public class MainActivity extends AppCompatActivity {

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
        JusticeCenter.preload(business, new ResourceManager.OnResourceLoadedListener() {
            @Override
            public void onResourceLoadResult(Map<String, ResResult> result) {

            }
        });
    }
}
