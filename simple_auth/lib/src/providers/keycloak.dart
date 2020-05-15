import 'dart:async';

import 'package:simple_auth/simple_auth.dart';
import "package:http/http.dart" as http;
import "dart:convert" as Convert;


class KeycloakApi extends OAuthApi {
  String realm;

  // Keycloak base url E.G., https://auth.mydomain.com
  String baseUrl;

  KeycloakApi(String identifier,
      String clientId,
      String clientSecret,
      String redirectUrl,
      String baseUrl,
      String realm,
      {
        List<String> scopes = const ["email", "profile"],
        http.Client client,
        Converter converter,
        AuthStorage authStorage
      }) : super(
      identifier,
      clientId,
      clientSecret,
      "$baseUrl/auth/realms/$realm/protocol/openid-connect/token",
      "$baseUrl/auth/realms/$realm/protocol/openid-connect/auth",
      redirectUrl,
      client: client,
      scopes: scopes,
      converter: converter,
      authStorage: authStorage) {
    this.baseUrl = baseUrl;
    this.realm = realm;
  }

  /// Makes an API call to keycloak to get the users profile.
  Future<KeycloakUser> getUserProfile() async {
    var request = new Request(HttpMethod.Get, "${this.baseUrl}/auth/realms/${this.realm}/protocol/openid-connect/userinfo");
    request = await this.authenticateRequest(request);
    var resp = await send(request);
    var json = Convert.jsonDecode(resp.body);
    return KeycloakUser.fromJson(json);
  }

  /// Log out of Keycloak session and if successful proceed to logout locally
  Future<bool> logOutAccount() async {
    OAuthAccount account = currentOauthAccount ?? await loadAccountFromCache<OAuthAccount>();
    if (account == null) throw new Exception("Invalid Account");

    var postData = await getRefreshTokenPostData(account);
    var resp = await httpClient.post("${this.baseUrl}/auth/realms/${this.realm}/protocol/openid-connect/logout",
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/x-www-form-urlencoded"
        },
        body: postData
    );

    if (resp.statusCode == 204) {
//      print('KeycloakProvider.logOutAccount Success - Performing local logOut');
      await this.logOut();
      return true;
    } else {
      // TODO: Define Error/Exception classes to distinguish between network (external) exceptions and usage (internal) errors
      print("KeycloakProvider.logOutAccount Failure - statusCode: ${resp.statusCode}, reason ${resp.reasonPhrase}");
      return false;
    }
  }

  @override
  Authenticator getAuthenticator() => KeycloakAuthenticator(identifier, clientId,
      clientSecret, tokenUrl, authorizationUrl, redirectUrl, scopes);

}

/// Extend OAuthAuthenticator to disable SSO by default
class KeycloakAuthenticator extends OAuthAuthenticator {
  KeycloakAuthenticator(String identifier, String clientId, String clientSecret, String tokenUrl, String baseUrl, String redirectUrl, List<String> scopes)
      : super(identifier, clientId, clientSecret, tokenUrl, baseUrl, redirectUrl) {
    this.scope = scopes;
    useEmbeddedBrowser = false;
    // Disable SSO to remove Apples user consent dialog
    useSSO = false;
  }
}


class KeycloakUser implements JsonSerializable {
//  https://www.keycloak.org/docs/latest/server_development/index.html#_action_token_anatomy
  String sub;

  // Email scope
  String email;
  bool emailVerified;

  // Profile scope
  String gender;
  String fullName;
  String picture;
  String birthdate;
  String website;
  String nickname;
  String lastName;
  String middleName;
  String firstName;
  String updatedAt;
  String username;
  String locale;
  String zoneinfo;

  // TODO: Phone scope
  // TODO: Roles scope
  // TODO: Address scope

  KeycloakUser(this.sub, {

    // Email scope
    this.email,
    this.emailVerified,

    // Profile scope
    this.gender,
    this.fullName,
    this.picture,
    this.birthdate,
    this.website,
    this.nickname,
    this.lastName,
    this.middleName,
    this.firstName,
    this.updatedAt,
    this.username,
    this.locale,
    this.zoneinfo,
  });

  factory KeycloakUser.fromJson(Map<String, dynamic> json) =>
      new KeycloakUser(
        json["sub"],

        // Email scope
        email: json["email"],
        emailVerified: json["email_verified"],

        // Profile scope
        gender: json["gender"],
        fullName: json["name"],
        picture: json["picture"],
        birthdate: json["birthdate"],
        website: json["website"],
        nickname: json["nickname"],
        lastName: json["family_name"],
        middleName: json["middle_name"],
        firstName: json["given_name"],
        updatedAt: json["update_at"],
        username: json["preferred_username"],
        locale: json["locale"],
        zoneinfo: json["zoneinfo"],
      );

  @override
  Map<String, dynamic> toJson() =>
      {
        "sub": sub,

        // Email scope
        "email": email,
        "emai_verified": emailVerified,

        // Profile scope
        "gender": gender,
        "name": fullName,
        "picture": picture,
        "birthdate": birthdate,
        "website": website,
        "nickname": nickname,
        "family_name": lastName,
        "middle_name": middleName,
        "given_name": firstName,
        "updated_at": updatedAt,
        "preferred_username": username,
        "locale": locale,
        "zoneinfo": zoneinfo,
      };
}
