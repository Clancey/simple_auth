import 'dart:async';
import 'dart:convert';
import 'dart:math';
import "package:simple_auth/simple_auth.dart";
import 'package:crypto/crypto.dart';

class OAuthAuthenticator extends WebAuthenticator {
  String clientSecret;
  String verifier;
  bool usePkce;
  String tokenUrl;
  OAuthAuthenticator(String identifier, String clientId, this.clientSecret,
      this.tokenUrl, String baseUrl, String redirectUrl,
      [List<String> scopes, this.usePkce = false]) {
    this.clientId = clientId;
    this.baseUrl = baseUrl;
    this.redirectUrl = redirectUrl;
    this.identifier = identifier;
    this.scope = scopes ?? <String>[];
  }
  OAuthAuthenticator.empty();
  @override
  Future<Map<String, dynamic>> getTokenPostData(String clientSecret) async {
    var map = await super.getTokenPostData(clientSecret);
    map["redirect_uri"] = redirectUrl;
    if (usePkce){
      map["code_verifier"] = verifier;
    }

    return map;
  }

  @override
  Future resetAuthenticator() {
    // Generated a new code verifier at the beginning of the authorize flow
    if (usePkce){
      verifier = _generateCodeVerifier();
    }
    return super.resetAuthenticator();
  }

  @override
  Future<Map<String, dynamic>> getInitialUrlQueryParameters() async {
    var map = await super.getInitialUrlQueryParameters();
    if (usePkce) {
      map["code_challenge_method"] = "S256";
      map["code_challenge"] = _encodeVerifier(verifier);
    }
    return map;
  }

  String _generateCodeVerifier() {
    final Random _random = Random.secure();
    int length = 50;
    String text = "";
    String allowed = "-._~ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    for (var i = 0; i < length; i++) {
      text += allowed[_random.nextInt(allowed.length-1)];
    }
    return text;
  }

  String _encodeVerifier(String code) {
    Digest digest = sha256.convert(utf8.encode(code));
    String encoded = base64Url.encode(digest.bytes).split('=')[0];
    return encoded;
  }
}
