package com.momo.justicecenter.utils;

import android.content.Context;
import android.os.Environment;
import android.text.TextUtils;

import com.momo.justicecenter.JusticeCenter;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

public class FileHelper {
    private static final String ROOT_PATH;
    private static final String TAG = "FileHelper...";
    /**
     * zip压缩包不合法文件名
     */
    private static final String[] INVALID_ZIP_ENTRY_NAME = new String[]{
            "../",
            "~/"
    };
    static {
        Context context = JusticeCenter.getContext();
        if (context == null) {
            throw new IllegalStateException("you should call JusticeCenter.init(context,appId) first");
        }
        ROOT_PATH = context.getFilesDir() + File.separator + "justice";
    }

    public static String getBusinessDir(String business) {
        File businessDir = new File(ROOT_PATH, business);
        if (!businessDir.exists()) {
            businessDir.mkdirs();
        }
        return businessDir.getPath();
    }

    public static String getRootPath() {
        return ROOT_PATH;
    }

    public static boolean isResourceAvailable(String business, String version) {
        File file = getResource(business, version);
        return file != null && file.exists() && file.listFiles().length > 0;
    }

    /**
     * @param version business业务下，对应的版本。如果传空，默认返回业务文件夹下的唯一文件夹
     */
    public static File getResource(String business, String version) {
        String filePathByBusiness = getBusinessDir(business);
        if (TextUtils.isEmpty(version)) {
            File file = new File(filePathByBusiness);
            if (file.exists()) {
                File[] files = file.listFiles();
                if (files != null) {
                    if (files.length == 1) {
                        if (files[0].isDirectory()) {
                            return files[0];
                        }
                    } else if (files.length >= 1){
                        for (File f : files) {
                            deleteFiles(f);
                        }
                        MLogger.e(TAG, "本地有多个版本的资源，注意检查逻辑！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！");
                    }
                }
            }
            return null;
        }
        return new File(filePathByBusiness, version);
    }

    public static void deleteFiles(File file) {
        if (file == null) {
            return;
        }
        if (file.exists()) {
            if (file.isDirectory()) {
                File[] files = file.listFiles();
                if (files != null) { //some JVMs return null for empty dirs
                    for (File f : files) {
                        deleteFiles(f);
                    }
                }
            } else {
                file.delete();
            }
        } else {
            MLogger.d(TAG, " the file to delete is not exist:" + file.getAbsolutePath());
        }
        file.delete();
    }

    public static File getTempZipResource(String bussiness, String materialVersion) {
        String businessDir = getBusinessDir(bussiness);
        File file = new File(businessDir, ".temp");
        if (!file.exists()) {
            file.mkdirs();
        }
        return new File(file, materialVersion + ".zip");
    }

    public static boolean unzip(String zipFile, String targetDir) {
        return unzip(zipFile, targetDir, false);
    }

    /**
     * @param zipFile   zip文件路径
     * @param targetDir 把zip解压的文件夹路径。意思是把zip包里的东西，放到此文件夹中
     * @param nomedia   不希望解压后的资源被系统图库等扫描到，可以设置为true，不关心则传入false
     * @return
     */
    public static boolean unzip(String zipFile, String targetDir, boolean nomedia) {
        boolean unzipSuccess;
        try {
            unzipSuccess = true;
            unzipWithExeption(zipFile, targetDir, nomedia);
        } catch (Exception e) {
            MLogger.printStakeTrace(e);
            unzipSuccess = false;
        }
        return unzipSuccess;
    }


    public static void unzipWithExeption(String zipFile, String targetDir) throws Exception {
        unzipWithExeption(zipFile, targetDir, false);
    }

    public static void unzipWithExeption(String zipFile, String targetDir, boolean nomedia) throws Exception {
        int BUFFER = 4096; //这里缓冲区我们使用4KB，
        String strEntry; //保存每个zip的条目名称
        BufferedOutputStream dest = null; //缓冲输出流
        FileInputStream fis = new FileInputStream(zipFile);
        ZipInputStream zis = new ZipInputStream(new BufferedInputStream(fis));
        ZipEntry entry; //每个zip条目的实例
        try {
            while ((entry = zis.getNextEntry()) != null) {
                int count;
                byte data[] = new byte[BUFFER];
                strEntry = entry.getName();
                if (!validEntry(strEntry))
                    throw new IllegalArgumentException("unsecurity zipfile!");
                File entryFile = new File(targetDir, strEntry);

                if (entry.isDirectory()) {
                    if (!entryFile.exists()) {
                        entryFile.mkdirs();
                    }
                    continue;
                }

                File entryDir = new File(entryFile.getParent());
                if (!entryDir.exists()) {
                    entryDir.mkdirs();
                }

                if (nomedia) {
                    //创建 .nomedia 文件，防止解压后的资源在系统相册中被看到
                    File nomeidiaFile = new File(entryDir, ".nomedia");
                    if (!nomeidiaFile.exists()) {
                        nomeidiaFile.createNewFile();
                    }
                }

                try {
                    dest = new BufferedOutputStream(new FileOutputStream(entryFile), BUFFER);
                    while ((count = zis.read(data, 0, BUFFER)) != -1) {
                        dest.write(data, 0, count);
                    }
                    dest.flush();
                } finally {
                    dest.close();
                }
            }
        } finally {
            zis.close();
        }

    }

    public static boolean validEntry(String name) {
        for (int i = 0, l = INVALID_ZIP_ENTRY_NAME.length; i < l; i++) {
            if (name.contains(INVALID_ZIP_ENTRY_NAME[i]))
                return false;
        }
        return true;
    }
}
