import 'dart:convert';

import "package:simple_auth/simple_auth.dart";
import "package:http/http.dart" as http;
import "dart:async";

class BasicAuthAuthenticator extends Authenticator {
  String loginUrl;
  http.Client client;
  BasicAuthAuthenticator(this.client, this.loginUrl);

  Future<bool> verifyCredentials(String username, String password) async {
    try {
      if (username?.isEmpty ?? true) throw new Exception("Invalid Username");
      if (password?.isEmpty ?? true) throw new Exception("Invalid Password");
      var key = base64.encode(utf8.encode("$username:$password"));
      var req =
          await http.get(loginUrl, headers: {"Authorization": "Basic $key"});
      var success = req.statusCode >= 200 && req.statusCode < 300;
      if (!success) return false;
      foundAuthCode(key);
      return true;
    } catch (e) {
      return false;
    }
  }
}
