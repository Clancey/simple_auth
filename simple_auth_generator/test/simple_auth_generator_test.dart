import 'package:simple_auth_generator/src/generator.dart';
import 'package:test/test.dart';
import 'dart:async';
import 'package:dart_style/dart_style.dart' as dart_style;
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';

import 'analysis_utils.dart';
import 'test_file_utils.dart';

import 'dart:mirrors';
import 'test_apis/services.dart';

final _formatter = new dart_style.DartFormatter();

String _packagePathCache;
String getPackagePath() {
  if (_packagePathCache == null) {
    // Getting the location of this file – via reflection
    var currentFilePath = (reflect(getPackagePath) as ClosureMirror)
        .function
        .location
        .sourceUri
        .path;

    _packagePathCache = p.normalize(p.join(p.dirname(currentFilePath), '..'));
  }
  return _packagePathCache;
}

LibraryReader _library;
void main() {
  setUpAll(() async {

  final path = testFilePath('test', 'test_apis');
  _library = await resolveCompilationUnit(path);
  });
  var generator = new SimpleAuthGenerator();

  Future<String> runForElementNamed(String name) async {
    final element = _library.allElements.singleWhere((e) => e.name == name);
    var annotation = generator.typeChecker.firstAnnotationOf(element);
    var generated = await generator.generateForAnnotatedElement(
        element, new ConstantReader(annotation), null);

    var output = _formatter.format(generated);
    printOnFailure(output);
    return output;
  }

  test('run generator for MyService', () async {
    var result = await runForElementNamed('$MyServiceDefinition');
    expect(result, ApiGenerationResults.myServiceResult);
  });

  test('run generator for ApiKeyApi', () async {
    var result = await runForElementNamed('$MyApiKeyDefinition');
    expect(result, ApiGenerationResults.myApiKeyDefinitionResult);
  });
  test('run generator for BasicAuthApi', () async {
    var result = await runForElementNamed('$MyBasicAuthApiDefinition');
    expect(result, ApiGenerationResults.myBasicAuthApiDefinitionResult);
  });
  test('run generator for MyOAuthApiDefinition', () async {
    var result = await runForElementNamed('$MyOAuthApiDefinition');
    expect(result, ApiGenerationResults.myOAuthApiDefinition);
  });
  test('run generator for MyOAuthApiKeyApiDefinition', () async {
    var result = await runForElementNamed('$MyOAuthApiKeyApiDefinition');
    expect(result, ApiGenerationResults.myOAuthApiKeyApiDefinitionResults);
  });

  test('run generator for GoogleTestDefinition', () async {
    var result = await runForElementNamed('$GoogleTestDefinition');
    expect(result, ApiGenerationResults.googleTestDefinitionResult);
  });

  test('run generator for YouTube', () async {
    var result = await runForElementNamed('$YouTubeApiDefinition');
    expect(result, ApiGenerationResults.youtubeApiResult);
  });

  test('run generator for AzureADDefinition', () async {
    var result = await runForElementNamed('$AzureADDefinition');
    expect(result, ApiGenerationResults.azureADDefinitionResult);
  });

  test('run generator for $AmazonDefinition', () async {
    var result = await runForElementNamed('$AmazonDefinition');
    expect(result, ApiGenerationResults.amazonDefinitionResult);
  });
  test('run generator for $DropboxDefinition', () async {
    var result = await runForElementNamed('$DropboxDefinition');
    expect(result, ApiGenerationResults.dropboxDefinitionResult);
  });
  test('run generator for $FacebookDefinition', () async {
    var result = await runForElementNamed('$FacebookDefinition');
    expect(result, ApiGenerationResults.facebookDefinitionResult);
  });
  test('run generator for $GithubDefinition', () async {
    var result = await runForElementNamed('$GithubDefinition');
    expect(result, ApiGenerationResults.githubDefinitionResult);
  });
  test('run generator for $InstagramDefinition', () async {
    var result = await runForElementNamed('$InstagramDefinition');
    expect(result, ApiGenerationResults.instagramDefinitionResult);
  });
  test('run generator for $LinkedInDefinition', () async {
    var result = await runForElementNamed('$LinkedInDefinition');
    expect(result, ApiGenerationResults.linkedInDefinitionResult);
  });
  test('run generator for $MicrosoftLiveDefinition', () async {
    var result = await runForElementNamed('$MicrosoftLiveDefinition');
    expect(result, ApiGenerationResults.microsoftDefinitionResult);
  });
}

class ApiGenerationResults {
  static String youtubeApiResult =
      '''class YoutubeApi extends GoogleApiKeyApi implements YouTubeApiDefinition {
  YoutubeApi(String identifier,
      {String apiKey:
          '419855213697-uq56vcune334omgqi51ou7jg08i3dnb1.apps.googleusercontent.com',
      String clientId: 'AIzaSyCxoYMmVpDwj7KXI3tRjWkVGsgg7JR5zAw',
      String clientSecret: 'UwQ8aUXKDpqPzH0gpJnSij3i',
      String redirectUrl: 'redirecturl',
      List<String> scopes,
      http.Client client,
      Converter converter,
      AuthStorage authStorage})
      : super(identifier, apiKey, clientId, redirectUrl,
            clientSecret: clientSecret,
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

  Future<Response<String>> search(String q,
      [int maxResults = 25, String part = "snippet"]) {
    final url = 'search';
    final params = {'q': q, 'maxResults': maxResults, 'part': part};
    final request =
        new Request('GET', url, parameters: params, authenticated: true);
    return send<String>(request, responseType: String);
  }
}
''';
  static String googleTestDefinitionResult =
      '''class GoogleTestApi extends GoogleApi implements GoogleTestDefinition {
  GoogleTestApi(String identifier,
      {String clientId: 'client_id',
      String clientSecret: 'client_secret',
      String redirectUrl: 'redirecturl',
      List<String> scopes,
      http.Client client,
      Converter converter,
      AuthStorage authStorage})
      : super(identifier, clientId, redirectUrl,
            clientSecret: clientSecret,
            scopes: scopes,
            client: client,
            converter: converter,
            authStorage: authStorage) {
    this.scopes = scopes ?? ['TestScope', 'Scope2'];
  }

  Future<Response<GoogleUser>> getCurrentUserInfo() {
    final url = 'https://www.googleapis.com/oauth2/v1/userinfo?alt=json';
    final request = new Request('GET', url, authenticated: true);
    return send<GoogleUser>(request, responseType: GoogleUser);
  }

  @override
  Future<Response<Value>> decodeResponse<Value>(
      Response<String> response, Type responseType, bool responseIsList) async {
    var converted =
        await converter?.decode(response, responseType, responseIsList);
    if (converted != null) return converted;
    if (responseType == GoogleUser) {
      final d =
          await jsonConverter.decode(response, responseType, responseIsList);
      final body = responseIsList && d.body is List
          ? new List.from((d.body as List)
              .map((f) => new GoogleUser.fromJson(f as Map<String, dynamic>)))
          : new GoogleUser.fromJson(d.body as Map<String, dynamic>);
      return new Response(d.base, body as Value);
    }
    throw new Exception('No converter found for type \$Value');
  }
}
''';
  static String myServiceResult =
      '''class MyService extends Api implements MyServiceDefinition {
  MyService([http.Client client, Converter converter, AuthStorage authStorage])
      : super(client: client, converter: converter);

  Future<Response<List<GoogleUser>>> getList(String id) {
    final url = '/';
    final params = {'id': id};
    final headers = {'foo': 'bar'};
    final request = new Request('GET', url,
        parameters: params, headers: headers, authenticated: true);
    return send<List<GoogleUser>>(request,
        responseType: GoogleUser, responseIsList: true);
  }

  Future<Response<JsonSerializableObject>> getJsonSerializableObject(
      String id) {
    final url = '/';
    final params = {'id': id};
    final headers = {'foo': 'bar'};
    final request = new Request('GET', url,
        parameters: params, headers: headers, authenticated: true);
    return send<JsonSerializableObject>(request,
        responseType: JsonSerializableObject);
  }

  Future<Response> getResource(String id) {
    final url = '/\$id';
    final request = new Request('GET', url, authenticated: true);
    return send(request);
  }

  Future<Response<Map>> getMapResource(String id) {
    final url = '/';
    final params = {'id': id};
    final headers = {'foo': 'bar'};
    final request = new Request('GET', url,
        parameters: params, headers: headers, authenticated: true);
    return send<Map>(request, responseType: Map);
  }

  @override
  Future<Response<Value>> decodeResponse<Value>(
      Response<String> response, Type responseType, bool responseIsList) async {
    var converted =
        await converter?.decode(response, responseType, responseIsList);
    if (converted != null) return converted;
    if (responseType == GoogleUser) {
      final d =
          await jsonConverter.decode(response, responseType, responseIsList);
      final body = responseIsList && d.body is List
          ? new List.from((d.body as List)
              .map((f) => new GoogleUser.fromJson(f as Map<String, dynamic>)))
          : new GoogleUser.fromJson(d.body as Map<String, dynamic>);
      return new Response(d.base, body as Value);
    }
    if (responseType == JsonSerializableObject) {
      final d =
          await jsonConverter.decode(response, responseType, responseIsList);
      final body = responseIsList && d.body is List
          ? new List.from((d.body as List).map((f) =>
              new JsonSerializableObject.fromJson(f as Map<String, dynamic>)))
          : new JsonSerializableObject.fromJson(d.body as Map<String, dynamic>);
      return new Response(d.base, body as Value);
    }
    throw new Exception('No converter found for type \$Value');
  }
}
''';

  static String azureADDefinitionResult =
      '''class AzureAdTestApi extends AzureADApi implements AzureADDefinition {
  AzureAdTestApi(String identifier,
      {String clientId: 'resource',
      String authorizationUrl:
          'https://login.microsoftonline.com/azureTennant/oauth2/authorize',
      String tokenUrl:
          'https://login.microsoftonline.com/azureTennant/oauth2/token',
      String resource: 'client_id',
      String redirectUrl: 'redirecturl',
      String clientSecret: 'client_secret',
      List<String> scopes,
      http.Client client,
      Converter converter,
      AuthStorage authStorage})
      : super(identifier, clientId, authorizationUrl, tokenUrl, resource,
            redirectUrl,
            clientSecret: clientSecret,
            scopes: scopes,
            client: client,
            converter: converter,
            authStorage: authStorage) {}
}
''';

  static String myApiKeyDefinitionResult =
      '''class MyApiKeyDefinitionApi extends ApiKeyApi implements MyApiKeyDefinition {
  MyApiKeyDefinitionApi(
      {String apiKey: 'fdsfdskjfdskljflds',
      String authKey: 'key',
      AuthLocation authLocation: AuthLocation.query,
      http.Client client,
      Converter converter,
      AuthStorage authStorage})
      : super(apiKey, authKey, authLocation,
            client: client, converter: converter, authStorage: authStorage) {}
}
''';

  static String myBasicAuthApiDefinitionResult =
      '''class MyBasicAuthApi extends BasicAuthApi implements MyBasicAuthApiDefinition {
  MyBasicAuthApi(String identifier,
      {String loginUrl: 'http://example.com/login',
      http.Client client,
      Converter converter,
      AuthStorage authStorage})
      : super(identifier, loginUrl,
            client: client, converter: converter, authStorage: authStorage) {}
}
''';

  static String myOAuthApiDefinition =
      '''class MyOAuthApi extends OAuthApi implements MyOAuthApiDefinition {
  MyOAuthApi(String identifier,
      {String clientId: 'client_id',
      String clientSecret: 'clientSecret',
      String tokenUrl: 'TokenUrl',
      String authorizationUrl: 'AuthUrl',
      String redirectUrl: 'redirecturl',
      List<String> scopes,
      http.Client client,
      Converter converter,
      AuthStorage authStorage})
      : super(identifier, clientId, clientSecret, tokenUrl, authorizationUrl,
            redirectUrl,
            scopes: scopes,
            client: client,
            converter: converter,
            authStorage: authStorage) {}
}
''';

  static String myOAuthApiKeyApiDefinitionResults =
      '''class MyOAuthApiKeyApi extends OAuthApiKeyApi
    implements MyOAuthApiKeyApiDefinition {
  MyOAuthApiKeyApi(String identifier,
      {String apiKey: 'apiKey',
      String authKey: 'key',
      AuthLocation authLocation: AuthLocation.header,
      String clientId: 'client_id',
      String clientSecret: 'clientSecret',
      String tokenUrl: 'TokenUrl',
      String authorizationUrl: 'AuthUrl',
      String redirectUrl: 'redirecturl',
      List<String> scopes,
      http.Client client,
      Converter converter,
      AuthStorage authStorage})
      : super(identifier, apiKey, authKey, authLocation, clientId, clientSecret,
            tokenUrl, authorizationUrl, redirectUrl,
            scopes: scopes,
            client: client,
            converter: converter,
            authStorage: authStorage) {}
}
''';
  static String amazonDefinitionResult = '''class AmazonTestApi extends AmazonApi implements AmazonDefinition {
  AmazonTestApi(String identifier,
      {String clientId: 'client_id',
      String clientSecret: 'client_secret',
      String redirectUrl: 'redirecturl',
      List<String> scopes,
      http.Client client,
      Converter converter,
      AuthStorage authStorage})
      : super(identifier, clientId, redirectUrl,
            clientSecret: clientSecret,
            scopes: scopes,
            client: client,
            converter: converter,
            authStorage: authStorage) {}
}
''';
  static String dropboxDefinitionResult = '''class DropboxTestApi extends DropboxApi implements DropboxDefinition {
  DropboxTestApi(String identifier,
      {String clientId: 'client_id',
      String clientSecret: 'client_secret',
      String redirectUrl: 'redirecturl',
      List<String> scopes,
      http.Client client,
      Converter converter,
      AuthStorage authStorage})
      : super(identifier, clientId, redirectUrl,
            clientSecret: clientSecret,
            scopes: scopes,
            client: client,
            converter: converter,
            authStorage: authStorage) {}
}
''';
  static String facebookDefinitionResult = '''class FacebookTestApi extends FacebookApi implements FacebookDefinition {
  FacebookTestApi(String identifier,
      {String clientId: 'client_id',
      String clientSecret: 'client_secret',
      String redirectUrl: 'redirecturl',
      List<String> scopes,
      http.Client client,
      Converter converter,
      AuthStorage authStorage})
      : super(identifier, clientId, redirectUrl,
            clientSecret: clientSecret,
            scopes: scopes,
            client: client,
            converter: converter,
            authStorage: authStorage) {}
}
''';
  static String githubDefinitionResult = '''class GithubTestApi extends GithubApi implements GithubDefinition {
  GithubTestApi(String identifier,
      {String clientId: 'client_id',
      String clientSecret: 'client_secret',
      String redirectUrl: 'redirecturl',
      List<String> scopes,
      http.Client client,
      Converter converter,
      AuthStorage authStorage})
      : super(identifier, clientId, redirectUrl,
            clientSecret: clientSecret,
            scopes: scopes,
            client: client,
            converter: converter,
            authStorage: authStorage) {}
}
''';
  static String instagramDefinitionResult = '''class InstagramTestApi extends InstagramApi implements InstagramDefinition {
  InstagramTestApi(String identifier,
      {String clientId: 'client_id',
      String clientSecret: 'client_secret',
      String redirectUrl: 'redirecturl',
      List<String> scopes,
      http.Client client,
      Converter converter,
      AuthStorage authStorage})
      : super(identifier, clientId, redirectUrl,
            clientSecret: clientSecret,
            scopes: scopes,
            client: client,
            converter: converter,
            authStorage: authStorage) {}
}
''';
  static String linkedInDefinitionResult = '''class LinkedInTestApi extends LinkedInApi implements LinkedInDefinition {
  LinkedInTestApi(String identifier,
      {String clientId: 'client_id',
      String clientSecret: 'client_secret',
      String redirectUrl: 'redirecturl',
      List<String> scopes,
      http.Client client,
      Converter converter,
      AuthStorage authStorage})
      : super(identifier, clientId, redirectUrl,
            clientSecret: clientSecret,
            scopes: scopes,
            client: client,
            converter: converter,
            authStorage: authStorage) {}
}
''';
  static String microsoftDefinitionResult = '''class MicrosoftLiveTestApi extends MicrosoftLiveConnectApi
    implements MicrosoftLiveDefinition {
  MicrosoftLiveTestApi(String identifier,
      {String clientId: 'client_id',
      String clientSecret: 'client_secret',
      String redirectUrl: 'redirecturl',
      List<String> scopes,
      http.Client client,
      Converter converter,
      AuthStorage authStorage})
      : super(identifier, clientId, redirectUrl,
            clientSecret: clientSecret,
            scopes: scopes,
            client: client,
            converter: converter,
            authStorage: authStorage) {}
}
''';
}
