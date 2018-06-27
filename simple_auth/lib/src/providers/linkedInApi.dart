import 'package:simple_auth/simple_auth.dart';
import "package:http/http.dart" as http;

class LinkedInApi extends OAuthApi {
  LinkedInApi(String identifier, String clientId, String clientSecret,
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
    this.tokenUrl = "https://www.linkedin.com/uas/oauth2/accessToken";
    this.authorizationUrl = "https://www.linkedin.com/uas/oauth2/authorization";
    this.redirectUrl = redirectUrl;
    this.baseUrl = "https://api.linkedin.com/v1/";
    this.scopes = scopes ?? ["r_basicprofile"];
  }
}
