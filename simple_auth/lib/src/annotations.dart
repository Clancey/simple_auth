import 'package:meta/meta.dart';
import 'request.dart';


@immutable
class AzureADApiDeclaration extends ApiDeclaration {
  final String authorizationUrl;
  final String tokenUrl;
  final String azureTennant;
  final String resource;
  final String clientId;
  final String clientSecret;
  final String redirectUrl;
  const AzureADApiDeclaration(String name, this.clientId,this.resource,
      {this.clientSecret = "native" ,String baseUrl: "/", this.redirectUrl = "http://localhost",this.authorizationUrl ,this.tokenUrl, this.azureTennant}) : super(name,baseUrl:baseUrl);
}

@immutable
class GoogleApiKeyApiDeclaration extends ApiDeclaration {
  final String apiKey;
  final String clientId;
  final String clientSecret;
  final String redirectUrl;
  final List<String> scopes;
  const GoogleApiKeyApiDeclaration(String name, this.apiKey, this.clientId,
      {this.clientSecret = "native" ,String baseUrl: "/", this.scopes, this.redirectUrl = "http://localhost"}) : super(name,baseUrl:baseUrl);
}

@immutable
class GoogleApiDeclaration extends ApiDeclaration {
  final String clientId;
  final String clientSecret;
  final String redirectUrl;
  final List<String> scopes;
  const GoogleApiDeclaration(String name, this.clientId,
      {this.clientSecret = "native" ,String baseUrl: "/", this.scopes, this.redirectUrl = "http://localhost"}) : super(name,baseUrl:baseUrl);
}

@immutable
class OAuthApiDeclaration extends ApiDeclaration {
  final String clientId;
  final String clientSecret;
  final List<String> scopes;
  const OAuthApiDeclaration(String name, this.clientId, this.clientSecret,
      {String baseUrl: "/", this.scopes}) : super(name,baseUrl: baseUrl);
}

@immutable
class ApiDeclaration {
  final String baseUrl;
  final String name;
  const ApiDeclaration(this.name, {this.baseUrl: "/"});
}

@immutable
class Path {
  final String name;
  const Path({this.name});
}

@immutable
class Query {
  final String name;
  const Query({this.name});
}

@immutable
class Body {
  const Body();
}

@immutable
class Header {
  final String name;
  const Header([this.name]);
}

@immutable
class Method {
  final String method;
  final String url;
  final Map<String, String> headers;
  final bool authenticated;

  const Method(this.method, {this.url: "/", this.headers: const {}, this.authenticated = true});
}

@immutable
class Get extends Method {
  const Get({String url: "/", Map<String, String> headers: const {}, bool authenticated = true})
      : super(HttpMethod.Get, url: url, headers: headers, authenticated: authenticated);
}

@immutable
class Post extends Method {
  const Post({String url: "/", Map<String, String> headers: const {}, bool authenticated = true})
      : super(HttpMethod.Post, url: url, headers: headers, authenticated: authenticated);
}

@immutable
class Delete extends Method {
  const Delete({String url: "/", Map<String, String> headers: const {}, bool authenticated = true})
      : super(HttpMethod.Delete, url: url, headers: headers, authenticated: authenticated);
}

@immutable
class Put extends Method {
  const Put({String url: "/", Map<String, String> headers: const {}, bool authenticated = true})
      : super(HttpMethod.Put, url: url, headers: headers, authenticated: authenticated);
}

@immutable
class Patch extends Method {
  const Patch({String url: "/", Map<String, String> headers: const {}, bool authenticated = true})
      : super(HttpMethod.Patch, url: url, headers: headers, authenticated: authenticated);
}

/* @immutable
class FormUrlEncoded {
  const FormUrlEncoded();
}

@immutable
class Field {
  final String name;
  const Field({this.name});
} */
