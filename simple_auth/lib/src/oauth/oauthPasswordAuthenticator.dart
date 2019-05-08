import 'dart:convert';

import "package:simple_auth/simple_auth.dart";
import "package:http/http.dart" as http;
import "dart:async";

class OauthPasswordAuthenticator extends OAuthAuthenticator {
  String loginUrl;
  AuthTokenClass token;

  OauthPasswordAuthenticator(String identifier, String clientId, String clientSecret,
      this.loginUrl, tokenUrl, String baseUrl, String redirectUrl, List<String> scopes)
      : super(identifier, clientId, clientSecret, tokenUrl, baseUrl,
            redirectUrl) {}

  Future<bool> verifyCredentials(String username, String password) async {
    try {
      if (username?.isEmpty ?? true) throw new Exception("Invalid Username");
      if (password?.isEmpty ?? true) throw new Exception("Invalid Password");

      Map<String, dynamic> body = {
        'username': username,
        'password': password,
        'grant_type': "password"
      };

      var headers = {'Content-Type' : 'application/x-www-form-urlencoded'};
      var req = await http.post(loginUrl, body: body , headers: headers,encoding: Encoding.getByName("utf-8"));
      
      var success = req.statusCode >= 200 && req.statusCode < 300;
      if (!success) return false;

      
      var token = new AuthTokenClass.fromJson(json.decode(req.body));
        if(token.accessToken?.isNotEmpty ?? false) {
        this.token = token;
        foundAuthCode(token.accessToken);
        return true;      
      }
      return false;
      
    } catch (e) {
      return false;
    }
  }


    ///Gets the data that will be posted to swap the auth code for an auth token
  Future<Map<String, dynamic>> getTokenPostData(String clientSecret) async {
    var data = {
      "grant_type": "password",
      "client_id": clientId,
      "client_secret": clientSecret
    };
    return data;
  }
}

class AuthTokenClass {
  String accessToken;
  String refreshToken;
  String tokenType;
  int expiresIn;

  AuthTokenClass({this.accessToken,this.refreshToken,this.tokenType,this.expiresIn});

  factory AuthTokenClass.fromJson(Map<String,dynamic> json) {
    return AuthTokenClass(
      accessToken : json['access_token'],
      refreshToken : json['refresh_token'],
      tokenType: json['token_type'],
      expiresIn: json['expires_in'],
    );
  }
}
