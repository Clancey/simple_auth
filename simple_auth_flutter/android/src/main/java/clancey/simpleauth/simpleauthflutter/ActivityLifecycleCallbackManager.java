package clancey.simpleauth.simpleauthflutter;

import android.app.Activity;
import android.app.Application;
import android.os.Bundle;

class ActivityLifecycleCallbackManager implements Application.ActivityLifecycleCallbacks {


    public Activity CurrentActivity;
    @Override
    public void onActivityCreated(Activity activity, Bundle savedInstanceState) {
        CurrentActivity = activity;
    }

    @Override
    public void onActivityDestroyed(Activity activity) {
        if(activity == CurrentActivity)
            CurrentActivity = null;
    }

    @Override
    public void onActivityPaused(Activity activity) {

    }

    @Override
    public void onActivityResumed(Activity activity) {
        if(!(activity instanceof SimpleAuthCallbackActivity))
            CustomTabsAuthenticator.onResume();
    }

    @Override
    public void onActivitySaveInstanceState(Activity activity, Bundle outState) {

    }

    @Override
    public void onActivityStarted(Activity activity) {

    }

    @Override
    public void onActivityStopped(Activity activity) {

    }
}
