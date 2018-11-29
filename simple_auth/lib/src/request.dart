import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;

@immutable
class Request {
  final bool authenticated;
  final String method;
  final String url;
  final dynamic body;
  final Map<String, dynamic> parameters;
  final Map<String, String> headers;

  Request(this.method, this.url,
      {this.body,
      this.parameters: const {},
      this.headers: const {},
      this.authenticated = true});

  String _getMethod(String method) {
    switch (method) {
      case HttpMethod.Delete:
        return "DELETE";
      case HttpMethod.Patch:
        return "PATCH";
      case HttpMethod.Post:
        return "POST";
      case HttpMethod.Put:
        return "PUT";
      default:
        return "GET";
    }
  }

  Request replace(
          {HttpMethod method,
          String url,
          Map<String, dynamic> parameters,
          Map<String, String> headers,
          Encoding encoding}) =>
      new Request(method ?? this.method, url ?? this.url,
          parameters: parameters ?? this.parameters,
          headers: headers ?? this.headers,
          body: this.body,
          authenticated: this.authenticated);
  Request replaceBody(dynamic body,
          {HttpMethod method,
          String url,
          Map<String, dynamic> parameters,
          Map<String, String> headers,
          Encoding encoding}) =>
      new Request(method ?? this.method, url ?? this.url,
          body: body,
          parameters: parameters ?? this.parameters,
          headers: headers ?? this.headers,
          authenticated: this.authenticated);

  http.BaseRequest toHttpRequest(String baseUrl) {
    var pathUrl = Uri.tryParse(url);
    if (pathUrl?.scheme?.isEmpty ?? true) {
      pathUrl = Uri.parse("$baseUrl/${url}");
    }
    var cleanedParams = parameters;
    parameters.keys
        .where((key) => parameters[key] == null)
        .toList()
        .forEach(cleanedParams.remove);
    final uri = pathUrl.replace(
        queryParameters: cleanedParams.map((k, v) => new MapEntry(k, "$v")));
    final baseRequest = new http.Request(_getMethod(method), uri);
    baseRequest.headers.addAll(headers);
    if (body != null) {
      if (body is String) {
        baseRequest.body = body as String;
      } else if (body is List) {
        baseRequest.bodyBytes = (body as List<int>).cast<int>();
      } else if (body is Map) {
        baseRequest.bodyFields = (body as Map).cast<String, String>();
      } else {
        throw new ArgumentError('Invalid request body "${body}".');
      }
    }
    return baseRequest;
  }
}

class HttpMethod {
  static const String Get = "GET";
  static const String Post = "POST";
  static const String Put = "PUT";
  static const String Delete = "DELETE";
  static const String Patch = "PATCH";
}
