package clancey.simpleauth.simpleauthflutter;

import java.net.MalformedURLException;
import java.net.URL;
import java.util.Dictionary;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;

public class WebAuthenticator {

    public WebAuthenticator(MethodCall call) throws MalformedURLException
    {
        identifier = call.argument("identifier");
        initialUrl = new URL(call.argument("initialUrl").toString());
        //TODO: fix this, and uncomment
        //redirectUrl = new URL(call.argument("redirectUrl").toString());
        title = call.argument("title");
        allowsCancel = Boolean.parseBoolean((String)call.argument("allowsCancel"));
        isCompleted = Boolean.parseBoolean((String)call.argument("isCompleted"));
        useEmbeddedBrowser = Boolean.parseBoolean((String)call.argument("useEmbeddedBrowser"));


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
        //eventSink.success();
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
