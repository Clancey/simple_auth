package clancey.simpleauth.simpleauthflutter;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.os.PersistableBundle;
import android.webkit.CookieManager;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import java.util.HashMap;
import java.util.UUID;

public class WebAuthenticatorActivity extends Activity {
    WebView webview;
    public static String UserAgent = "";

    public static HashMap<String,WebAuthenticator> States = new HashMap<>();
    public static void presentAuthenticator(Context context, WebAuthenticator authenticator)
    {
        String stateKey = UUID.randomUUID().toString();
        WebAuthenticatorActivity.States.put(stateKey, authenticator);
        Intent i = new Intent(context, WebAuthenticatorActivity.class);
        i.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        i.putExtra("StateKey", stateKey);
        context.startActivity(i);
    }

    WebAuthenticator authenticator;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Object lastNonConfigurationInstance = getLastNonConfigurationInstance();
        if(lastNonConfigurationInstance != null && lastNonConfigurationInstance.getClass().isInstance(WebAuthenticator.class))
        {
            authenticator = (WebAuthenticator)lastNonConfigurationInstance;
        }
        Intent intent = getIntent();
        if(authenticator == null && intent.hasExtra("StateKey"))
        {
            String key = intent.getStringExtra("StateKey");
            authenticator = States.get(key);
            authenticator.addListener(authenticator.new CompleteNotifier(){
                @Override
                public void onComplete() {
                    webview.stopLoading();
                    finish();
                }
            });
            States.remove(key);
        }
        if(authenticator == null)
        {
            finish();
            return;
        }
        setTitle(authenticator.title);
        webview = new WebView(this);

        WebSettings settings = webview.getSettings();
        CookieManager.getInstance().removeAllCookies(null);
        CookieManager.getInstance().flush();
        if(UserAgent != null && !UserAgent.isEmpty())
        {
            settings.setUserAgentString(UserAgent);
            settings.setLoadWithOverviewMode(true);
        }
        settings.setJavaScriptEnabled(true);
        webview.setWebViewClient(new Client(this));
        setContentView(webview);
        if(savedInstanceState != null)
        {
            webview.restoreState(savedInstanceState);
        }
        webview.loadUrl(authenticator.initialUrl);
    }

    @Override
    public void onBackPressed() {
        finish();
        authenticator.cancel();
    }

    @Override
    public Object onRetainNonConfigurationInstance() {
        return authenticator;
    }

    @Override
    public void onSaveInstanceState(Bundle outState, PersistableBundle outPersistentState) {
        super.onSaveInstanceState(outState, outPersistentState);
        webview.saveState(outState);
    }

    class Client extends WebViewClient
    {
        private WebAuthenticatorActivity activity;

        Client(WebAuthenticatorActivity activity)
        {

            this.activity = activity;
        }

        @Override
        public void onPageStarted(WebView view, String url, Bitmap favicon) {
            activity.authenticator.checkUrl(url,false);
            //activity.webview.setEnabled(false);
        }

        @Override
        public void onPageFinished(WebView view, String url) {
            super.onPageFinished(view, url);
            //activity.webview.setEnabled(true);
            activity.authenticator.checkUrl(url,false);
        }
    }

}
