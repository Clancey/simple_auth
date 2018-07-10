import 'dart:async';

import 'package:test/test.dart';
import 'package:simple_auth/simple_auth.dart';
import 'package:http/http.dart' as http;

void main() {
  test('serializes object lists to json and deserializes to json ', () async {
    var convert = new ModelConverter();
    final respStart = new Resource("id2", "foo from resource 2");
    final respStart2 = new Resource("id2", "foo from resource 1");
    var json = await convert.encode(new Request("get", "foo",
        body: new List.from([respStart, respStart2])));
    var decoded = await convert.decode(
        new Response(new http.Response(json.body, 200), null), Resource, true);
    var newJson =
        await convert.encode(new Request("get", "foo", body: decoded.body));
    expect(json.body, newJson.body);
  });
}

class Resource2 implements JsonSerializable {
  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
  final String id;
  final String name;
  Resource2(this.id, this.name);

  @override
  factory Resource2.fromJson(Map<String, dynamic> json) =>
      new Resource2(json['id'], json['name']);
}

class Resource {
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
  final String id;
  final String name;
  Resource(this.id, this.name);

  factory Resource.fromJson(Map<String, dynamic> json) =>
      new Resource(json['id'], json['name']);
}

class ModelConverter extends JsonConverter {
  @override
  Future<Response> decode(
      Response response, Type responseType, bool responseIsList) async {
    final d = await super.decode(response, responseType, responseIsList);
    var body = d.body;

    if (responseType == Resource) {
      body = responseIsList && body is List
          ? new List.from(
              body.map((f) => new Resource.fromJson(f as Map<String, dynamic>)))
          : new Resource.fromJson(d.body as Map<String, dynamic>);
    } else if (responseType == Resource2) {
      body = new Resource2.fromJson(body as Map<String, dynamic>);
    }
    return new Response(response.base, body);
  }
}
