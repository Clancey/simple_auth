import 'package:simple_auth/simple_auth.dart';

class OAuthResponse implements JsonSerializable {
  String tokenType;
  int expiresIn;
  String refreshToken;
  String accessToken;
  String idToken;
  String error;
  String errorDescription;

  OAuthResponse(this.tokenType, this.expiresIn, this.refreshToken,
      this.accessToken, this.idToken,
      {this.error, this.errorDescription});

  @override
  Map<String, dynamic> toJson() => {
        "token_type": tokenType,
        "expires_in": expiresIn,
        "refresh_token": refreshToken,
        "access_token": accessToken,
        "id_token": idToken,
        error?.isEmpty ?? true ? null : "error": error,
        errorDescription?.isEmpty ?? true ? null : "error_description":
            errorDescription,
      };

  factory OAuthResponse.fromJson(Map<String, dynamic> json) => OAuthResponse(
      json["token_type"],
      json.containsKey("expires_in")
          ? json["expires_in"] is int
              ? json["expires_in"]
              : int.parse(json["expires_in"])
          : 3600, 
      json["refresh_token"],
      json["access_token"],
      json["id_token"],
      error: json["error"],
      errorDescription: json["error_description"]);
}
