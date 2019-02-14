package clancey.simpleauth.simpleauthflutter;

import android.app.Activity;
import android.os.Bundle;

public class SimpleAuthCallbackActivity extends Activity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        CustomTabsAuthenticator.onActivityResult(getIntent());
        finish();
    }
}
