import 'package:simple_auth/simple_auth.dart';

Request applyHeader(Request request, String name, String value) =>
    applyHeaders(request, {name: value});

Request applyHeaders(Request request, Map<String, String> headers) {
  final h = new Map.from(request.headers);
  h.addAll(headers);
  return request.replace(headers: h);
}

Request addParameter(Request request, String name, dynamic value) =>
    addParametersToRequest(request, {name: value});

Request addParametersToRequest(
    Request request, Map<String, dynamic> parameters) {
  final h = new Map.from(request.parameters);
  h.addAll(parameters);
  return request.replace(parameters: h);
}

Uri addParameters(Uri uri, Map<String, dynamic> parameters) {
  Map<String, dynamic> p = new Map.from(uri.queryParameters);
  p.addAll(parameters);
  return uri.replace(queryParameters: p);
}
