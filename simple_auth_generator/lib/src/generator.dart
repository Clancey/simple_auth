///@nodoc
import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:simple_auth/simple_auth.dart' as simple_auth;
import 'package:source_gen/source_gen.dart';

const _urlVar = "url";
const _parametersVar = "params";
const _headersVar = "headers";
const _requestVar = "request";

class SimpleAuthGenerator
    extends GeneratorForAnnotation<simple_auth.ApiDeclaration> {
  @override
  FutureOr<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) {
      final friendlyName = element.displayName;
      throw new InvalidGenerationSourceError(
          'Generator cannot target `$friendlyName`.',
          todo:
              'Remove the ServiceDefinition annotation from `$friendlyName`.');
    }

    return _buildImplementationClass(annotation, element);
  }

  String _buildImplementationClass(
      ConstantReader annotation, ClassElement element) {
    final friendlyName = element.name;
    final builderName =
        annotation?.peek("name")?.stringValue ?? "${friendlyName}Impl";
    //var constructors = element.constructors.toList();
    var jsonSearializables = new List<ClassElement>();
    final baseClass = _getBaseClass(annotation);
//    //List<ClassElement>()
    final classBuilder = new Class((c) {
      c
        ..name = builderName
        ..extend = new Reference(baseClass)
        ..constructors.add(_getConstructor(annotation))
        ..methods.addAll(element.methods.where((MethodElement m) {
          final methodAnnot = _getMethodAnnotation(m);
          return methodAnnot != null &&
              m.isAbstract &&
              m.returnType.isDartAsyncFuture;
        }).map((MethodElement m) {
          final method = _getMethodAnnotation(m);
          final body = _getAnnotation(m, simple_auth.Body);
          final paths = _getAnnotations(m, simple_auth.Path);
          final queries = _getAnnotations(m, simple_auth.Query);
          final headers = _generateHeaders(m, method);
          final url = _generateUrl(method, paths);
          final responseType = _getResponseType(m.returnType);
          final baseResponsetype =
              _getResponseType(m.returnType, stripList: true) ?? responseType;
          if (baseResponsetype?.element is ClassElement) {
            var ce = baseResponsetype.element as ClassElement;
            var json = ce.getNamedConstructor("fromJson");
            var firstParam = json?.parameters?.first?.type?.toString();
            if (json != null &&
                json.parameters.length == 1 &&
                firstParam == "Map<String, dynamic>" &&
                !jsonSearializables.contains(ce)) jsonSearializables.add(ce);
          }
          return new Method((b) {
            b.name = m.displayName;
            b.returns = new Reference(m.returnType.displayName);
            b.requiredParameters.addAll(m.parameters
                .where((p) => p.isNotOptional)
                .map((p) => new Parameter((pb) => pb
                  ..name = p.name
                  ..named = true
                  ..type = new Reference(p.type.displayName))));

            b.optionalParameters.addAll(m.parameters
                .where((p) => p.isOptionalPositional)
                .map((p) => new Parameter((pb) {
                      pb
                        ..name = p.name
                        ..type = new Reference(p.type.displayName);
                      if (p.defaultValueCode != null)
                        pb.defaultTo = new Code(p.defaultValueCode);
                    })));

            b.optionalParameters.addAll(m.parameters
                .where((p) => p.isNamed)
                .map((p) => new Parameter((pb) => pb
                  ..named = true
                  ..name = p.name
                  ..type = new Reference(p.type.displayName))));

            final blocks = [
              url.assignFinal(_urlVar).statement,
            ];

            if (queries.isNotEmpty) {
              blocks.add(_genereteQueryParams(queries));
            }

            if (headers != null) {
              blocks.add(headers);
            }

            blocks.add(_generateRequest(method, body,
                    useQueries: queries.isNotEmpty, useHeaders: headers != null)
                .assignFinal(_requestVar)
                .statement);

            final Map<String, Expression> namedArguments = {};
            final List<Reference> typeArguments = [];
            if (responseType != null) {
              namedArguments["responseType"] =
                  new CodeExpression(refer(baseResponsetype.displayName).code);
              typeArguments.add(refer(responseType.displayName));
              if (baseResponsetype.displayName != responseType.displayName) {
                namedArguments["responseIsList"] = literal(true);
              }
            }
            blocks.add(refer("send")
                .call([refer(_requestVar)], namedArguments, typeArguments)
                .returned
                .statement);

            b.body = new Block.of(blocks);
          });
        }))
        ..implements.add(new Reference(friendlyName));
      if (jsonSearializables.length > 0)
        c.methods.add(new Method((b) {
          final List<Code> body = [
            new Code(
                "var converted = await converter?.decode(response, responseType,responseIsList);"),
            new Code("if(converted != null) return converted;"),
          ];
          body.addAll(jsonSearializables.map((j) {
            return _generateJsonDeserialization(j);
          }));
          final errorMessage = r"'No converter found for type $Value'";
          body.add(new Code("throw new Exception($errorMessage);"));
          b.annotations.add(refer("override"));
          b.modifier = MethodModifier.async;
          b.name = "decodeResponse<Value>";
          b.returns = new Reference("Future<Response<Value>>");
          b.requiredParameters.addAll([
            new Parameter((p) => p
              ..name = 'response'
              ..type = new Reference("Response<String>")),
            new Parameter((p) => p
              ..name = 'responseType'
              ..type = new Reference("Type")),
            new Parameter((p) => p
              ..name = 'responseIsList'
              ..type = new Reference("bool")),
          ]);
          b.body = new Block.of(body);
        }));
    });

    final emitter = new DartEmitter();

    //final unformattedCode = classBuilder.accept(emitter).toString();
    return new DartFormatter().format('${classBuilder.accept(emitter)}');
  }

  String _getBaseClass(ConstantReader annotation) {
    final type = annotation.objectValue.type.name;
    switch (type) {
      case BuiltInAnnotations.apiKeyDeclaration:
        return "${simple_auth.ApiKeyApi}";
      case BuiltInAnnotations.basicAuthDeclaration:
        return "${simple_auth.BasicAuthApi}";
      case BuiltInAnnotations.amazonApiDeclaration:
        return "${simple_auth.AmazonApi}";
      case BuiltInAnnotations.azureADApiDeclaration:
        return "${simple_auth.AzureADApi}";
      case BuiltInAnnotations.azureADV2ApiDeclaration:
        return "${simple_auth.AzureADV2Api}";
      case BuiltInAnnotations.dropboxApiDeclaration:
        return "${simple_auth.DropboxApi}";
      case BuiltInAnnotations.facebookApiDeclaration:
        return "${simple_auth.FacebookApi}";
      case BuiltInAnnotations.githubApiDeclaration:
        return "${simple_auth.GithubApi}";
      case BuiltInAnnotations.googleApiDeclaration:
        return "${simple_auth.GoogleApi}";
      case BuiltInAnnotations.googleApiKeyApiDeclaration:
        return "${simple_auth.GoogleApiKeyApi}";
      case BuiltInAnnotations.instagramApiDeclaration:
        return "${simple_auth.InstagramApi}";
      case BuiltInAnnotations.linkedInApiDeclaration:
        return "${simple_auth.LinkedInApi}";
      case BuiltInAnnotations.microsoftLiveDeclaration:
        return "${simple_auth.MicrosoftLiveConnectApi}";
      case BuiltInAnnotations.oAuthApiDeclaration:
        return "${simple_auth.OAuthApi}";
      case BuiltInAnnotations.oAuthApiKeyApiDeclaration:
        return "${simple_auth.OAuthApiKeyApi}";
      default:
        return "${simple_auth.Api}";
    }
  }

  Code _generateJsonDeserialization(ClassElement element) {
    return new Code(
        "if(responseType == ${element.name}){ final d = await jsonConverter.decode(response,responseType,responseIsList); final body = responseIsList && d.body is List ?  new List.from((d.body as List).map((f) => new ${element.name}.fromJson(f as Map<String, dynamic>))) :  new ${element.name}.fromJson(d.body as Map<String, dynamic>); return new Response(d.base,body as Value);}");
  }

  Constructor _getConstructor(ConstantReader annotation) {
    final type = annotation.objectValue.type.name;
    final scopes = annotation.peek("scopes")?.listValue;
    final baseUrl = annotation.peek("baseUrl").stringValue;
    String body = "";
    if (baseUrl != "/") {
      body = "this.baseUrl = '${baseUrl}'; ";
    }
    if (scopes != null && scopes.length > 0) {
      List<String> strings = [];
      for (var scope in scopes) {
        var s = scope.toStringValue();
        strings.add("'$s'");
      }
      final scopeString = strings.join(",");
      body += " this.scopes = scopes ?? [${scopeString}];";
    }
    switch (type) {
      case BuiltInAnnotations.apiKeyDeclaration:
        {
          return new Constructor(
            (b) => b
              ..optionalParameters.addAll(_createParameters(annotation, [
                BuiltInParameters.apiKey,
                BuiltInParameters.authKey,
                BuiltInParameters.authLocation,
                BuiltInParameters.client,
                BuiltInParameters.converter,
                BuiltInParameters.authStorage
              ]))
              ..initializers.addAll([
                const Code(
                    'super(apiKey,authKey,authLocation, client: client, converter: converter,authStorage:authStorage)'),
              ])
              ..body = new Code(body),
          );
        }
      case BuiltInAnnotations.basicAuthDeclaration:
        {
          return new Constructor(
            (b) => b
              ..requiredParameters.addAll(
                  _createParameters(annotation, [BuiltInParameters.identifier]))
              ..optionalParameters.addAll(_createParameters(annotation, [
                BuiltInParameters.loginUrl,
                BuiltInParameters.client,
                BuiltInParameters.converter,
                BuiltInParameters.authStorage
              ]))
              ..initializers.addAll([
                const Code(
                    'super(identifier, loginUrl, client: client, converter: converter,authStorage:authStorage)'),
              ])
              ..body = new Code(body),
          );
        }
      case BuiltInAnnotations.azureADApiDeclaration:
        {
          return new Constructor(
            (b) => b
              ..requiredParameters.addAll(
                  _createParameters(annotation, [BuiltInParameters.identifier]))
              ..optionalParameters.addAll(_createParameters(annotation, [
                BuiltInParameters.clientId,
                BuiltInParameters.authorizationUrl,
                BuiltInParameters.tokenUrl,
                BuiltInParameters.resource,
                BuiltInParameters.redirectUrl,
                BuiltInParameters.clientSecret,
                BuiltInParameters.scopes,
                BuiltInParameters.client,
                BuiltInParameters.converter,
                BuiltInParameters.authStorage
              ]))
              ..initializers.addAll([
                const Code(
                    'super(identifier, clientId,tokenUrl,resource,authorizationUrl,redirectUrl,clientSecret: clientSecret,scopes: scopes, client: client, converter: converter,authStorage:authStorage)'),
              ])
              ..body = new Code(body),
          );
        }
      case BuiltInAnnotations.azureADV2ApiDeclaration:
        {
          return new Constructor(
            (b) => b
              ..requiredParameters.addAll(
                  _createParameters(annotation, [BuiltInParameters.identifier]))
              ..optionalParameters.addAll(_createParameters(annotation, [
                BuiltInParameters.clientId,
                BuiltInParameters.authorizationUrl,
                BuiltInParameters.tokenUrl,
                BuiltInParameters.redirectUrl,
                BuiltInParameters.clientSecret,
                BuiltInParameters.scopes,
                BuiltInParameters.client,
                BuiltInParameters.converter,
                BuiltInParameters.authStorage
              ]))
              ..initializers.addAll([
                const Code(
                    'super(identifier, clientId, clientSecret, tokenUrl, authorizationUrl, redirectUrl,scopes: scopes, client: client, converter: converter,authStorage:authStorage)'),
              ])
              ..body = new Code(body),
          );
        }
      case BuiltInAnnotations.amazonApiDeclaration:
      case BuiltInAnnotations.dropboxApiDeclaration:
      case BuiltInAnnotations.facebookApiDeclaration:
      case BuiltInAnnotations.githubApiDeclaration:
      case BuiltInAnnotations.instagramApiDeclaration:
      case BuiltInAnnotations.linkedInApiDeclaration:
      case BuiltInAnnotations.microsoftLiveDeclaration:
      case BuiltInAnnotations.googleApiDeclaration:
        {
          return new Constructor(
            (b) => b
              ..requiredParameters.addAll(
                  _createParameters(annotation, [BuiltInParameters.identifier]))
              ..optionalParameters.addAll(_createParameters(annotation, [
                BuiltInParameters.clientId,
                BuiltInParameters.clientSecret,
                BuiltInParameters.redirectUrl,
                BuiltInParameters.scopes,
                BuiltInParameters.client,
                BuiltInParameters.converter,
                BuiltInParameters.authStorage
              ]))
              ..initializers.addAll([
                const Code(
                    'super(identifier, clientId, redirectUrl, clientSecret: clientSecret,scopes: scopes, client: client, converter: converter,authStorage:authStorage)'),
              ])
              ..body = new Code(body),
          );
        }

      case BuiltInAnnotations.googleApiKeyApiDeclaration:
        {
          return new Constructor(
            (b) => b
              ..requiredParameters.addAll(
                  _createParameters(annotation, [BuiltInParameters.identifier]))
              ..optionalParameters.addAll(_createParameters(annotation, [
                BuiltInParameters.apiKey,
                BuiltInParameters.clientId,
                BuiltInParameters.clientSecret,
                BuiltInParameters.redirectUrl,
                BuiltInParameters.scopes,
                BuiltInParameters.client,
                BuiltInParameters.converter,
                BuiltInParameters.authStorage
              ]))
              ..initializers.addAll([
                const Code(
                    'super(identifier,apiKey, clientId, redirectUrl, clientSecret: clientSecret,scopes: scopes, client: client, converter: converter,authStorage:authStorage)'),
              ])
              ..body = new Code(body),
          );
        }
      case BuiltInAnnotations.oAuthApiKeyApiDeclaration:
        {
          return new Constructor(
            (b) => b
              ..requiredParameters.addAll(
                  _createParameters(annotation, [BuiltInParameters.identifier]))
              ..optionalParameters.addAll(_createParameters(annotation, [
                BuiltInParameters.apiKey,
                BuiltInParameters.authKey,
                BuiltInParameters.authLocation,
                BuiltInParameters.clientId,
                BuiltInParameters.clientSecret,
                BuiltInParameters.tokenUrl,
                BuiltInParameters.authorizationUrl,
                BuiltInParameters.redirectUrl,
                BuiltInParameters.scopes,
                BuiltInParameters.client,
                BuiltInParameters.converter,
                BuiltInParameters.authStorage
              ]))
              ..initializers.addAll([
                new Code(
                    'super(identifier,apiKey,authKey,authLocation,clientId,clientSecret,tokenUrl,authorizationUrl,redirectUrl,scopes:scopes, client: client, converter: converter,authStorage:authStorage)')
              ])
              ..body = new Code(body),
          );
        }
      case BuiltInAnnotations.oAuthApiDeclaration:
        {
          return new Constructor(
            (b) => b
              ..requiredParameters.addAll(
                  _createParameters(annotation, [BuiltInParameters.identifier]))
              ..optionalParameters.addAll(_createParameters(annotation, [
                BuiltInParameters.clientId,
                BuiltInParameters.clientSecret,
                BuiltInParameters.tokenUrl,
                BuiltInParameters.authorizationUrl,
                BuiltInParameters.redirectUrl,
                BuiltInParameters.scopes,
                BuiltInParameters.client,
                BuiltInParameters.converter,
                BuiltInParameters.authStorage
              ]))
              ..initializers.addAll([_generateOAuthSuper()])
              ..body = new Code(body),
          );
        }
      default:
        return new Constructor(
          (b) => b
            ..optionalParameters.addAll(_createParameters(annotation, [
              BuiltInParameters.client,
              BuiltInParameters.converter,
              BuiltInParameters.authStorage
            ]))
            ..initializers.addAll([
              const Code('super(client: client, converter: converter)'),
            ]),
        );
    }
  }

  Code _generateOAuthSuper() => const Code(
      'super(identifier,clientId,clientSecret,tokenUrl,authorizationUrl,redirectUrl,scopes:scopes, client: client, converter: converter,authStorage:authStorage)');

  Parameter _createStringParameterFromAnnotation(
      String name, ConstantReader annotation) {
    final peekValue = annotation.peek(name);
    if (peekValue == null) {
      print(name);
      throw name;
    }
    final value = peekValue.stringValue;
    if (value == null) return null;
    return new Parameter((b) => b
      ..name = name
      ..type = new Reference("${String}")
      ..defaultTo = new Code("${literal(value)}")
      ..named = true);
  }

  List<Parameter> _createParameters(
      ConstantReader annotation, List<String> parameterNames) {
    var parameters = new List<Parameter>();
    for (String pstring in parameterNames) {
      switch (pstring) {
        case BuiltInParameters.identifier:
          parameters.add(new Parameter((b) => b
            ..name = BuiltInParameters.identifier
            ..named = true
            ..type = new Reference("${String}")));
          break;
        case BuiltInParameters.apiKey:
          parameters.add(_createStringParameterFromAnnotation(
              BuiltInParameters.apiKey, annotation));
          break;
        case BuiltInParameters.authKey:
          parameters.add(_createStringParameterFromAnnotation(
              BuiltInParameters.authKey, annotation));
          break;
        case BuiltInParameters.authLocation:
          final name = BuiltInParameters.authLocation;
          final peekValue = annotation.peek(name);
          if (peekValue == null) {
            print(name);
            throw name;
          }
          final value = peekValue.stringValue;
          if (value == null) return null;
          parameters.add(new Parameter((b) => b
            ..name = name
            ..type = new Reference("${simple_auth.AuthLocation}")
            ..defaultTo = new Code("${value}")
            ..named = true));
          break;
        case BuiltInParameters.clientId:
          parameters.add(_createStringParameterFromAnnotation(
              BuiltInParameters.clientId, annotation));
          break;
        case BuiltInParameters.clientSecret:
          parameters.add(_createStringParameterFromAnnotation(
              BuiltInParameters.clientSecret, annotation));
          break;
        case BuiltInParameters.tokenUrl:
          parameters.add(_createStringParameterFromAnnotation(
              BuiltInParameters.tokenUrl, annotation));
          break;
        case BuiltInParameters.authorizationUrl:
          parameters.add(_createStringParameterFromAnnotation(
              BuiltInParameters.authorizationUrl, annotation));
          break;
        case BuiltInParameters.redirectUrl:
          parameters.add(_createStringParameterFromAnnotation(
              BuiltInParameters.redirectUrl, annotation));
          break;
        case BuiltInParameters.azureTennant:
          parameters.add(_createStringParameterFromAnnotation(
              BuiltInParameters.azureTennant, annotation));
          break;
        case BuiltInParameters.loginUrl:
          parameters.add(_createStringParameterFromAnnotation(
              BuiltInParameters.loginUrl, annotation));
          break;
        case BuiltInParameters.scopes:
          parameters.add(new Parameter((b) => b
            ..name = BuiltInParameters.scopes
            ..named
            ..type = new Reference("List<String>")
            ..named = true));
          break;
        case BuiltInParameters.identifier:
          parameters.add(new Parameter((b) => b
            ..name = BuiltInParameters.identifier
            ..named
            ..type = new Reference("${String}")));
          break;
        case BuiltInParameters.resource:
          parameters.add(_createStringParameterFromAnnotation(
              BuiltInParameters.resource, annotation));
          break;
        case BuiltInParameters.client:
          parameters.add(new Parameter((b) => b
            ..name = BuiltInParameters.client
            ..named
            ..type = new Reference("http.Client")));
          break;
        case BuiltInParameters.converter:
          parameters.add(new Parameter((b) => b
            ..name = BuiltInParameters.converter
            ..named
            ..type = new Reference("${simple_auth.Converter}")));
          break;
        case BuiltInParameters.authStorage:
          parameters.add(new Parameter((b) => b
            ..name = BuiltInParameters.authStorage
            ..named
            ..type = new Reference("${simple_auth.AuthStorage}")));
          break;
        default:
          throw pstring;
      }
    }
    return parameters;
  }

  Map<String, ConstantReader> _getAnnotation(MethodElement m, Type type) {
    var annot;
    String name;
    for (final p in m.parameters) {
      final a = _typeChecker(type).firstAnnotationOf(p);
      if (annot != null && a != null) {
        throw new Exception("Too many $type annotation for '${m.displayName}");
      } else if (annot == null && a != null) {
        annot = a;
        name = p.displayName;
      }
    }
    if (annot == null) return new Map<String, ConstantReader>();
    return {name: new ConstantReader(annot)};
  }

  Map<String, ConstantReader> _getAnnotations(MethodElement m, Type type) {
    Map<String, ConstantReader> annot = {};
    for (final p in m.parameters) {
      final a = _typeChecker(type).firstAnnotationOf(p);
      if (a != null) {
        annot[p.displayName] = new ConstantReader(a);
      }
    }
    return annot;
  }

  TypeChecker _typeChecker(Type type) => new TypeChecker.fromRuntime(type);

  ConstantReader _getMethodAnnotation(MethodElement method) {
    for (final type in _methodsAnnotations) {
      final annot = _typeChecker(type)
          .firstAnnotationOf(method, throwOnUnresolved: false);
      if (annot != null) return new ConstantReader(annot);
    }
    return null;
  }

  final _methodsAnnotations = const [
    simple_auth.Get,
    simple_auth.Post,
    simple_auth.Delete,
    simple_auth.Put,
    simple_auth.Patch,
    simple_auth.Method
  ];

  DartType _genericOf(DartType type) {
    return type is InterfaceType && type.typeArguments.isNotEmpty
        ? type.typeArguments.first
        : null;
  }

  DartType _getResponseType(DartType type, {bool stripList = false}) {
    final generic = _genericOf(type);
    if (generic == null ||
        (!stripList &&
            (_typeChecker(Map).isExactlyType(type) ||
                _typeChecker(List).isExactlyType(type)))) {
      return type;
    }
    if (generic.isDynamic) {
      return null;
    }
    return _getResponseType(generic, stripList: stripList);
  }

  Expression _generateUrl(
      ConstantReader method, Map<String, ConstantReader> paths) {
    String value = "${method.read("url").stringValue}";
    paths.forEach((String key, ConstantReader r) {
      final name = r.peek("name")?.stringValue ?? key;
      value = value.replaceFirst("{$name}", "\$$key");
    });
    return literal('$value');
  }

  Expression _generateRequest(
      ConstantReader method, Map<String, ConstantReader> body,
      {bool useQueries: false, bool useHeaders: false}) {
    final params = <Expression>[
      literal(method.peek("method").stringValue),
      refer(_urlVar)
    ];

    final namedParams = <String, Expression>{};

    if (body.isNotEmpty) {
      namedParams["body"] = refer(body.keys.first);
    }

    if (useQueries) {
      namedParams["parameters"] = refer(_parametersVar);
    }

    if (useHeaders) {
      namedParams["headers"] = refer(_headersVar);
    }
    namedParams["authenticated"] =
        literal(method.peek("authenticated").boolValue);
    return refer("Request").newInstance(params, namedParams);
  }

  Code _genereteQueryParams(Map<String, ConstantReader> queries) {
    final map = {};
    queries.forEach((String key, ConstantReader r) {
      final name = r.peek("name")?.stringValue ?? key;
      map[literal(name)] = refer(key);
    });

    return literalMap(map).assignFinal(_parametersVar).statement;
  }

  Code _generateHeaders(MethodElement m, ConstantReader method) {
    final map = {};

    final annotations = _getAnnotations(m, simple_auth.Header);

    annotations.forEach((String key, ConstantReader r) {
      final name = r.peek("name")?.stringValue ?? key;
      map[literal(name)] = refer(key);
    });

    final methodAnnotations = method.peek("headers").mapValue;

    methodAnnotations.forEach((k, v) {
      map[literal(k.toStringValue())] = literal(v.toStringValue());
    });

    if (map.isEmpty) {
      return null;
    }

    return literalMap(map).assignFinal(_headersVar).statement;
  }
}

Builder simple_authGeneratorFactoryBuilder({String header}) =>
    new PartBuilder([new SimpleAuthGenerator()], ".simple_auth.dart",
        header: header);

class BuiltInParameters {
  static const String scopes = 'scopes';
  static const String identifier = 'identifier';
  static const String client = 'client';
  static const String converter = 'converter';
  static const String authStorage = 'authStorage';
  static const String clientId = 'clientId';
  static const String clientSecret = 'clientSecret';
  static const String tokenUrl = 'tokenUrl';
  static const String authorizationUrl = 'authorizationUrl';
  static const String redirectUrl = 'redirectUrl';
  static const String apiKey = 'apiKey';
  static const String resource = 'resource';
  static const String azureTennant = 'azureTennant';
  static const String authKey = 'authKey';
  static const String authLocation = 'authLocation';
  static const String loginUrl = 'loginUrl';
}

class BuiltInAnnotations {
  static const String amazonApiDeclaration = 'AmazonApiDeclaration';
  static const String azureADApiDeclaration = 'AzureADApiDeclaration';
  static const String azureADV2ApiDeclaration = 'AzureADV2ApiDeclaration';
  static const String dropboxApiDeclaration = 'DropboxApiDeclaration';
  static const String facebookApiDeclaration = 'FacebookApiDeclaration';
  static const String githubApiDeclaration = 'GithubApiDeclaration';
  static const String googleApiDeclaration = 'GoogleApiDeclaration';
  static const String googleApiKeyApiDeclaration = 'GoogleApiKeyApiDeclaration';
  static const String instagramApiDeclaration = 'InstagramApiDeclaration';
  static const String linkedInApiDeclaration = 'LinkedInApiDeclaration';
  static const String microsoftLiveDeclaration = 'MicrosoftLiveDeclaration';
  static const String oAuthApiDeclaration = 'OAuthApiDeclaration';
  static const String oAuthApiKeyApiDeclaration = 'OAuthApiKeyApiDeclaration';
  static const String apiKeyDeclaration = 'ApiKeyDeclaration';
  static const String basicAuthDeclaration = "BasicAuthDeclaration";
}
