package clancey.simpleauth.simpleauthflutter;

import android.app.Application;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import androidx.browser.customtabs.CustomTabsIntent;

import java.util.HashMap;
import java.util.Map;

public class CustomTabsAuthenticator {


    static ActivityLifecycleCallbackManager activityLifecyleManager;
    public static void Setup(Application app)
    {
        if(activityLifecyleManager == null)
        {
            activityLifecyleManager = new ActivityLifecycleCallbackManager();
            app.registerActivityLifecycleCallbacks(activityLifecyleManager);
        }
    }


    static HashMap<String,WebAuthenticator> Authenticators = new HashMap<>();
    public static void presentAuthenticator(Context context, WebAuthenticator authenticator)
    {
        final String scheme = authenticator.redirectUrl.getScheme().toLowerCase();
        Authenticators.put(scheme,authenticator);
        authenticator.addListener(authenticator.new CompleteNotifier(){
            @Override
            public void onComplete() {
                Authenticators.remove(scheme);
            }
        });

        final CustomTabsIntent.Builder builder = new CustomTabsIntent.Builder();
        builder.setInstantAppsEnabled(true);
        CustomTabsIntent intent = builder.build();
        final Uri uri =  Uri.parse(authenticator.initialUrl);

        intent.intent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP | Intent.FLAG_ACTIVITY_NO_HISTORY | Intent.FLAG_ACTIVITY_NEW_TASK);
        Intent keepAliveIntent = new Intent().setClassName(
                context.getPackageName(), KeepAliveService.class.getCanonicalName());
        intent.intent.putExtra("android.support.customtabs.extra.KEEP_ALIVE", keepAliveIntent);
        CustomTabActivityHelper.openCustomTab(context, intent, uri,
                new CustomTabActivityHelper.CustomTabFallback() {
                    @Override
                    public void openUri(Context activity, Uri uri) {
                        Intent intent = new Intent(Intent.ACTION_VIEW, uri);
                        activity.startActivity(intent);
                    }
                });
    }

    public static void onActivityResult(Intent intent) {
        if(intent == null || intent.getData() == null)
            return;
        Uri uri = intent.getData();
        String scheme = uri.getScheme();
        if(scheme != null)
            scheme = scheme.toLowerCase();
        if(!Authenticators.containsKey(scheme))
            return;
        WebAuthenticator authenticator = Authenticators.get(scheme);
        authenticator.checkUrl(uri.toString(),true);
    }

    public static void onResume() {
        for(Map.Entry<String, WebAuthenticator> entry : Authenticators.entrySet()) {
            String key = entry.getKey();
            WebAuthenticator value = entry.getValue();
            value.cancel();
        }
        Authenticators.clear();
    }
}
