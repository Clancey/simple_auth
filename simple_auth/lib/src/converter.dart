import 'dart:async';
import "dart:convert";
import "package:meta/meta.dart";
import 'package:simple_auth/simple_auth.dart';
import 'request.dart';
import 'response.dart';

@immutable
abstract class Converter {
  const Converter();

  Future<Request> encode(Request request);

  Future<Response> decode(Response response, Type responseType);
}

@immutable
class BodyConverterCodec extends Converter {
  final Codec codec;

  const BodyConverterCodec(this.codec) : super();

  Future<Request> encode(Request request) async {
    if (request.body == null) {
      return request;
    }
    return request.replace(body: codec.encode(request.body));
  }

  Future<Response> decode(Response response, Type responseType) async {
    if (response.base.body == null) {
      return response;
    }
    return response.replace(body: codec.decode(response.base.body));
  }
}

@immutable
class JsonConverter extends BodyConverterCodec {
  const JsonConverter() : super(json);

  @override
  Future<Request> encode(Request request) {
    var body = request.body;
    if (request.body is JsonSerializable) {
      body = (request.body as JsonSerializable).toJson();
    }
    return super.encode(request.replace(body: body));
  }
}
