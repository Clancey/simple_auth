import 'package:simple_auth/simple_auth.dart';
import "package:http/http.dart" as http;

class GithubApi extends OAuthApi {
  GithubApi(String identifier, String clientId, String clientSecret,
      String redirectUrl,
      {List<String> scopes,
      http.Client client,
      Converter converter,
      AuthStorage authStorage})
      : super(
            identifier,
            clientId,
            clientSecret,
            "https://github.com/login/oauth/access_token",
            "https://github.com/login/oauth/authorize",
            redirectUrl,
            client: client,
            scopes: scopes,
            converter: converter,
            authStorage: authStorage) {}
}
