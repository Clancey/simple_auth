package clancey.simpleauth.simpleauthflutter;

import java.util.Dictionary;

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
import java.util.Iterator;
import java.util.Set;

/**
 * SimpleAuthFlutterPlugin
 */
public class SimpleAuthFlutterPlugin implements MethodCallHandler,StreamHandler {
  /**
   * Plugin registration.
   */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "simple_auth_flutter/showAuthenticator");
    final EventChannel eventChannel =
            new EventChannel(registrar.messenger(), "simple_auth_flutter/urlChanged");
    final SimpleAuthFlutterPlugin instance = new SimpleAuthFlutterPlugin();
    channel.setMethodCallHandler(instance);
    eventChannel.setStreamHandler(instance);
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {

    if(call.method.equals("showAuthenticator")){
      WebAuthenticator authenticator = new WebAuthenticator(call);
      authenticator.eventSink = _eventSink;
      result.success("success");
      return;

    }

    if (call.method.equals("getPlatformVersion")) {
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
