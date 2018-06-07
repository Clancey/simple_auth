import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:simple_auth/simple_auth.dart';

class Api {
  final String identifier;
  String baseUrl;
  String defaultMediaType = "application/json";
  final http.Client httpClient;
  Converter _converter;
  Map<String, String> defaultHeaders;
  Api(
      {this.identifier,
      http.Client client,
      Converter converter})
      : httpClient = client ?? new http.Client(),
        _converter = converter;

  Future logOut() async {
    //TODO: Reset data;
  }

  Future onAccountUpdated(Account account) async {}

  

  Future<Request> encodeRequest(Request request) async {
    final converted = await _converter?.encode(request) ?? request;

    if (converted == null) {
      throw new Exception(
          "No converter found for type ${request.body?.runtimeType}");
    }

    return converted;
  }

  Future<Response<Value>> decodeResponse<Value>(
      Response<String> response, Type responseType) async {
    final converted = await _converter?.decode(response, responseType);

    if (converted == null) {
      throw new Exception("No converter found for type $Value");
    }

    return converted as Response<Value>;
  }

  Future<Request> interceptRequest(Request request) async {
    Request req = request;
    // for (final i in _requestInterceptors) {
    //   if (i is RequestInterceptor) {
    //     req = await i.onRequest(req);
    //   } else if (i is RequestInterceptorFunc) {
    //     req = await i(req);
    //   }
    // }
    return req;
  }

  Future<Response> interceptResponse(Response response) async {
    Response res = response;
    // for (final i in _responseInterceptors) {
    //   if (i is ResponseInterceptor) {
    //     res = await i.onResponse(res);
    //   } else if (i is ResponseInterceptorFunc) {
    //     res = await i(res);
    //   }
    // }
    return res;
  }

  Future<Response<Value>> send<Value>(Request request,
      {Type responseType}) async {
    Request req = request;

    if (req.body != null) {
      req = await encodeRequest(request);
    }

    req = await interceptRequest(req);

    final stream = await httpClient.send(req.toHttpRequest(baseUrl));

    final response = await http.Response.fromStream(stream);

    Response res = new Response<String>(response, response.body);

    if (res.isSuccessful && responseType != null) {
      res = await decodeResponse<Value>(res, responseType);
    }

    res = await interceptResponse(res);

    if (!res.isSuccessful) {
      throw res;
    }

    return res;
  }
  Future<bool> ping() => pingUrl(baseUrl);
  Future<bool> pingUrl(String url)async {
    try{
      final Uri uri = Uri.parse(url);
      var request = new http.Request("GET", uri);
      await httpClient.send(request);
      return true;
    }
    catch(e)
    {
      return false;
    }
  }
}
