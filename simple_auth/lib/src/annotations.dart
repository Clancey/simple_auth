import 'package:meta/meta.dart';
import 'package:simple_auth/simple_auth.dart';
import 'request.dart';

@immutable
class ApiDeclaration {
  final String baseUrl;
  final String name;
  const ApiDeclaration(this.name, {this.baseUrl: "/"});
}

@immutable
class ApiKeyDeclaration extends ApiDeclaration {
  static const String AuthKeyLocationHeader = "AuthLocation.header";
  static const String AuthKeyLocationQuery = "AuthLocation.query";
  final String authLocation;
  final String apiKey;
  final String authKey;
  const ApiKeyDeclaration(
      String name, this.apiKey, this.authKey, this.authLocation,
      {String baseUrl: "/"})
      : super(name, baseUrl: baseUrl);
}

@immutable
class BasicAuthDeclaration extends ApiDeclaration {
  final String loginUrl;
  const BasicAuthDeclaration(
      String name, this.loginUrl,
      {String baseUrl: "/"})
      : super(name, baseUrl: baseUrl);
}

@immutable
class OAuthApiKeyApiDeclaration extends ApiDeclaration {
  static const String AuthKeyLocationHeader = "AuthLocation.header";
  static const String AuthKeyLocationQuery = "AuthLocation.query";
  final String authLocation;
  final String apiKey;
  final String authKey;
  final String clientId;
  final String clientSecret;
  final String tokenUrl;
  final String authorizationUrl;
  final String redirectUrl;
  final List<String> scopes;
  const OAuthApiKeyApiDeclaration(String name, this.apiKey, this.authKey,
      this.authLocation, this.clientId, this.clientSecret, this.tokenUrl, this.authorizationUrl,
      {String baseUrl: "/",this.redirectUrl = "http://localhost" ,this.scopes})
      : super(name, baseUrl: baseUrl);
}

@immutable
class OAuthApiDeclaration extends ApiDeclaration {
  final String clientId;
  final String clientSecret;
  final String tokenUrl;
  final String authorizationUrl;
  final String redirectUrl;
  final List<String> scopes;
  const OAuthApiDeclaration(String name, this.clientId, this.clientSecret, this.tokenUrl, this.authorizationUrl,
      {this.redirectUrl = "http://localhost", String baseUrl: "/", this.scopes})
      : super(name, baseUrl: baseUrl);
}

@immutable
class AmazonApiDeclaration extends ApiDeclaration {
  final String clientId;
  final String clientSecret;
  final String redirectUrl;
  final List<String> scopes;
  const AmazonApiDeclaration(String name, this.clientId,this.clientSecret,
      {String baseUrl: "/",
      this.scopes,
      this.redirectUrl = "http://localhost"})
      : super(name, baseUrl: baseUrl);
}

@immutable
class DropboxApiDeclaration extends ApiDeclaration {
  final String clientId;
  final String clientSecret;
  final String redirectUrl;
  final List<String> scopes;
  const DropboxApiDeclaration(String name, this.clientId,this.clientSecret,
      {String baseUrl: "/",
      this.scopes,
      this.redirectUrl = "http://localhost"})
      : super(name, baseUrl: baseUrl);
}

@immutable
class FacebookApiDeclaration extends ApiDeclaration {
  final String clientId;
  final String clientSecret;
  final String redirectUrl;
  final List<String> scopes;
  const FacebookApiDeclaration(String name, this.clientId,this.clientSecret,
      {String baseUrl: "/",
      this.scopes,
      this.redirectUrl = "http://localhost"})
      : super(name, baseUrl: baseUrl);
}


@immutable
class GithubApiDeclaration extends ApiDeclaration {
  final String clientId;
  final String clientSecret;
  final String redirectUrl;
  final List<String> scopes;
  const GithubApiDeclaration(String name, this.clientId,this.clientSecret,
      {String baseUrl: "/",
      this.scopes,
      this.redirectUrl = "http://localhost"})
      : super(name, baseUrl: baseUrl);
}


@immutable
class InstagramApiDeclaration extends ApiDeclaration {
  final String clientId;
  final String clientSecret;
  final String redirectUrl;
  final List<String> scopes;
  const InstagramApiDeclaration(String name, this.clientId,this.clientSecret,
      {String baseUrl: "/",
      this.scopes,
      this.redirectUrl = "http://localhost"})
      : super(name, baseUrl: baseUrl);
}

@immutable
class LinkedInApiDeclaration extends ApiDeclaration {
  final String clientId;
  final String clientSecret;
  final String redirectUrl;
  final List<String> scopes;
  const LinkedInApiDeclaration(String name, this.clientId,this.clientSecret,
      {String baseUrl: "/",
      this.scopes,
      this.redirectUrl = "http://localhost"})
      : super(name, baseUrl: baseUrl);
}

@immutable
class MicrosoftLiveDeclaration extends ApiDeclaration {
  final String clientId;
  final String clientSecret;
  final String redirectUrl;
  final List<String> scopes;
  const MicrosoftLiveDeclaration(String name, this.clientId,this.clientSecret,
      {String baseUrl: "/",
      this.scopes,
      this.redirectUrl = "http://localhost"})
      : super(name, baseUrl: baseUrl);
}


@immutable
class AzureADApiDeclaration extends ApiDeclaration {
  final String authorizationUrl;
  final String tokenUrl;
  final String azureTennant;
  final String resource;
  final String clientId;
  final String clientSecret;
  final String redirectUrl;
  const AzureADApiDeclaration(String name, this.clientId, this.resource,
      {this.clientSecret = "native",
      String baseUrl: "/",
      this.redirectUrl = "http://localhost",
      String authorizationUrl,
      String tokenUrl,
      this.azureTennant="\$azureTennant"})
      : authorizationUrl = authorizationUrl ??
            "https://login.microsoftonline.com/$azureTennant/oauth2/authorize",
        tokenUrl = tokenUrl ??
            "https://login.microsoftonline.com/$azureTennant/oauth2/token",
        super(name, baseUrl: baseUrl);
}

@immutable
class GoogleApiKeyApiDeclaration extends ApiDeclaration {
  final String apiKey;
  final String clientId;
  final String clientSecret;
  final String redirectUrl;
  final List<String> scopes;
  const GoogleApiKeyApiDeclaration(String name, this.apiKey, this.clientId,
      {this.clientSecret = "native",
      String baseUrl: "/",
      this.scopes,
      this.redirectUrl = "http://localhost"})
      : super(name, baseUrl: baseUrl);
}

@immutable
class GoogleApiDeclaration extends ApiDeclaration {
  final String clientId;
  final String clientSecret;
  final String redirectUrl;
  final List<String> scopes;
  const GoogleApiDeclaration(String name, this.clientId,
      {this.clientSecret = "native",
      String baseUrl: "/",
      this.scopes,
      this.redirectUrl = "http://localhost"})
      : super(name, baseUrl: baseUrl);
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

  const Method(this.method,
      {this.url: "/", this.headers: const {}, this.authenticated = true});
}

@immutable
class Get extends Method {
  const Get(
      {String url: "/",
      Map<String, String> headers: const {},
      bool authenticated = true})
      : super(HttpMethod.Get,
            url: url, headers: headers, authenticated: authenticated);
}

@immutable
class Post extends Method {
  const Post(
      {String url: "/",
      Map<String, String> headers: const {},
      bool authenticated = true})
      : super(HttpMethod.Post,
            url: url, headers: headers, authenticated: authenticated);
}

@immutable
class Delete extends Method {
  const Delete(
      {String url: "/",
      Map<String, String> headers: const {},
      bool authenticated = true})
      : super(HttpMethod.Delete,
            url: url, headers: headers, authenticated: authenticated);
}

@immutable
class Put extends Method {
  const Put(
      {String url: "/",
      Map<String, String> headers: const {},
      bool authenticated = true})
      : super(HttpMethod.Put,
            url: url, headers: headers, authenticated: authenticated);
}

@immutable
class Patch extends Method {
  const Patch(
      {String url: "/",
      Map<String, String> headers: const {},
      bool authenticated = true})
      : super(HttpMethod.Patch,
            url: url, headers: headers, authenticated: authenticated);
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
