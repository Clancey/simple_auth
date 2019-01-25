import 'package:simple_auth/simple_auth.dart';
import "package:http/http.dart" as http;

class InstagramApi extends OAuthApi {
  InstagramApi(String identifier, String clientId, String clientSecret,
      String redirectUrl,
      {List<String> scopes,
      http.Client client,
      Converter converter,
      AuthStorage authStorage})
      : super(
            identifier,
            clientId,
            clientSecret,
            "https://api.instagram.com/oauth/access_token",
            "https://api.instagram.com/oauth/authorize",
            redirectUrl,
            client: client,
            scopes: scopes,
            converter: converter,
            authStorage: authStorage) {
    this.scopes = scopes ?? ["basic"];
  }
  @override
  Authenticator getAuthenticator() {
    var authenticator = super.getAuthenticator() as WebAuthenticator;
    authenticator.useEmbeddedBrowser = true;
    return authenticator;
  }
}
