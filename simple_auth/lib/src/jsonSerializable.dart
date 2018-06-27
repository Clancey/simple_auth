abstract class JsonSerializable {
  Map<String, dynamic> toJson();
  factory JsonSerializable.fromJson(Map<String, dynamic> json) => null;
}
