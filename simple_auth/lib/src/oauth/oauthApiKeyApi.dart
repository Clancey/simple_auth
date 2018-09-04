import "dart:async";

import "package:simple_auth/simple_auth.dart";
import "package:http/http.dart" as http;

class OAuthApiKeyApi extends OAuthApi {
  AuthLocation authLocation;
  String apiKey;
  String authKey;
  OAuthApiKeyApi(
      String identifier,
      this.apiKey,
      this.authKey,
      this.authLocation,
      String clientId,
      String clientSecret,
      String tokenUrl,
      String authorizationUrl,
      String redirectUrl,
      {List<String> scopes,
      http.Client client,
      Converter converter,
      AuthStorage authStorage})
      : super(identifier, clientId, clientSecret, tokenUrl, authorizationUrl,
            redirectUrl,
            client: client,
            scopes: scopes,
            converter: converter,
            authStorage: authStorage) {}
  @override
  Future<Request> interceptRequest(Request request) async {
    Request req = request;
    if (authLocation == AuthLocation.header) {
      Map<String, String> map = new Map.from(request.headers);
      map[authKey] = apiKey;
      req = request.replace(headers: map);
    } else {
      Map<String, dynamic> map = new Map.from(request.parameters);
      map[authKey] = apiKey;
      req = request.replace(parameters: map);
    }
    if (req.authenticated) {
      await verifyCredentials();
      req = await authenticateRequest(request);
    }
    return super.interceptRequest(req);
  }
}
