import "package:simple_auth/simple_auth.dart";

class Account implements JsonSerializable {
  Account(this.identifier, {this.userData = const {}});

  String identifier;
  Map<String, String> userData = {};
  factory Account.fromJson(Map<String, dynamic> json) =>
      new Account(json["identifier"],
          userData: new Map<String, String>.from(json["userData"]));

  @override
  Map<String, dynamic> toJson() => {
        "identifier": identifier,
        "userData": userData,
      };

  void invalidate() {}

  bool isValid() => true;
}
