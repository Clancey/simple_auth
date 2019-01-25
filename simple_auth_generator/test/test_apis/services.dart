import "dart:async";
import 'package:simple_auth/simple_auth.dart';

abstract class JsonSerializableObject {
  Map<String, dynamic> toJson();
  factory JsonSerializableObject.fromJson(Map<String, dynamic> json) => null;
}

@ApiDeclaration("MyService", baseUrl: "/resources")
abstract class MyServiceDefinition {
  @Get(url: "/", headers: const {"foo": "bar"})
  Future<Response<List<GoogleUser>>> getList(@Query() String id);

  @Get(url: "/", headers: const {"foo": "bar"})
  Future<Response<JsonSerializableObject>> getJsonSerializableObject(
      @Query() String id);

  @Get(url: "/{id}")
  Future<Response> getResource(@Path() String id);

  @Get(url: "/", headers: const {"foo": "bar"})
  Future<Response<Map>> getMapResource(@Query() String id);
}

@GoogleApiDeclaration("GoogleTestApi", "client_id", "redirecturl",
    clientSecret: "client_secret", scopes: ["TestScope", "Scope2"])
abstract class GoogleTestDefinition {
  @Get(url: "https://www.googleapis.com/oauth2/v1/userinfo?alt=json")
  Future<Response<GoogleUser>> getCurrentUserInfo();
}

@GoogleApiKeyApiDeclaration(
    "YoutubeApi",
    "419855213697-uq56vcune334omgqi51ou7jg08i3dnb1.apps.googleusercontent.com",
    "AIzaSyCxoYMmVpDwj7KXI3tRjWkVGsgg7JR5zAw",
    "redirecturl",
    clientSecret: "UwQ8aUXKDpqPzH0gpJnSij3i",
    baseUrl: "https://www.googleapis.com/youtube/v3",
    scopes: [
      "https://www.googleapis.com/auth/youtube.readonly",
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/userinfo.profile"
    ])
abstract class YouTubeApiDefinition {
  @Get(url: "search")
  Future<Response<String>> search(@Query() String q,
      [@Query() int maxResults = 25, @Query() String part = "snippet"]);
}

@AmazonApiDeclaration(
    "AmazonTestApi", "client_id", "client_secret", "redirecturl")
abstract class AmazonDefinition {}

@AzureADApiDeclaration("AzureAdTestApi", "resource", "client_id", "redirecturl",
    azureTennant: "azureTennant", clientSecret: "client_secret")
abstract class AzureADDefinition {}

@DropboxApiDeclaration(
    "DropboxTestApi", "client_id", "client_secret", "redirecturl")
abstract class DropboxDefinition {}

@FacebookApiDeclaration(
    "FacebookTestApi", "client_id", "client_secret", "redirecturl")
abstract class FacebookDefinition {}

@GithubApiDeclaration(
    "GithubTestApi", "client_id", "client_secret", "redirecturl")
abstract class GithubDefinition {}

@InstagramApiDeclaration(
    "InstagramTestApi", "client_id", "client_secret", "redirecturl")
abstract class InstagramDefinition {}

@MicrosoftLiveDeclaration(
    "MicrosoftLiveTestApi", "client_id", "client_secret", "redirecturl")
abstract class MicrosoftLiveDefinition {}

@LinkedInApiDeclaration(
    "LinkedInTestApi", "client_id", "client_secret", "redirecturl")
abstract class LinkedInDefinition {}

@ApiKeyDeclaration("MyApiKeyDefinitionApi", "fdsfdskjfdskljflds", "key",
    ApiKeyDeclaration.AuthKeyLocationQuery)
abstract class MyApiKeyDefinition {}

@BasicAuthDeclaration("MyBasicAuthApi", "http://example.com/login")
abstract class MyBasicAuthApiDefinition {}

@OAuthApiKeyApiDeclaration(
    "MyOAuthApiKeyApi",
    "apiKey",
    "key",
    OAuthApiKeyApiDeclaration.AuthKeyLocationHeader,
    "client_id",
    "clientSecret",
    "TokenUrl",
    "AuthUrl",
    "redirecturl")
abstract class MyOAuthApiKeyApiDefinition {}

@OAuthApiDeclaration("MyOAuthApi", "client_id", "clientSecret", "TokenUrl",
    "AuthUrl", "redirecturl")
abstract class MyOAuthApiDefinition {}
