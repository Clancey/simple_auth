import 'dart:async';

import 'package:simple_auth/simple_auth.dart';
import "package:http/http.dart" as http;
import "dart:convert" as Convert;

class GoogleApi extends OAuthApi {
  bool isUsingNative;
  GoogleApi(String identifier, String clientId, String redirectUrl,
      {String clientSecret = "native",
      List<String> scopes,
      http.Client client,
      Converter converter,
      AuthStorage authStorage})
      : super.fromIdAndSecret(
            identifier, _cleanseClientId(clientId), clientSecret,
            client: client,
            scopes: scopes,
            converter: converter,
            authStorage: authStorage) {
    this.tokenUrl = "https://accounts.google.com/o/oauth2/token";
    this.authorizationUrl = "https://accounts.google.com/o/oauth2/auth";
    this.redirectUrl = redirectUrl;
    this.scopes = scopes ??
        [
          "https://www.googleapis.com/auth/userinfo.email",
          "https://www.googleapis.com/auth/userinfo.profile"
        ];
  }

  static String _cleanseClientId(String clientid) =>
      clientid.replaceAll(".apps.googleusercontent.com", "");
  static String getGoogleClientId(String clientId) =>
      "${_cleanseClientId(clientId)}.apps.googleusercontent.com";
  @override
  Authenticator getAuthenticator() => GoogleAuthenticator(identifier, clientId,
      clientSecret, tokenUrl, authorizationUrl, redirectUrl, scopes);

  /// Makes an API call to google to get the users profile.
  Future<GoogleUser> getUserProfile() async {
    var request = new Request(HttpMethod.Get,
        "https://www.googleapis.com/oauth2/v1/userinfo?alt=json");
    var resp = await send(request);
    var json = Convert.jsonDecode(resp.body);
    return GoogleUser.fromJson(json);
  }
}

class GoogleAuthenticator extends OAuthAuthenticator {
  GoogleAuthenticator(String identifier, String clientId, String clientSecret,
      String tokenUrl, String baseUrl, String redirectUrl, List<String> scopes)
      : super(identifier, clientId, clientSecret, tokenUrl, baseUrl,
            redirectUrl) {
    this.scope = scopes;
    useEmbeddedBrowser = false;
    usePkce = true;
  }

  @override
  String get redirectUrl {
    var url = getRedirectUrl();
    if (url != super.redirectUrl) super.redirectUrl = url;
    return url;
  }

  String getRedirectUrl() {
    if (!useEmbeddedBrowser)
      return "com.googleusercontent.apps.${this.clientId}:/oauthredirect";
    return super.redirectUrl;
  }

  @override
  Future<Map<String, dynamic>> getInitialUrlQueryParameters() async {
    var map = await super.getInitialUrlQueryParameters();
    map["access_type"] = "offline";
    map["client_id"] = GoogleApi.getGoogleClientId(clientId);
    map["redirect_uri"] = getRedirectUrl();
    return map;
  }
}

class GoogleApiKeyApi extends GoogleApi {
  AuthLocation authLocation;
  String apiKey;
  String authKey;
  GoogleApiKeyApi(
      String identifier, this.apiKey, String clientId, String redirectUrl,
      {this.authKey = "key",
      this.authLocation = AuthLocation.query,
      String clientSecret = "native",
      List<String> scopes,
      http.Client client,
      Converter converter,
      AuthStorage authStorage})
      : super(identifier, clientId, redirectUrl,
            clientSecret: clientSecret,
            client: client,
            scopes: scopes,
            converter: converter,
            authStorage: authStorage) {}
  @override
  Future<Request> interceptRequest(Request request) async {
    Request req = request;
    if (authLocation == AuthLocation.header) {
      Map<String, String> map = new Map.from(request.headers);
      map[authKey] = apiKey;
      req = request.replace(headers: map);
    } else {
      Map<String, dynamic> map = new Map.from(request.parameters);
      map[authKey] = apiKey;
      req = request.replace(parameters: map);
    }
    if (req.authenticated) {
      await verifyCredentials();
      req = await authenticateRequest(request);
    }
    return super.interceptRequest(req);
  }
}

class GoogleUser implements JsonSerializable {
  String id;
  String email;
  bool verifiedEmail;
  String name;
  String givenName;
  String familyName;
  String link;
  String picture;
  String gender;
  String locale;
  GoogleUser(
      {this.id,
      this.email,
      this.verifiedEmail,
      this.name,
      this.givenName,
      this.familyName,
      this.link,
      this.picture,
      this.gender,
      this.locale});
  factory GoogleUser.fromJson(Map<String, dynamic> json) => new GoogleUser(
      id: json["id"],
      email: json["email"],
      verifiedEmail: json["verified_email"],
      name: json["name"],
      givenName: json["given_name"],
      familyName: json["family_name"],
      link: json["link"],
      picture: json["picture"],
      gender: json["gender"],
      locale: json["locale"]);

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "email": email,
        "verified_email": verifiedEmail,
        "name": name,
        "given_name": givenName,
        "family_name": familyName,
        "link": link,
        "picture": picture,
        "gender": gender,
        "locale": locale
      };
}
