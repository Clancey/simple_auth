package clancey.simpleauth.simpleauthflutter;

import android.app.Application;
import android.content.Context;

import androidx.annotation.NonNull;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * SimpleAuthFlutterPlugin
 */
public class SimpleAuthFlutterPlugin implements FlutterPlugin, ActivityAware,MethodCallHandler,StreamHandler {

  private Context applicationContext;
  private ActivityPluginBinding activityBinding;
  private MethodChannel methodChannel;
  private EventChannel eventChannel;

  @Override
  public void onMethodCall(MethodCall call, Result result)   {
    if(call.method.equals("showAuthenticator")){
      try {
        WebAuthenticator authenticator = new WebAuthenticator(call);
        authenticator.eventSink = _eventSink;
        authenticators.put(authenticator.identifier,authenticator);

        if(authenticator.useEmbeddedBrowser) {
          WebAuthenticatorActivity.presentAuthenticator(applicationContext,authenticator);
        }
        else
        {
          CustomTabsAuthenticator.presentAuthenticator(activityBinding.getActivity(),authenticator);
        }

        result.success("success");
      }
      catch (Exception ex)
      {
        result.error(ex.getMessage(), ex.getLocalizedMessage(),ex);
      }
      return;
    }
    else if(call.method.equals("completed")) {
      String id = call.argument("identifier");
      WebAuthenticator authenticator = authenticators.get(id);
      authenticator.foundToken();
      authenticators.remove(id);
      authenticator.clearListeners();
      result.success("success");
      return;
    }

    else if(call.method.equals("getValue")) {
      String key = call.argument("key");
      try{
        result.success(AuthStorage.getValue(key));
      }
      catch (Exception ex)
      {
        result.error(ex.getMessage(), ex.getLocalizedMessage(),ex);
      }
      return;
    }
    else if(call.method.equals("saveKey")) {
      String key = call.argument("key");
      String value = call.argument("value");
      try{
        AuthStorage.setValue(key,value);}
      catch (Exception ex)
      {
        result.error(ex.getMessage(), ex.getLocalizedMessage(),ex);
      }
      result.success("success");
      return;
    }

    else if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else {
      result.notImplemented();
    }
  }

  HashMap<String,WebAuthenticator> authenticators = new HashMap<String,WebAuthenticator>();

  EventSink _eventSink;
  @Override
  public void onListen(Object o, EventSink eventSink) {
    _eventSink = eventSink;
    for(Map.Entry<String, WebAuthenticator> entry : authenticators.entrySet()) {
      String key = entry.getKey();
      WebAuthenticator value = entry.getValue();
      value.eventSink = eventSink;
    }
  }

  @Override
  public void onCancel(Object o) {
    for(Map.Entry<String, WebAuthenticator> entry : authenticators.entrySet()) {
      WebAuthenticator value = entry.getValue();
      value.eventSink = null;
    }
    _eventSink = null;
  }

  /**
   * Plugin registration.
   */

  @SuppressWarnings("deprecation")
  public static void registerWith(io.flutter.plugin.common.PluginRegistry.Registrar registrar) {
    final SimpleAuthFlutterPlugin instance = new SimpleAuthFlutterPlugin();
    instance.onAttachedToEngine(registrar.context(), registrar.messenger());
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    onAttachedToEngine(flutterPluginBinding.getApplicationContext(), flutterPluginBinding.getBinaryMessenger());
  }

  private void onAttachedToEngine(Context applicationContext, BinaryMessenger messenger) {
    this.applicationContext = applicationContext;

    AuthStorage.Context = applicationContext;

    methodChannel = new MethodChannel(messenger, "simple_auth_flutter/showAuthenticator");
    eventChannel =
            new EventChannel(messenger, "simple_auth_flutter/urlChanged");
    methodChannel.setMethodCallHandler(this);
    eventChannel.setStreamHandler(this);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    applicationContext = null;
    methodChannel.setMethodCallHandler(null);
    methodChannel = null;
    eventChannel.setStreamHandler(null);
    eventChannel = null;
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding activityPluginBinding) {
    activityBinding = activityPluginBinding;
    Application app = activityPluginBinding.getActivity().getApplication();
    CustomTabsAuthenticator.Setup(app);
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    activityBinding = null;
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding activityPluginBinding) {
    activityBinding = activityPluginBinding;
  }

  @Override
  public void onDetachedFromActivity() {
    activityBinding = null;
  }
}
