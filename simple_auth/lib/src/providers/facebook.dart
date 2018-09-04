import 'dart:async';

import 'package:simple_auth/simple_auth.dart';
import "package:http/http.dart" as http;
import 'package:simple_auth/src/utils.dart';
import "dart:convert" as convert;

class FacebookApi extends OAuthApi {
  static bool isUsingNative;
  FacebookApi(String identifier, String clientId, String clientSecret,
      String redirectUrl,
      {List<String> scopes,
      http.Client client,
      Converter converter,
      AuthStorage authStorage})
      : super.fromIdAndSecret(identifier, clientId, clientSecret,
            client: client,
            scopes: scopes,
            converter: converter,
            authStorage: authStorage) {
    this.scopesRequired = false;
    this.tokenUrl = "https://graph.facebook.com/v2.3/oauth/access_token";
    this.baseUrl = "https://graph.facebook.com";
    this.authorizationUrl = "https://m.facebook.com/dialog/oauth/";
    this.redirectUrl = redirectUrl;
    this.scopes = scopes ?? ["public_profile"];
  }

  Authenticator getAuthenticator() => FacebookAuthenticator(identifier,
      clientId, clientSecret, tokenUrl, authorizationUrl, redirectUrl, scopes);

  @override
  Future<OAuthAccount> getAccountFromAuthCode(
      WebAuthenticator authenticator) async {
    var auth = authenticator as FacebookAuthenticator;
    OAuthResponse result;
    if (isUsingNative) {
      result = new OAuthResponse(
          "Bearer", auth.expiration, auth.authCode, auth.authCode, null);
    } else {
      var postData = await authenticator.getTokenPostData(clientSecret);
      var url = addParameters(Uri.parse(tokenUrl), postData);
      var resp = await this.httpClient.get(url);
      var map = convert.json.decode(resp.body);
      result = OAuthResponse.fromJson(map);
    }
    var account = OAuthAccount(identifier,
        created: DateTime.now().toUtc(),
        expiresIn: result.expiresIn,
        idToken: result.idToken,
        refreshToken: result.refreshToken,
        scope: authenticator.scope,
        tokenType: result.tokenType,
        token: result.accessToken);
    return account;
  }
}

class FacebookAuthenticator extends OAuthAuthenticator {
  Uri redirectUri;
  FacebookAuthenticator(String identifier, String clientId, String clientSecret,
      String tokenUrl, String baseUrl, String redirectUrl, List<String> scopes)
      : super(identifier, clientId, clientSecret, tokenUrl, baseUrl,
            redirectUrl) {}
  int expiration;
  @override
  Future<Map<String, dynamic>> getTokenPostData(String clientSecret) async {
    var map = {
      "redirect_uri": redirectUrl,
      "code": authCode,
      "client_id": clientId,
      "client_secret": clientSecret,
    };
    return map;
  }
}
