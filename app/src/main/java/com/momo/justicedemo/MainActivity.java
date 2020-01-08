package com.momo.justicedemo;

import android.Manifest;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.support.annotation.Nullable;
import android.support.v4.app.ActivityCompat;
import android.support.v7.app.AppCompatActivity;
import android.text.TextUtils;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import com.immomo.justice.Justice;
import com.momo.justicecenter.JusticeCenter;
import com.momo.justicecenter.callback.OnAsyncJusticeCallback;
import com.momo.justicecenter.callback.OnPreloadCallback;
import com.momo.justicecenter.resource.ResResult;
import com.momo.justicecenter.utils.MLogger;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.Socket;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class MainActivity extends AppCompatActivity {

    private static final String TAG = "MainActivity...";
    private static final int RC_CHOOSE_PHOTO = 1;
    private String mCurrentSceneID;
    private TextView mImgPathTV;
    private TextView mLogTV;
    private TextView mBusinessIDTV;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        JusticeCenter.init(getApplication(), "ed908f89453ca1793dc7da5fb32e1b30");
        ActivityCompat.requestPermissions(this, new String[]{
                Manifest.permission.WRITE_EXTERNAL_STORAGE,
                Manifest.permission.READ_EXTERNAL_STORAGE}, 1);
        MLogger.setEnable(true);
        findView();
    }

    private void findView() {
        mImgPathTV = findViewById(R.id.text_img_path);
        mLogTV = findViewById(R.id.text_log);
        mBusinessIDTV = findViewById(R.id.edit_text_type_id2);

    }

    private void toast(String msg) {
        Toast.makeText(this, msg, Toast.LENGTH_SHORT).show();
    }

    public void loadResourceByScene(View view) {
        getCurrentSceneID();
        if (TextUtils.isEmpty(mCurrentSceneID)) {
            toast("场景id不可以为空");
            return;
        }
        JusticeCenter.preload(mCurrentSceneID, new OnPreloadCallback() {
            @Override
            public void onPreloadCallback(Map<String, ResResult> resultMap) {
                MLogger.d(TAG, "success", resultMap);
                StringBuilder sb = new StringBuilder();
                sb.append("场景类型").append(mCurrentSceneID).append(" preload结果：");
                for (Map.Entry<String, ResResult> stringResResultEntry : resultMap.entrySet()) {
                    sb.append(stringResResultEntry.getKey())
                            .append(":")
                            .append(stringResResultEntry.getValue())
                            .append("\n");
                }
                addToLogText(sb.toString());
            }

            @Override
            public void onFailed(String msg) {
                MLogger.d(TAG, "onFailed", msg);
                addToLogText("场景类型" + mCurrentSceneID + "预加载失败：" + msg);

            }
        });
    }

    private String getCurrentSceneID() {
        EditText et = findViewById(R.id.edit_text_type_id);
        final String text = et.getText().toString();

        mCurrentSceneID = text;
        return text;
    }

    private void addToLogText(final String msg) {

        mLogTV.post(new Runnable() {
            @Override
            public void run() {
                SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss SSS");
                String timeStr = simpleDateFormat.format(new Date());
                String log = timeStr + " \t" + msg + "\n";
                String s = mLogTV.getText().toString();
                s += log;
                mLogTV.setText(s);
            }
        });
    }

    public void loadResourceByBusinessIds(View view) {
        Set<String> businesses = new HashSet<>();
//        businesses.add("AntiSpam");
//        businesses.add("AntiPorn");
        String s = mBusinessIDTV.getText().toString();
        if (TextUtils.isEmpty(s.trim())) {
            toast("业务场景不能为空");
            return;
        }
        String[] ss = s.split(",");
        for (String s1 : ss) {
            if (!TextUtils.isEmpty(s1.trim())) {
                businesses.add(s1);
            }
        }
        if (businesses.isEmpty()) {
            toast("业务类型输入格式有误");
            return;
        }
        JusticeCenter.preload(businesses, new OnPreloadCallback() {
            @Override
            public void onPreloadCallback(Map<String, ResResult> resultMap) {
                StringBuilder sb = new StringBuilder();
                sb.append("业务类型").append(" preload结果：");
                for (Map.Entry<String, ResResult> stringResResultEntry : resultMap.entrySet()) {
                    sb.append(stringResResultEntry.getKey())
                            .append(":")
                            .append(stringResResultEntry.getValue())
                            .append("\n");
                }
                addToLogText(sb.toString());
            }

            @Override
            public void onFailed(String msg) {
                addToLogText("业务类型预加载失败：" + msg);
            }
        });
//        JusticeCenter.asyncNewJustice(businesses, new OnAsyncJusticeCallback() {
//            @Override
//            public void onCreated(Justice justice, List<String> successBusiness) {
//                Bitmap image = BitmapFactory.decodeFile("/sdcard/ht.jpg");
//                String predict = justice.predict(image);
//                MLogger.d(TAG, "predict result:", predict);
//            }
//
//            @Override
//            public void onFailed(String em) {
//                MLogger.e(TAG, "loadResourceByBusinessIds", em);
//            }
//        });
    }

    public void clearCache(View view) {
        mLogTV.setText("");
        JusticeCenter.clearCache();

    }

    public void socketTest(View view) {
        new Thread(new Runnable() {
            @Override
            public void run() {
                Socket socket = null;
                try {
                    socket = new Socket("172.16.224.128", 8888);

                    OutputStream outputStream = socket.getOutputStream();
                    MLogger.d(TAG, "客户端：写消息：");
                    Util.writeStr("我是客户端", outputStream);
                    outputStream = socket.getOutputStream();
                    MLogger.d(TAG, "客户端：写消息：");
                    Util.writeStr("我是客户端2", outputStream);
                    socket.shutdownOutput();//关闭输出流

                    InputStream inputStream = socket.getInputStream();
                    String s = Util.readStr(inputStream);
                    MLogger.d(TAG, "客户端读取到服务端返回消息：", s);
                } catch (IOException e) {
                    e.printStackTrace();
                    MLogger.e(e);
                }
            }
        }).start();
    }

    public void selectImg(View view) {
        Intent intentToPickPic = new Intent(Intent.ACTION_PICK, null);
        intentToPickPic.setDataAndType(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, "image/*");
        startActivityForResult(intentToPickPic, RC_CHOOSE_PHOTO);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == RC_CHOOSE_PHOTO) {
            if (resultCode == RESULT_OK) {
                if (data != null) {
                    Uri uri = data.getData();
                    String realPathFromUri = Util.getRealPathFromUri(this, uri);
                    toast(realPathFromUri);
                    if (!TextUtils.isEmpty(realPathFromUri)) {
                        processDetectIMG(realPathFromUri);
                    }
                } else {
                    toast("获取data失败");
                }

            }
        }
    }

    private void processDetectIMG(final String realPathFromUri) {
        mImgPathTV.setText(realPathFromUri);
        getCurrentSceneID();
        if (TextUtils.isEmpty(mCurrentSceneID)) {
            toast("场景id不可为空");
            return;
        }
        JusticeCenter.asyncNewJustice(mCurrentSceneID, new OnAsyncJusticeCallback() {
            @Override
            public void onCreated(Justice justice, List<String> successBusiness) {
                StringBuilder sb = new StringBuilder();
                sb.append(mCurrentSceneID).append(" 创建成功的业务类型有：");
                for (String business : successBusiness) {
                    sb.append(business).append(" ");
                }
                String s = sb.toString().trim();
                addToLogText(s);
                String predict = justice.predict(BitmapFactory.decodeFile(realPathFromUri));
                addToLogText(predict);
            }

            @Override
            public void onFailed(String em) {
                addToLogText("processDetectIMG onFailed：" + em);

            }
        });
    }
}
