package clancey.simpleauth.simpleauthflutter;

import java.net.URI;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;


public class WebAuthenticator {

    public WebAuthenticator(MethodCall call) throws Exception
    {
        identifier = call.argument("identifier");
        initialUrl = call.argument("initialUrl").toString();
        redirectUrl = new URI(call.argument("redirectUrl").toString());
        title = call.argument("title");
        allowsCancel = Boolean.parseBoolean((String)call.argument("allowsCancel"));
        isCompleted = Boolean.parseBoolean((String)call.argument("isCompleted"));
        useEmbeddedBrowser = Boolean.parseBoolean((String)call.argument("useEmbeddedBrowser"));


    }
    public String identifier;
    public String initialUrl;
    public URI redirectUrl;
    public String title;
    public boolean allowsCancel;
    public boolean isCompleted;
    public boolean useEmbeddedBrowser;
    public EventChannel.EventSink eventSink;
    public void checkUrl(final String url, final boolean forceComplete)
    {
        eventSink.success( new HashMap<String, String>() {{
            put("identifier",identifier);
            put("url",url);
            put("forceComplete", forceComplete ? "true":"false");

        }});
    }
    List<CompleteNotifier> listeners = new ArrayList<CompleteNotifier>();
    public void foundToken()
    {
        isCompleted = true;
        for (CompleteNotifier l : listeners)
            l.onComplete();
    }

    public void addListener(CompleteNotifier listener)
    {
        listeners.add(listener);
    }

    public void clearListeners()
    {
        listeners.clear();
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
    public class CompleteNotifier
    {
        public void onComplete()
        {

        }
    }
}
