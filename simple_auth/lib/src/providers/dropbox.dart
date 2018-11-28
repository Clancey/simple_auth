import 'dart:async';

import 'package:simple_auth/simple_auth.dart';
import "package:http/http.dart" as http;

class DropboxApi extends OAuthApi {
  DropboxApi(String identifier, String clientId, String clientSecret,
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
    this.tokenUrl = "https://api.dropbox.com/oauth2/token";
    this.baseUrl = "https://api.dropbox.com";
    this.authorizationUrl = "https://www.dropbox.com/oauth2/authorize";
    this.redirectUrl = redirectUrl;
  }

  Authenticator getAuthenticator() => DropboxAuthenticator(identifier, clientId,
      clientSecret, tokenUrl, authorizationUrl, redirectUrl, scopes);

  @override
  Future<OAuthAccount> getAccountFromAuthCode(
      WebAuthenticator authenticator) async {
    var auth = authenticator as DropboxAuthenticator;
    return OAuthAccount(identifier,
        created: DateTime.now().toUtc(),
        expiresIn: -1,
        scope: authenticator.scope,
        refreshToken: auth.token,
        tokenType: auth.tokenType,
        token: auth.token);
  }
}

class DropboxAuthenticator extends OAuthAuthenticator {
  Uri redirectUri;
  DropboxAuthenticator(String identifier, String clientId, String clientSecret,
      String tokenUrl, String baseUrl, String redirectUrl, List<String> scopes)
      : super(identifier, clientId, clientSecret, tokenUrl, baseUrl,
            redirectUrl) {
    authCodeKey = "access_token";
    redirectUri = Uri.parse(redirectUrl);
  }
  String token;
  String tokenType;
  String state;
  String uid;
  bool checkUrl(Uri url) {
    try {
      /*
       * If dropbox uses fragments instead of query parameters then swap convert
       * them to parameters so it is easier to parse. This also allows us to use
       * parameters if they don't use fragments.
       */
      if (url.hasFragment && !url.hasQuery) {
        url = url.replace(query: url.fragment);
      }

      if (url?.host != redirectUri.host) return false;
      if (url?.query?.isEmpty ?? true) return false;
      if (!url.queryParameters.containsKey(authCodeKey)) return false;
      var code = url.queryParameters[authCodeKey];
      if (code?.isEmpty ?? true) return false;
      token = code;
      tokenType = url.queryParameters["token_type"] == 'bearer'
          ? 'Bearer'
          : url.queryParameters["token_type"];
      uid = url.queryParameters["uid"];
      foundAuthCode(code);
      return true;
    } catch (exception) {
      print(exception);
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> getInitialUrlQueryParameters() async {
    var data = {
      "client_id": clientId,
      "response_type": "token",
      "redirect_uri": redirectUrl,
    };

    if (state?.isNotEmpty ?? false) {
      data["state"] = state;
    }
    return data;
  }
}
