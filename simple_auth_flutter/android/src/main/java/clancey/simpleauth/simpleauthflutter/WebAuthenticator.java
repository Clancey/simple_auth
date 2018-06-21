package clancey.simpleauth.simpleauthflutter;

import java.net.MalformedURLException;
import java.net.URL;
import java.util.Dictionary;
import java.util.HashMap;

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
    public void checkUrl(URL url, final boolean forceComplete)
    {
        final String uri = url.toString();
        eventSink.success( new HashMap<String, String>() {{
            put("identifier",identifier);
            put("url",uri);
            put("forceComplete", forceComplete ? "true":"false");

        }});
    }
    public void foundToken()
    {
        isCompleted = true;
        //TODO: proxy completed!
    }

    public void cancel()
    {
        eventSink.success( new HashMap<String, String>() {{
            put("identifier",identifier);
            put("url","canceled");
        }});
    }

    public void failed(final String error)
    {
        eventSink.success( new HashMap<String, String>() {{
            put("identifier",identifier);
            put("url","error");
            put("description", error);
            put("forceComplete", "true");
        }});
    }
}
