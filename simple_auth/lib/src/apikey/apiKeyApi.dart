import "dart:async";
import "package:simple_auth/simple_auth.dart";
import 'package:simple_auth/src/utils.dart';
import "package:http/http.dart" as http;

enum AuthLocation { header, query }

class ApiKeyApi extends Api {
  AuthLocation authLocation;
  String apiKey;
  String authKey;
  ApiKeyApi(this.apiKey, this.authKey, this.authLocation,
      {http.Client client, Converter converter, AuthStorage authStorage})
      : super(identifier: apiKey, client: client, converter: converter);
  @override
  Future<Request> interceptRequest(Request request) async {
    Request req = request;
    if (req.authenticated) {
      if (authLocation == AuthLocation.header) {
        req = await applyHeader(request, authKey, apiKey);
      } else {
        req = await addParameter(request, authKey, apiKey);
      }
    }
    return super.interceptRequest(req);
  }
}
