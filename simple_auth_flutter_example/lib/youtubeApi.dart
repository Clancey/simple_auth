import 'dart:async';
import 'package:simple_auth/simple_auth.dart';
import "package:http/http.dart" as http;

part 'youtubeApi.simple_auth.dart';

@GoogleApiKeyApiDeclaration("YoutubeApi",
    "419855213697-uq56vcune334omgqi51ou7jg08i3dnb1.apps.googleusercontent.com",
    "AIzaSyA6pSGpSe7dmcKGq87lcAcRl03h2CKSN7c",
    clientSecret: "UwQ8aUXKDpqPzH0gpJnSij3i",
    baseUrl: "https://www.googleapis.com/youtube/v3",
    scopes: [
      "https://www.googleapis.com/auth/youtube.readonly",
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/userinfo.profile"
    ])
abstract class YouTubeApiDefinition {
  @Get(url: "search", authenticated: false)
  Future<Response<String>> search(@Query() String q,[@Query() int maxResults = 25, @Query() String part = "snippet" ]);
}