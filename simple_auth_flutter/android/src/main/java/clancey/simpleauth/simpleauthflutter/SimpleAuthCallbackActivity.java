package clancey.simpleauth.simpleauthflutter;

import android.app.Activity;
import android.os.Bundle;
import android.support.annotation.Nullable;

public class SimpleAuthCallbackActivity extends Activity {
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        CustomTabsAuthenticator.onActivityResult(getIntent());
        finish();
    }
}
