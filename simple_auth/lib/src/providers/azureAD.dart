import 'dart:async';
import 'package:simple_auth/simple_auth.dart';
import "package:http/http.dart" as http;

class AzureADApi extends OAuthApi {
  bool useClientSecret;
  String resource;
  AzureADApi(String identifier, String clientId, String tokenUrl, this.resource,
      String authorizationUrl, String redirectUrl,
      {String clientSecret = "native",
      List<String> scopes,
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
    useClientSecret = clientSecret != "native";
    this.scopes = scopes;
    this.scopesRequired = false;
  }
  @override
  Authenticator getAuthenticator() => AzureADAuthenticator(
      identifier,
      clientId,
      clientSecret,
      tokenUrl,
      authorizationUrl,
      redirectUrl,
      resource,
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

class AzureADAuthenticator extends OAuthAuthenticator {
  bool useClientSecret;
  String resource;
  AzureADAuthenticator(
      String identifier,
      String clientId,
      String clientSecret,
      String tokenUrl,
      String baseUrl,
      String redirectUrl,
      this.resource,
      this.useClientSecret,
      List<String> scopes)
      : super(identifier, clientId, clientSecret, tokenUrl, baseUrl,
            redirectUrl) {
    this.scope = scopes;
    useEmbeddedBrowser = useClientSecret;
  }

  @override
  Future<Map<String, dynamic>> getInitialUrlQueryParameters() async {
    var map = await super.getInitialUrlQueryParameters();
    if (!useClientSecret && map.containsKey("client_secret")) {
      map.remove("client_secret");
    }
    map["resource"] = resource;
    return map;
  }

  @override
  Future<Map<String, dynamic>> getTokenPostData(String clientSecret) async {
    var map = await super.getTokenPostData(clientSecret);
    map["redirect_uri"] = redirectUrl;
    map["response_type"] = "token id_token";
    if (!useClientSecret && map.containsKey("client_secret")) {
      map.remove("client_secret");
    }
    return map;
  }
}
