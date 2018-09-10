import 'package:simple_auth/simple_auth.dart';
import "package:http/http.dart" as http;

class LinkedInApi extends OAuthApi {
  LinkedInApi(String identifier, String clientId, String clientSecret,
      String redirectUrl,
      {List<String> scopes,
      http.Client client,
      Converter converter,
      AuthStorage authStorage})
      : super(
            identifier,
            clientId,
            clientSecret,
            "https://www.linkedin.com/uas/oauth2/accessToken",
            "https://www.linkedin.com/uas/oauth2/authorization",
            redirectUrl,
            client: client,
            scopes: scopes ?? ["r_basicprofile"],
            converter: converter,
            authStorage: authStorage) {
    this.baseUrl = "https://api.linkedin.com/v1/";
  }
}
