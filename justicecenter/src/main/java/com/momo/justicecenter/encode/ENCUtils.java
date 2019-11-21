package com.momo.justicecenter.encode;

import java.security.KeyFactory;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.PublicKey;
import java.security.spec.X509EncodedKeySpec;
import java.util.Random;

import javax.crypto.Cipher;
import javax.crypto.NoSuchPaddingException;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;

public class ENCUtils {
    private static final String PubKey = "MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBAKbj7WvmhEVXZbeqvMGXdMDvGlD6/Aa/MRxkhtUzdMBtB1FzUGOs77Yo7Es3cxt4HQGrioAaPXCyNC4KX1L8qdcCAwEAAQ==";
    private IvParameterSpec ivspec;
    private Cipher cipher;

    //	private byte[] iv = { 0xD, 91, 0xB, 5, 4, 0xA, 2, 0xF, 7, 11, 0x17, 6, 8, 3, 1, 0xC };
    private ENCUtils() throws NoSuchAlgorithmException, NoSuchPaddingException {
        ivspec = new IvParameterSpec("GUgemWNhGTrh6kSM".getBytes());
        cipher = Cipher.getInstance("AES/CBC/PKCS7Padding");
    }

    private static ENCUtils instance = null;

    public static ENCUtils getInstance() throws NoSuchAlgorithmException,
            NoSuchPaddingException {
        if (instance == null) {
            instance = new ENCUtils();
        }
        return instance;
    }

    public String encrypt(String text, String key) {
        try {
            SecretKeySpec keyspec = new SecretKeySpec(hash256(key), "AES");
            cipher.init(Cipher.ENCRYPT_MODE, keyspec, ivspec);
            byte[] encrypted = cipher.doFinal(text.getBytes());
            return Base64.encode(encrypted);
        } catch (Exception e) {
            return null;
        }
    }

    public String decrypt(String code, String key) throws Exception {
        if (code == null || code.length() == 0)
            throw new Exception("Empty string");

        try {
            SecretKeySpec keyspec = new SecretKeySpec(hash256(key), "AES");
            cipher.init(Cipher.DECRYPT_MODE, keyspec, ivspec);
            byte[] decrypted = cipher.doFinal(Base64.decode(code.getBytes()));
            return new String(decrypted);
        } catch (Exception e) {
            return null;
        }
    }

    private static byte[] hash256(String str) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            md.update(str.getBytes());
            return md.digest();
        } catch (Exception e) {
            return null;
        }
    }

    //加密
    public static byte[] RSAEncode(byte[] content) throws Exception {
        Cipher cipher = Cipher.getInstance("RSA/ECB/PKCS1Padding");//java默认"RSA"="RSA/ECB/PKCS1Padding"
        cipher.init(Cipher.ENCRYPT_MODE, getPublicKey(PubKey));
        return cipher.doFinal(content);
    }

    //将base64编码后的公钥字符串转成PublicKey实例
    public static PublicKey getPublicKey(String publicKey) throws Exception {
        byte[] keyBytes = Base64.decode(publicKey.getBytes());
        X509EncodedKeySpec keySpec = new X509EncodedKeySpec(keyBytes);
        KeyFactory keyFactory = KeyFactory.getInstance("RSA");
        return keyFactory.generatePublic(keySpec);
    }

    private static char[] numbersAndLetters = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ".toCharArray();
    private static Random randGen = new Random();

    public static String random(int length) {
        char[] randBuffer = new char[length];
        for (int i = 0; i < randBuffer.length; i++) {
            randBuffer[i] = numbersAndLetters[randGen.nextInt(62)];
        }
        return new String(randBuffer);
    }

}