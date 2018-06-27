import "package:simple_auth/simple_auth.dart";

class BasicAuthAccount extends Account {
  BasicAuthAccount(String identifier,
      {this.key, Map<String, String> userData = const {}})
      : super(identifier, userData: userData) {}
  String key;

  @override
  bool isValid() => key?.isNotEmpty ?? false;

  @override
  void invalidate() {
    super.invalidate();
    key = null;
  }

  factory BasicAuthAccount.fromJson(Map<String, dynamic> json) =>
      BasicAuthAccount(json["identifier"],
          key: json["key"],
          userData: new Map<String, String>.from(json["userData"]));

  @override
  Map<String, dynamic> toJson() => {
        "identifier": identifier,
        "userData": userData,
        "key": key,
      };
}
