import "dart:async";
import 'dart:math';
import "package:simple_auth/simple_auth.dart";
import "package:simple_auth/src/utils.dart";

abstract class WebAuthenticator extends Authenticator {
  String clientId;
  String baseUrl;
  String nonce;
  bool useNonce = false;
  int nonceLength = 8;
  String _redirectUrl;
  String get redirectUrl => _redirectUrl;
  bool useEmbeddedBrowser = false;
  set redirectUrl(String value) {
    this._redirectUrl = value;
    if (value?.isNotEmpty ?? false)
      _redirectUri = Uri.parse(value);
    else
      _redirectUri = null;
  }

  Uri _redirectUri;
  String authCodeKey = "code";
  List<String> scope = List<String>();

  /// This will check if the current URL has authentication tokens.
  bool checkUrl(Uri url) {
    try {
      if (url?.host != _redirectUri.host) return false;
      if (url?.query?.isEmpty ?? true) return false;
      if (!url.queryParameters.containsKey(authCodeKey)) return false;
      var code = url.queryParameters[authCodeKey];
      foundAuthCode(code);
      return true;
    } catch (exception) {
      print(exception);
      return false;
    }
  }

  ///Gets the URL that will be used for user login.
  Future<Uri> getInitialUrl() async {
    var uri = Uri.parse(baseUrl);
    var parameters = await getInitialUrlQueryParameters();
    return addParameters(uri, parameters);
  }

  ///Gets the URL Parameters that will be used for the login page.
  Future<Map<String, dynamic>> getInitialUrlQueryParameters() async {
    var data = {
      "client_id": clientId,
      "response_type": authCodeKey,
      "redirect_uri": _redirectUrl
    };
    if (useNonce) {
      data['nonce'] = nonce = generateNonce(nonceLength);
    }
    if ((scope?.length ?? 0) > 0) {
      data["scope"] = scope.join(" ");
    }
    return data;
  }

  ///Gets the data that will be posted to swap the auth code for an auth token
  Future<Map<String, dynamic>> getTokenPostData(String clientSecret) async {
    var data = {
      "grant_type": "authorization_code",
      authCodeKey: authCode,
      "client_id": clientId,
      "client_secret": clientSecret
    };
    if ((scope?.length ?? 0) > 0) {
      data["scope"] = scope.join(" ");
    }
    if (_redirectUrl?.isNotEmpty ?? false) data["redirect_uri"] = _redirectUrl;
    return data;
  }

  String generateNonce(int length) {
    var rand = new Random();
    var codeUnits = new List.generate(length, (index) {
      return rand.nextInt(33) + 89;
    });
    return new String.fromCharCodes(codeUnits);
  }
}
