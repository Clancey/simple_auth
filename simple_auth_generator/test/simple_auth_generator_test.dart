import 'package:simple_auth_generator/src/generator.dart';
import 'package:test/test.dart';
import 'dart:async';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:dart_style/dart_style.dart' as dart_style;
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';
import 'dart:io';

import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer/src/dart/sdk/sdk.dart' show FolderBasedDartSdk;
import 'package:analyzer/src/generated/engine.dart';
import 'package:analyzer/src/generated/source.dart';
import 'package:analyzer/src/source/package_map_resolver.dart';
import 'package:analyzer/src/source/pub_package_map_provider.dart';
import 'package:analyzer/src/generated/source_io.dart';
import 'package:analyzer/file_system/file_system.dart' hide File;

import 'dart:mirrors';

final _formatter = new dart_style.DartFormatter();

CompilationUnit _compilationUnit;

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

void main() {
  setUpAll(() async {
    var sdkPath = p.dirname(p.dirname(Platform.resolvedExecutable));

    var resourceProvider = PhysicalResourceProvider.INSTANCE;
    var sdk = new FolderBasedDartSdk(
        resourceProvider, resourceProvider.getFolder(sdkPath));

    var options = new AnalysisOptionsImpl()
      ..analyzeFunctionBodies = false
      ..strongMode = true
      ..previewDart2 = true;
    var pubPackageMapProvider =
        new PubPackageMapProvider(PhysicalResourceProvider.INSTANCE, sdk);
    var packageMapInfo = pubPackageMapProvider.computePackageMap(
        PhysicalResourceProvider.INSTANCE.getResource(getPackagePath())
            as Folder);

    AnalysisEngine.instance.processRequiredPlugins();
    var context = AnalysisEngine.instance.createAnalysisContext()
      ..analysisOptions = options
      ..sourceFactory = new SourceFactory([
        new DartUriResolver(sdk),
        new ResourceUriResolver(PhysicalResourceProvider.INSTANCE),
        new PackageMapUriResolver(
            PhysicalResourceProvider.INSTANCE, packageMapInfo.packageMap)
      ]);

    var fileUri =
        p.toUri(p.join(getPackagePath(), 'test', 'test_apis', 'services.dart'));
    var source = context.sourceFactory.forUri2(fileUri);
    var libElement = context.computeLibraryElement(source);
    _compilationUnit = context.resolveCompilationUnit(source, libElement);
  });
  var generator = new SimpleAuthGenerator();

  Future<String> runForElementNamed(String name) async {
    var library = new LibraryReader(_compilationUnit.element.library);
    var element = library.allElements.singleWhere((e) => e.name == name);
    var annotation = generator.typeChecker.firstAnnotationOf(element);
    var generated = await generator.generateForAnnotatedElement(
        element, new ConstantReader(annotation), null);

    var output = _formatter.format(generated);
    printOnFailure(output);
    return output;
  }

  test('run generator for ApiKeyApi', () async {
    var result = await runForElementNamed('MyApiKeyDefinition');
    expect(result, ApiGenerationResults.myApiKeyDefinitionResult);
  });
  test('run generator for BasicAuthApi', () async {
    var result = await runForElementNamed('MyBasicAuthApiDefinition');
    expect(result, ApiGenerationResults.myBasicAuthApiDefinitionResult);
  });
  test('run generator for MyOAuthApiDefinition', () async {
    var result = await runForElementNamed('MyOAuthApiDefinition');
    expect(result, ApiGenerationResults.myOAuthApiDefinition);
  });
  test('run generator for MyOAuthApiKeyApiDefinition', () async {
    var result = await runForElementNamed('MyOAuthApiKeyApiDefinition');
    expect(result, ApiGenerationResults.myOAuthApiKeyApiDefinitionResults);
  });
  test('run generator for MyService', () async {
    var result = await runForElementNamed('MyServiceDefinition');
    expect(result, ApiGenerationResults.myServiceResult);
  });

  test('run generator for GoogleTestDefinition', () async {
    var result = await runForElementNamed('GoogleTestDefinition');
    expect(result, ApiGenerationResults.googleTestDefinitionResult);
  });

  test('run generator for YouTube', () async {
    var result = await runForElementNamed('YouTubeApiDefinition');
    expect(result, ApiGenerationResults.youtubeApiResult);
  });

  test('run generator for AzureADDefinition', () async {
    var result = await runForElementNamed('AzureADDefinition');
    expect(result, ApiGenerationResults.azureADDefinitionResult);
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
      String redirectUrl: 'http://localhost',
      List scopes,
      http.Client client,
      Converter converter,
      AuthStorage authStorage})
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
      String redirectUrl: 'http://localhost',
      List scopes,
      http.Client client,
      Converter converter,
      AuthStorage authStorage})
      : super(identifier, clientId,
            clientSecret: clientSecret,
            redirectUrl: redirectUrl,
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
      Response<String> response, Type responseType) async {
    var converted = await converter?.decode(response, responseType);
    if (converted != null) return converted;
    if (responseType == GoogleUser) {
      final d = await jsonConverter.decode(response, responseType);
      final body = new GoogleUser.fromJson(d.body as Map<String, dynamic>);
      return new Response(d.base, body as Value);
    }
    throw new Exception('No converter found for type \$Value');
  }
}
''';
  static String myServiceResult =
      '''class MyService extends Api implements MyServiceDefinition {
  MyService([http.Client client, Converter converter, AuthStorage authStorage])
      : super(identifier: identifier, client: client, converter: converter);

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
      Response<String> response, Type responseType) async {
    var converted = await converter?.decode(response, responseType);
    if (converted != null) return converted;
    if (responseType == JsonSerializableObject) {
      final d = await jsonConverter.decode(response, responseType);
      final body =
          new JsonSerializableObject.fromJson(d.body as Map<String, dynamic>);
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
      String clientSecret: 'client_secret',
      String redirectUrl: 'http://localhost',
      List scopes,
      http.Client client,
      Converter converter,
      AuthStorage authStorage})
      : super(identifier, clientId, authorizationUrl, tokenUrl, resource,
            clientSecret: clientSecret,
            redirectUrl: redirectUrl,
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

  static String myBasicAuthApiDefinitionResult = '''class MyBasicAuthApi extends BasicAuthApi implements MyBasicAuthApiDefinition {
  MyBasicAuthApi(String identifier,
      {String loginUrl: 'http://example.com/login',
      http.Client client,
      Converter converter,
      AuthStorage authStorage})
      : super(identifier, loginUrl,
            client: client, converter: converter, authStorage: authStorage) {}
}
''';

static String myOAuthApiDefinition = '''class MyOAuthApi extends OAuthApi implements MyOAuthApiDefinition {
  MyOAuthApi(String identifier,
      {String clientId: 'client_id',
      String clientSecret: 'clientSecret',
      String tokenUrl: 'TokenUrl',
      String authorizationUrl: 'AuthUrl',
      String redirectUrl: 'http://localhost',
      List scopes,
      http.Client client,
      Converter converter,
      AuthStorage authStorage})
      : super(identifier, clientId, clientSecret, tokenUrl, authorizationUrl,
            redirectUrl: redirectUrl,
            scopes: scopes,
            client: client,
            converter: converter,
            authStorage: authStorage) {}
}
''';

static String myOAuthApiKeyApiDefinitionResults = '''class MyOAuthApiKeyApi extends OAuthApiKeyApi
    implements MyOAuthApiKeyApiDefinition {
  MyOAuthApiKeyApi(String identifier,
      {String apiKey: 'apiKey',
      String authKey: 'key',
      AuthLocation authLocation: AuthLocation.header,
      String clientId: 'client_id',
      String clientSecret: 'clientSecret',
      String tokenUrl: 'TokenUrl',
      String authorizationUrl: 'AuthUrl',
      String redirectUrl: 'http://localhost',
      List scopes,
      http.Client client,
      Converter converter,
      AuthStorage authStorage})
      : super(identifier, apiKey, authKey, authLocation, clientId, clientSecret,
            tokenUrl, authorizationUrl,
            redirectUrl: redirectUrl,
            scopes: scopes,
            client: client,
            converter: converter,
            authStorage: authStorage) {}
}
''';
}
