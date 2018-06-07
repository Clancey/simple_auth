import 'dart:async';

import 'package:test/test.dart';
import 'package:simple_auth/simple_auth.dart';

void main() {
  test('adds one to input values', () async {

    var convert = new ModelConverter();
    var json = await convert.encode(new Request("get", "foo",body: new Resource2("id2", "foo from resource 2")));
    var resource1 = await convert.decode(new Response<Resource2>(null,null), Resource2);
    var resource = await convert.decode(new Response<Resource>(null,null), Resource);
    var json2 = await convert.encode(new Request("get", "foo",body: new Resource("id1", "foo from duck typing")));
    print(json);
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
    return response.replace(body: body);
  }
}