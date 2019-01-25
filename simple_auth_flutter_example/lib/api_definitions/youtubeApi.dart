import 'dart:async';
import 'package:simple_auth/simple_auth.dart';
import "package:http/http.dart" as http;

part 'youtubeApi.simple_auth.dart';

@GoogleApiKeyApiDeclaration(
    "YoutubeApi",
    "AIzaSyA6pSGpSe7dmcKGq87lcAcRl03h2CKSN7c",
    "419855213697-uq56vcune334omgqi51ou7jg08i3dnb1.apps.googleusercontent.com",
    "redirecturl",
    clientSecret: "UwQ8aUXKDpqPzH0gpJnSij3i",
    baseUrl: "https://www.googleapis.com/youtube/v3",
    scopes: [
      "https://www.googleapis.com/auth/youtube.readonly",
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/userinfo.profile"
    ])
abstract class YouTubeApiDefinition {
  @Get(url: "search", authenticated: false)
  Future<Response<YoutubeSearchListResult>> search(@Query() String q,
      [@Query() int maxResults = 25, @Query() String part = "snippet"]);
}

class YoutubeSearchListResult {
  String kind;
  String etag;
  String nextPageToken;
  String prevPageToken;
  String regionCode;
  PageInfo pageInfo;
  List<Resource> items;

  YoutubeSearchListResult({
    this.kind,
    this.etag,
    this.nextPageToken,
    this.prevPageToken,
    this.regionCode,
    this.pageInfo,
    this.items = const [],
  });

  factory YoutubeSearchListResult.fromJson(Map<String, dynamic> json) =>
      new YoutubeSearchListResult(
        kind: json['kind'],
        etag: json['etag'],
        nextPageToken: json['nextPageToken'],
        prevPageToken: json['prevPageToken'],
        regionCode: json['regionCode'],
        pageInfo: new PageInfo.fromJson(json['pageInfo']),
        items: List<Resource>.from(
            (json['items']).map((x) => new Resource.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        'kind': kind,
        'etag': etag,
        'nextPageToken': nextPageToken,
        'prevPageToken': prevPageToken,
        'regionCode': regionCode,
        'pageInfo': pageInfo.toJson(),
        'items': items.map((i) => i.toJson()),
      };
}

class PageInfo {
  int totalResults;
  int resultsPerPage;

  PageInfo({
    this.totalResults,
    this.resultsPerPage,
  });

  factory PageInfo.fromJson(Map<String, dynamic> json) => new PageInfo(
      totalResults: json['totalResults'],
      resultsPerPage: json['resultsPerPage']);

  Map<String, dynamic> toJson() => {
        'totalResults': totalResults,
        'resultsPerPage': resultsPerPage,
      };
}

class ResourceId {
  String kind;
  String videoId;
  String channelId;
  String playlistId;

  ResourceId({
    this.kind,
    this.videoId,
    this.channelId,
    this.playlistId,
  });

  factory ResourceId.fromJson(Map<String, dynamic> json) => new ResourceId(
      kind: json['kind'],
      videoId: json['videoId'],
      channelId: json['channelId'],
      playlistId: json['playlistId']);

  Map<String, dynamic> toJson() => {
        'kind': kind,
        'videoId': videoId,
        'channelId': channelId,
        'playlistId': playlistId,
      };
}

class ResourceSnippet {}

class Resource {
  String kind;
  String etag;
  String channelTitle;
  String liveBroadcastContent;
  ResourceId id;
  ResourceSnippet snippet;

  Resource({
    this.kind,
    this.etag,
    this.channelTitle,
    this.liveBroadcastContent,
    this.id,
    this.snippet,
  });

  factory Resource.fromJson(Map<String, dynamic> json) => new Resource(
        kind: json['kind'],
        etag: json['etag'],
        channelTitle: json['channelTitle'],
        liveBroadcastContent: json['liveBroadcastContent'],
        id: ResourceId.fromJson(json['id']),
        //snippet: json['snippet'],
      );

  Map<String, dynamic> toJson() => {
        'kind': kind,
        'etag': etag,
        'channelTitle': channelTitle,
        'liveBroadcastContent': liveBroadcastContent,
        'id': id.toJson(),
        //'snippet': snippet,
      };
}
