import "package:simple_auth/simple_auth.dart";

class OAuthAccount extends Account {
  OAuthAccount(String identifier,
      {this.idToken,
      this.token,
      this.tokenType,
      this.refreshToken,
      this.expiresIn,
      this.created,
      List<String> scope,
      Map<String, String> userData = const {}})
      : super(identifier, userData: userData) {
    if (scope != null) {
      this.scope = scope;
    }
  }

  String tokenType = "Bearer";
  String idToken;
  String token;
  String refreshToken;
  int expiresIn;
  DateTime created;
  List<String> scope = List<String>();

  @override
  bool isValid() {
    if (token?.isEmpty ?? true) return false;
    if (expiresIn <= 0) return true;
    var expiresTime = created.add(Duration(seconds: expiresIn));
    return expiresTime.isAfter(DateTime.now().toUtc());
  }

  @override
  void invalidate() {
    super.invalidate();
    expiresIn = 1;
    token = null;
  }

  factory OAuthAccount.fromJson(Map<String, dynamic> json) =>
      OAuthAccount(json["identifier"],
          tokenType: json["tokenType"],
          idToken: json["idToken"],
          token: json["token"],
          created: DateTime.parse(json["created"]),
          expiresIn: json["expiresIn"],
          refreshToken: json["refreshToken"],
          scope: new List<String>.from(json["scope"]),
          userData: new Map<String, String>.from(json["userData"]));

  @override
  Map<String, dynamic> toJson() => {
        "identifier": identifier,
        "userData": userData,
        "idToken": idToken,
        "token": token,
        "created": created.toIso8601String(),
        "expiresIn": expiresIn,
        "refreshToken": refreshToken,
        "scope": scope,
        "tokenType": tokenType ?? "Bearer"
      };
}
