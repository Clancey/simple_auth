// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'youtubeApi.dart';

// **************************************************************************
// SimpleAuthGenerator
// **************************************************************************

class YoutubeApi extends GoogleApiKeyApi implements YouTubeApiDefinition {
  YoutubeApi(String identifier,
      [String apiKey = 'AIzaSyA6pSGpSe7dmcKGq87lcAcRl03h2CKSN7c',
      String clientId =
          '419855213697-uq56vcune334omgqi51ou7jg08i3dnb1.apps.googleusercontent.com',
      String clientSecret = 'UwQ8aUXKDpqPzH0gpJnSij3i',
      String redirectUrl = 'http://localhost',
      List<String> scopes,
      http.Client client,
      Converter converter,
      AuthStorage authStorage])
      : super(identifier, apiKey, clientId,
            clientSecret: clientSecret,
            redirectUrl: redirectUrl,
            scopes: scopes,
            client: client,
            converter: converter,
            authStorage: authStorage) {
    this.baseUrl = 'https://www.googleapis.com/youtube/v3';
    this.scopes = scopes ??
        [
          'https://www.googleapis.com/auth/youtube.readonly',
          'https://www.googleapis.com/auth/userinfo.email',
          'https://www.googleapis.com/auth/userinfo.profile'
        ];
  }

  Future<Response<YoutubeSearchListResult>> search(String q,
      [int maxResults = 25, String part = "snippet"]) {
    final url = 'search';
    final params = {'q': q, 'maxResults': maxResults, 'part': part};
    final request =
        new Request('GET', url, parameters: params, authenticated: false);
    return send<String>(request, responseType: String);
  }
}
