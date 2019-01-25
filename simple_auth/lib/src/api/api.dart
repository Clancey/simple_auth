import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:simple_auth/simple_auth.dart';

class Api {
  final String identifier;
  String baseUrl;
  String defaultMediaType = "application/json";
  String useragent;
  final http.Client httpClient;
  Converter converter;
  final JsonConverter jsonConverter = new JsonConverter();
  Map<String, String> defaultHeaders;
  Api({this.identifier, http.Client client, Converter converter})
      : httpClient = client ?? new http.Client(),
        converter = converter;

  Future logOut() async {}

  ///Used to encode the body of the request before sending it.
  Future<Request> encodeRequest(Request request) async {
    var converted = await converter?.encode(request);
    if (converted == null && request.body is JsonSerializable) {
      converted = await jsonConverter.encode(request);
    }
    if (converted == null) {
      throw new Exception(
          "No converter found for type ${request.body?.runtimeType}");
    }

    return converted;
  }

  ///Used to decode the response body before returning from an API call
  Future<Response<Value>> decodeResponse<Value>(
      Response<String> response, Type responseType, bool responseIsList) async {
    final converted =
        await converter?.decode(response, responseType, responseIsList) ??
            response;

    if (converted == null) {
      throw new Exception("No converter found for type $Value");
    }

    return converted as Response<Value>;
  }

  ///Called before a request is sent across the wire.
  Future<Request> interceptRequest(Request request) async {
    Request req = request;
    if (useragent?.isNotEmpty ?? false) {
      Map<String, String> map = new Map.from(request.headers);
      map["User-Agent"] = useragent;
      req = request.replace(headers: map);
    }
    // for (final i in _requestInterceptors) {
    //   if (i is RequestInterceptor) {
    //     req = await i.onRequest(req);
    //   } else if (i is RequestInterceptorFunc) {
    //     req = await i(req);
    //   }
    // }
    return req;
  }

  ///Called before the response is returned to the user
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

  ///Used to send a request
  Future<Response<Value>> send<Value>(Request request,
      {Type responseType, bool responseIsList = false}) async {
    Request req = request;

    if (req.body != null) {
      req = await encodeRequest(request);
    }

    req = await interceptRequest(req);

    final stream = await httpClient.send(req.toHttpRequest(baseUrl));

    final response = await http.Response.fromStream(stream);

    Response res = new Response<String>(response, response.body);

    if (res.isSuccessful && responseType != null) {
      res = await decodeResponse<Value>(res, responseType, responseIsList);
    }

    res = await interceptResponse(res);

    if (!res.isSuccessful) {
      throw res;
    }

    return res;
  }

//Pings the baseUrl
  Future<bool> ping() => pingUrl(baseUrl);
//Pings a url to see if it is available
  Future<bool> pingUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      var request = new http.Request("GET", uri);
      await httpClient.send(request);
      return true;
    } catch (e) {
      return false;
    }
  }
}
