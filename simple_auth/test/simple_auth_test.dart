import 'dart:async';

import 'package:test/test.dart';
import 'package:simple_auth/simple_auth.dart';
// import 'package:http/http.dart' as http;

void main() {
  test('adds one to input values', () async {

    // var convert = new ModelConverter();
    // final respStart =  new Resource("id2", "foo from resource 2");
    // var json = await convert.encode(new Request("get", "foo",body:respStart));
    // var response = new Response(new http.Response(json.body, 200),null);
    // var resource = await convert.decode(response, Resource);
    // expect(resource.body, respStart);
    // var resource2 = await convert.decode(response, Resource2);
    // var json2 = await convert.encode(new Request("get", "foo",body: resource2));
    // expect(json, json2);
    // final calculator = new Calculator();
    // expect(calculator.addOne(2), 3);
    // expect(calculator.addOne(-7), -6);
    // expect(calculator.addOne(0), 1);
    // expect(() => calculator.addOne(null), throwsNoSuchMethodError);
  });
}
class Resource2 implements JsonSerializable {

  @override
  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'name': name,
      };
  final String id;
  final String name;
  Resource2(this.id, this.name);

  @override
  factory Resource2.fromJson(Map<String, dynamic> json) => new Resource2(json['id'],json['name']);
}

class Resource {

  Map<String, dynamic> toJson()  =>
      {
        'id': id,
        'name': name,
      };
  final String id;
  final String name;
  Resource(this.id, this.name);

  factory Resource.fromJson(Map<String, dynamic> json) => new Resource(json['id'],json['name']);
}

class ModelConverter extends JsonConverter {

  @override
  Future<Response> decode(Response response, Type responseType) async {
    final d = await super.decode(response, responseType);
    var body = d.body;
    if (responseType == Resource) {
      body = new Resource.fromJson(body as Map<String, dynamic>);
    }
    else if(responseType == Resource2)
    {
      body = new Resource2.fromJson(body as Map<String, dynamic>);
    }
    return new Response(response.base, body);
  }
}