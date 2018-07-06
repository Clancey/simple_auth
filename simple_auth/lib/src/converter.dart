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

  Future<Response> decode(
      Response response, Type responseType, bool responseIsList);
}

@immutable
class BodyConverterCodec extends Converter {
  final Codec codec;

  const BodyConverterCodec(this.codec) : super();

  Future<Request> encode(Request request) async {
    if (request.body == null) {
      return request;
    }
    return request.replaceBody(codec.encode(request.body));
  }

  Future<Response> decode(
      Response response, Type responseType, bool responseIsList) async {
    if (response.base.body == null) {
      return response;
    }
    final decoded = codec.decode(response.base.body);
    return new Response(response.base, decoded);
  }
}

@immutable
class JsonConverter extends BodyConverterCodec {
  const JsonConverter() : super(json);

  @override
  Future<Request> encode(Request request) {
    var body = request.body;
    if (body is List) {
      new List.from(
          (body as List).map((f) => (f is JsonSerializable) ? f.toJson() : f));
      body = new List.from(
          (body as List).map((f) => (f is JsonSerializable) ? f.toJson() : f));
    }
    if (request.body is JsonSerializable) {
      body = (request.body as JsonSerializable).toJson();
    }
    return super.encode(request.replaceBody(body));
  }
}
