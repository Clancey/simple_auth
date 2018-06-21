package clancey.simpleauth.simpleauthflutter;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import java.util.HashMap;
import java.util.Map;

/**
 * SimpleAuthFlutterPlugin
 */
public class SimpleAuthFlutterPlugin implements MethodCallHandler,StreamHandler {
  /**
   * Plugin registration.
   */
  public static void registerWith(Registrar registrar) {
    AuthStorage.Context = registrar.context();
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "simple_auth_flutter/showAuthenticator");
    final EventChannel eventChannel =
            new EventChannel(registrar.messenger(), "simple_auth_flutter/urlChanged");
    final SimpleAuthFlutterPlugin instance = new SimpleAuthFlutterPlugin();
    channel.setMethodCallHandler(instance);
    eventChannel.setStreamHandler(instance);
  }

  @Override
  public void onMethodCall(MethodCall call, Result result)   {

    if(call.method.equals("showAuthenticator")){
      try {
        WebAuthenticator authenticator = new WebAuthenticator(call);
        authenticator.eventSink = _eventSink;
        authenticators.put(authenticator.identifier,authenticator);
        //TODO: Show authenticator
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
}
