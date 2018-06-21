package clancey.simpleauth.simpleauthflutter;

import android.annotation.TargetApi;
import android.content.Context;
import android.content.SharedPreferences;
import android.os.Build;
import android.security.keystore.KeyGenParameterSpec;
import android.security.keystore.KeyProperties;
import android.util.Base64;

import javax.crypto.Cipher;
import javax.crypto.CipherInputStream;
import javax.crypto.CipherOutputStream;
import javax.crypto.KeyGenerator;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.security.Key;
import java.security.KeyStore;
import java.util.ArrayList;

public class AuthStorage {
    public static String Alias = "simpleAuthStorage";
    public static String FIXED_IV = "23fFSDF2safu";
    public static Context Context;
    static KeyStore _keyStore;
    static KeyStore GetKeyStore() throws Exception
    {
        if(_keyStore != null)
            return _keyStore;

        _keyStore = KeyStore.getInstance(AndroidKeyStore);
        _keyStore.load(null);
        return  _keyStore;
    }
    public static String getValue(String key) throws Exception
    {
        SharedPreferences sharedPreferences = Context.getSharedPreferences(Alias, Context.MODE_PRIVATE);
        String encodedString = sharedPreferences.getString(getMD5(key), null);
        if(encodedString == null || encodedString.isEmpty())
            return null;
        String decrypted = null;
        if(android.os.Build.VERSION.SDK_INT >= Build.VERSION_CODES.M)
        {
            decrypted = decryptStringM(encodedString);
        }
        else
        {
            decrypted = decryptString(encodedString);
        }
        return decrypted;
    }

    public static void setValue(String key, String value) throws Exception
    {
        String encryptedString = null;
        if(android.os.Build.VERSION.SDK_INT >= Build.VERSION_CODES.M)
        {
            encryptedString = encryptStringM(value);
        }
        else
        {
            encryptedString = encryptString(value);
        }
        SharedPreferences sharedPreferences = Context.getSharedPreferences(Alias, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();

        editor.putString(getMD5(key),encryptedString);
        editor.apply();


    }
    private static final String AndroidKeyStore = "AndroidKeyStore";
    private static final String AES_MODE = "AES/GCM/NoPadding";

    @TargetApi(Build.VERSION_CODES.M)
    private static java.security.Key getSecretKeyM() throws Exception {
        KeyStore keyStore = GetKeyStore();

        if (!keyStore.containsAlias(Alias)) {
            KeyGenerator keyGenerator = KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, AndroidKeyStore);
            keyGenerator.init(
                    new KeyGenParameterSpec.Builder(Alias,
                            KeyProperties.PURPOSE_ENCRYPT | KeyProperties.PURPOSE_DECRYPT)
                            .setBlockModes(KeyProperties.BLOCK_MODE_GCM).setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
                            .setRandomizedEncryptionRequired(false)
                            .build());
            keyGenerator.generateKey();
        }
        return keyStore.getKey(Alias, null);
    }

    @TargetApi(Build.VERSION_CODES.KITKAT)
    static String encryptStringM(String stringInput) throws Exception
    {
        Cipher c = Cipher.getInstance(AES_MODE);
        c.init(Cipher.ENCRYPT_MODE, getSecretKeyM(), new GCMParameterSpec(128, FIXED_IV.getBytes()));
        byte[] encodedBytes = c.doFinal(stringInput.getBytes());
        String encryptedBase64Encoded = Base64.encodeToString(encodedBytes, Base64.DEFAULT);
        return encryptedBase64Encoded;
    }

    @TargetApi(Build.VERSION_CODES.KITKAT)
    static String decryptStringM(String encrypted) throws Exception
    {
        Cipher c = Cipher.getInstance(AES_MODE);
        c.init(Cipher.DECRYPT_MODE, getSecretKeyM(), new GCMParameterSpec(128, FIXED_IV.getBytes()));
        byte[] decodedBytes = c.doFinal(Base64.decode(encrypted,Base64.DEFAULT));
        return new String(decodedBytes, "UTF-8");
    }


    private static final String RSA_MODE =  "RSA/ECB/PKCS1Padding";
    private static byte[] rsaEncrypt(byte[] secret) throws Exception{
        KeyStore keyStore = GetKeyStore();
        KeyStore.PrivateKeyEntry privateKeyEntry = (KeyStore.PrivateKeyEntry) keyStore.getEntry(Alias, null);
        Cipher inputCipher = Cipher.getInstance(RSA_MODE, "AndroidOpenSSL");
        inputCipher.init(Cipher.ENCRYPT_MODE, privateKeyEntry.getCertificate().getPublicKey());

        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        CipherOutputStream cipherOutputStream = new CipherOutputStream(outputStream, inputCipher);
        cipherOutputStream.write(secret);
        cipherOutputStream.close();

        byte[] vals = outputStream.toByteArray();
        return vals;
    }

    private static byte[]  rsaDecrypt(byte[] encrypted) throws Exception {
        KeyStore keyStore = GetKeyStore();
        KeyStore.PrivateKeyEntry privateKeyEntry = (KeyStore.PrivateKeyEntry)keyStore.getEntry(Alias, null);
        Cipher output = Cipher.getInstance(RSA_MODE, "AndroidOpenSSL");
        output.init(Cipher.DECRYPT_MODE, privateKeyEntry.getPrivateKey());
        CipherInputStream cipherInputStream = new CipherInputStream(
                new ByteArrayInputStream(encrypted), output);
        ArrayList<Byte> values = new ArrayList<>();
        int nextByte;
        while ((nextByte = cipherInputStream.read()) != -1) {
            values.add((byte)nextByte);
        }

        byte[] bytes = new byte[values.size()];
        for(int i = 0; i < bytes.length; i++) {
            bytes[i] = values.get(i).byteValue();
        }
        return bytes;
    }

    private static Key getSecretKey(Context context) throws Exception{
        SharedPreferences pref = context.getSharedPreferences(Alias, Context.MODE_PRIVATE);
        String enryptedKeyB64 = pref.getString(Alias, null);
        byte[] encryptedKey = Base64.decode(enryptedKeyB64, Base64.DEFAULT);
        byte[] key = rsaDecrypt(encryptedKey);
        return new SecretKeySpec(key, "AES");
    }

    public static String encryptString(String input) throws Exception {
        Cipher c = Cipher.getInstance(AES_MODE, "BC");
        c.init(Cipher.ENCRYPT_MODE, getSecretKey(Context));
        byte[] encodedBytes = c.doFinal(input.getBytes("UTF-8"));
        String encryptedBase64Encoded =  Base64.encodeToString(encodedBytes, Base64.DEFAULT);
        return encryptedBase64Encoded;
    }


    public static String decryptString(String encrypted) throws Exception {
        Cipher c = Cipher.getInstance(AES_MODE, "BC");
        c.init(Cipher.DECRYPT_MODE, getSecretKey(Context));
        byte[] decodedBytes = c.doFinal(Base64.decode(encrypted,Base64.DEFAULT));
        return new String(decodedBytes, "UTF-8");
    }

    static String getMD5(String input) {
        try {
            java.security.MessageDigest md = java.security.MessageDigest.getInstance("MD5");
            byte[] array = md.digest(input.getBytes());
            StringBuffer sb = new StringBuffer();
            for (int i = 0; i < array.length; ++i) {
                sb.append(Integer.toHexString((array[i] & 0xFF) | 0x100).substring(1,3));
            }
            return sb.toString();
        } catch (java.security.NoSuchAlgorithmException e) {
        }
        return null;
    }

}
