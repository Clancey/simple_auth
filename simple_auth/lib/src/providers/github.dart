import 'package:simple_auth/simple_auth.dart';
import "package:http/http.dart" as http;

class GithubApi extends OAuthApi {
  GithubApi(String identifier, String clientId, String clientSecret,String redirectUrl,
      {List<String> scopes,
      http.Client client,
      Converter converter,
      AuthStorage authStorage})
      : super.fromIdAndSecret(identifier, clientId, clientSecret,
            client: client,
            scopes: scopes,
            converter: converter,
            authStorage: authStorage) {
    this.tokenUrl = "https://github.com/login/oauth/access_token";
    this.authorizationUrl = "https://github.com/login/oauth/authorize";
    this.redirectUrl = redirectUrl;
  }
}
