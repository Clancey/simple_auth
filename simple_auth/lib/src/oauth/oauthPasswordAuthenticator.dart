import 'dart:convert';

import "package:simple_auth/simple_auth.dart";
import "package:http/http.dart" as http;
import "dart:async";

class OauthPasswordAuthenticator extends Authenticator {
  String tokenUrl;
  String loginUrl;
  //http.Client client;
  String clientId;
  String clientSecret;
  OauthPasswordAuthenticator(String identifier, String clientId,
      this.clientSecret, this.tokenUrl, this.loginUrl);

  Future<bool> verifyCredentials(String username, String password) async {
    try {
      if (username?.isEmpty ?? true) throw new Exception("Invalid Username");
      if (password?.isEmpty ?? true) throw new Exception("Invalid Password");

      Map<String, String> body = {
        'username': username,
        'password': password,
        'clientId': clientId,
        'clientSecret': clientSecret,
        'grant_type': "password"
      };

      var encodedBody = json.encode(body);

      var req = await http.post(loginUrl, body: encodedBody);

      var success = req.statusCode >= 200 && req.statusCode < 300;
      if (!success) return false;

      print("----> Response Body : " + req.body.toString());

      foundAuthCode(req.body);
      return true;
    } catch (e) {
      return false;
    }
  }
}
