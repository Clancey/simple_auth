import 'dart:async';

import "package:http/http.dart" as http;
import 'package:simple_auth/simple_auth.dart';

class AzureADV2Api extends OAuthApi {
  bool useClientSecret;

  AzureADV2Api(String identifier, String clientId, String clientSecret,
      String tokenUrl, String authorizationUrl, String redirectUrl,
      {List<String> scopes,
      http.Client client,
      Converter converter,
      AuthStorage authStorage})
      : super.fromIdAndSecret(identifier, clientId, clientSecret,
            client: client,
            scopes: scopes,
            converter: converter,
            authStorage: authStorage) {
    this.tokenUrl = tokenUrl;
    this.authorizationUrl = authorizationUrl;
    this.redirectUrl = redirectUrl;
    this.forceRefresh = true;
    this.scopes = scopes ?? ["basic"];
    useClientSecret = clientSecret != "native";
  }

  Authenticator getAuthenticator() => AzureADV2Authenticator(
      identifier,
      clientId,
      clientSecret,
      tokenUrl,
      authorizationUrl,
      redirectUrl,
      useClientSecret,
      scopes);

  @override
  Future<Map<String, String>> getRefreshTokenPostData(Account account) async {
    var map = await super.getRefreshTokenPostData(account);
    if (!useClientSecret && map.containsKey("client_secret")) {
      map.remove("client_secret");
    }
    return map;
  }
}

class AzureADV2Authenticator extends OAuthAuthenticator {
  bool useClientSecret;

  AzureADV2Authenticator(
      String identifier,
      String clientId,
      String clientSecret,
      String tokenUrl,
      String baseUrl,
      String redirectUrl,
      this.useClientSecret,
      List<String> scopes)
      : super(identifier, clientId, clientSecret, tokenUrl, baseUrl,
            redirectUrl) {
    this.scope = scopes;
    this.authCodeKey = "code";
    useEmbeddedBrowser = false;
    useNonce = true;
  }

  @override
  bool checkUrl(Uri url) {
    Uri _redirectUri = Uri.parse(redirectUrl);
    try {
      if (url?.host != _redirectUri.host) return false;
      var params = splitFragment(url.fragment);
      if (params.isEmpty ?? true) return false;
      if (!params.containsKey(authCodeKey)) return false;
      var code = params[authCodeKey];
      foundAuthCode(code);
      return true;
    } catch (exception) {
      print(exception);
      return false;
    }
  }

  Map<String, String> splitFragment(String fragment) {
    List<String> params = fragment.split("&");
    var result = Map<String, String>();
    params.forEach((param) {
      final split = param.split("=");
      result[split[0]] = split[1];
    });
    return result;
  }

  @override
  Future<Map<String, dynamic>> getInitialUrlQueryParameters() async {
    this.nonce = generateNonce(8);
    var map = await super.getInitialUrlQueryParameters();
    map['response_type'] = "id_token code";
    map["display"] = "touch";

    if (!useClientSecret && map.containsKey("client_secret")) {
      map.remove("client_secret");
    }
    return map;
  }

  @override
  Future<Map<String, dynamic>> getTokenPostData(String clientSecret) async {
    var map = await super.getTokenPostData(clientSecret);
    map.remove("client_secret");
    return map;
  }
}
