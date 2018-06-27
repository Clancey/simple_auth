import 'package:simple_auth/simple_auth.dart';
import "package:http/http.dart" as http;

class InstagramApi extends OAuthApi {
  InstagramApi(String identifier, String clientId, String clientSecret,
      {String redirectUrl = "http://localhost",
      List<String> scopes,
      http.Client client,
      Converter converter,
      AuthStorage authStorage})
      : super.fromIdAndSecret(identifier, clientId, clientSecret,
            client: client,
            scopes: scopes,
            converter: converter,
            authStorage: authStorage) {
    this.tokenUrl = "https://api.instagram.com/oauth/access_token";
    this.authorizationUrl = "https://api.instagram.com/oauth/authorize";
    this.redirectUrl = redirectUrl;
    this.scopes = scopes ?? ["basic"];
  }
}
