import 'package:simple_auth/simple_auth.dart';
import "package:http/http.dart" as http;
import 'dart:async';

class MicrosoftLiveConnectApi extends OAuthApi {
  MicrosoftLiveConnectApi(String identifier, String clientId,
      String clientSecret, String redirectUrl,
      {List<String> scopes,
      http.Client client,
      Converter converter,
      AuthStorage authStorage})
      : super.fromIdAndSecret(identifier, clientId, clientSecret,
            client: client,
            scopes: scopes,
            converter: converter,
            authStorage: authStorage) {
    this.tokenUrl = "https://login.live.com/oauth20_token.srf";
    this.authorizationUrl = "https://api.instagram.com/oauth/authorize";
    this.redirectUrl = redirectUrl;
    this.scopes = scopes ?? ["basic"];
  }

  Authenticator getAuthenticator() => MicrosoftLiveConnectAuthenticator(
      identifier,
      clientId,
      clientSecret,
      tokenUrl,
      authorizationUrl,
      redirectUrl,
      scopes);
}

class MicrosoftLiveConnectAuthenticator extends OAuthAuthenticator {
  MicrosoftLiveConnectAuthenticator(
      String identifier,
      String clientId,
      String clientSecret,
      String tokenUrl,
      String baseUrl,
      String redirectUrl,
      List<String> scopes)
      : super(identifier, clientId, clientSecret, tokenUrl, baseUrl,
            redirectUrl) {
    this.scope = scopes;
  }
  @override
  Future<Map<String, dynamic>> getInitialUrlQueryParameters() async {
    var map = await super.getInitialUrlQueryParameters();
    map["display"] = "touch";
    return map;
  }
}
