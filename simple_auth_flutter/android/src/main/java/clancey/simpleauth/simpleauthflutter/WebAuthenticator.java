package clancey.simpleauth.simpleauthflutter;

import java.net.URL;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;

public class WebAuthenticator {

    public WebAuthenticator(MethodCall call)
    {
        identifier = call.argument("identifier");
        initialUrl =  call.argument("initialUrl");
        redirectUrl = call.argument("redirectUrl");
        title = call.argument("title");
        allowsCancel = call.argument("allowsCancel");
        isCompleted = call.argument("isCompleted");
        useEmbeddedBrowser = call.argument("useEmbeddedBrowser");

    }
    public String identifier;
    public URL initialUrl;
    public URL redirectUrl;
    public String title;
    public boolean allowsCancel;
    public boolean isCompleted;
    public boolean useEmbeddedBrowser;
    public EventChannel.EventSink eventSink;
    public void checkUrl(URL url, boolean forceComplete)
    {

    }
    public void foundToken()
    {

    }

    public void cancel()
    {

    }

    public void failed(String error)
    {

    }
}
