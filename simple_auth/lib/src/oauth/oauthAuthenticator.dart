import 'dart:async';
import "package:simple_auth/simple_auth.dart";

class OAuthAuthenticator extends WebAuthenticator {
  String clientSecret;
  String tokenUrl;
  OAuthAuthenticator(String identifier, String clientId, this.clientSecret,
      this.tokenUrl, String baseUrl, String redirectUrl) {
    this.clientId = clientId;
    this.baseUrl = baseUrl;
    this.redirectUrl = redirectUrl;
    this.identifier = identifier;
  }
  OAuthAuthenticator.empty();
  @override
  Future<Map<String, dynamic>> getTokenPostData(String clientSecret) async {
    var map = await super.getTokenPostData(clientSecret);
    map["redirect_uri"] = redirectUrl;
    return map;
  }
}
