import "dart:async";
import 'package:simple_auth/simple_auth.dart';

abstract class JsonSerializableObject {
  Map<String, dynamic> toJson();
  factory JsonSerializableObject.fromJson(Map<String, dynamic> json) =>
      null;
}

@ApiDeclaration("MyService", baseUrl: "/resources")
abstract class MyServiceDefinition {


  @Get(url: "/", headers: const {"foo": "bar"})
  Future<Response<JsonSerializableObject>> getJsonSerializableObject(@Query() String id);

  @Get(url: "/{id}")
  Future<Response> getResource(@Path() String id);

  @Get(url: "/", headers: const {"foo": "bar"})
  Future<Response<Map>> getMapResource(@Query() String id);
}
