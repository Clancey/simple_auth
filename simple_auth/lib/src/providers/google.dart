import 'dart:async';

import 'package:simple_auth/simple_auth.dart';
import "package:http/http.dart" as http;
import 'dart:io' show Platform;

class GoogleApi extends OAuthApi {
  bool isUsingNative;
  GoogleApi(String identifier, String clientId,
      {String clientSecret = "native",
      String redirectUrl = "http://localhost",
      List<String> scopes,
      http.Client client,
      Converter converter,
      AuthStorage authStorage})
      : super.fromIdAndSecret(identifier, _cleanseClientId(clientId), clientSecret,
            client: client,
            scopes: scopes,
            converter: converter,
            authStorage: authStorage) {
    this.tokenUrl = "https://accounts.google.com/o/oauth2/token";
    this.authorizationUrl = "https://accounts.google.com/o/oauth2/auth";
    this.redirectUrl = redirectUrl;
  }


  static String _cleanseClientId(String clientid) => clientid.replaceAll(".apps.googleusercontent.com", "");
  static String getGoogleClientId(String clientId) => "${_cleanseClientId(clientId)}.apps.googleusercontent.com";
  @override
  Authenticator getAuthenticator() => GoogleAuthenticator(identifier, clientId,
      clientSecret, tokenUrl, authorizationUrl, redirectUrl, scopes);

  Future<String> getUserInfo() async {
    var request = new Request(
        HttpMethod.Get, "https://www.googleapis.com/oauth2/v1/userinfo?alt=json");
    var resp = await send(request);
    print(resp.body);
    return resp.body;
  }

}

class GoogleAuthenticator extends OAuthAuthenticator {
  GoogleAuthenticator(String identifier, String clientId, String clientSecret,
      String tokenUrl, String baseUrl, String redirectUrl, List<String> scopes)
      : super(identifier, clientId, clientSecret, tokenUrl, baseUrl,
            redirectUrl) {
    this.scope = scopes;
    useEmbeddedBrowser = false;
  }

  @override
  String get redirectUrl{
     var url = getRedirectUrl();
     if(url != super.redirectUrl)
      super.redirectUrl = url;
     return url;
  }
  String getRedirectUrl() {
    if (!useEmbeddedBrowser)
      return "com.googleusercontent.apps.${this.clientId}:/oauthredirect";
    return super.redirectUrl;
  }

  @override
  Future<Map<String, dynamic>> getInitialUrlQueryParameters() async {
    var map = await super.getInitialUrlQueryParameters();
    map["access_type"] = "offline";
    map["client_id"] = GoogleApi.getGoogleClientId(clientId);
    map["redirect_uri"] = getRedirectUrl();
    return map;
  }

  @override
  Future resetAuthenticator() {
    // TODO: implement resetAuthenticator
    return super.resetAuthenticator();
  }
}
