import "dart:async";
import "package:simple_auth/simple_auth.dart";
import "package:simple_auth/src/utils.dart";

abstract class WebAuthenticator extends Authenticator {
  String clientId;
  String baseUrl;
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

  Future<Uri> getInitialUrl() async {
    var uri = Uri.parse(baseUrl);
    var parameters = await getInitialUrlQueryParameters();
    return addParameters(uri, parameters);
  }

  Future<Map<String, dynamic>> getInitialUrlQueryParameters() async {
    var data = {
      "client_id": clientId,
      "response_type": authCodeKey,
      "redirect_uri": _redirectUrl
    };

    if ((scope?.length ?? 0) > 0) {
      data["scope"] = scope.join(" ");
    }
    return data;
  }

  Future<Map<String, dynamic>> getTokenPostData(String clientSecret) async {
    var data = {
      "grant_type": "authorization_code",
      authCodeKey: authCode,
      "client_id": clientId,
      "client_secret": clientSecret
    };

    if (_redirectUrl?.isNotEmpty ?? false) data["redirect_uri"] = _redirectUrl;
    return data;
  }
}
