///@nodoc
import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

import 'package:build/build.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:dart_style/dart_style.dart';

import 'package:source_gen/source_gen.dart';
import 'package:code_builder/code_builder.dart';
import 'package:simple_auth/simple_auth.dart' as simple_auth;

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

    return _buildImplementionClass(annotation, element);
  }

  String _buildImplementionClass(
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
          if (responseType?.element is ClassElement) {
            var ce = responseType.element as ClassElement;
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
                  ..type = new Reference(p.type.displayName))));

            b.optionalParameters.addAll(m.parameters
                .where((p) => p.isOptionalPositional)
                .map((p) => new Parameter((pb) {
                      pb
                        ..name = p.name
                        ..type = new Reference(p.type.displayName);
                      if (p.defaultValueCode != null)
                        pb.defaultTo = new Code(p.defaultValueCode);
                      return pb;
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

            final namedArguments = {};
            final typeArguments = [];
            if (responseType != null) {
              namedArguments["responseType"] =
                  refer(responseType.displayName).code;
              typeArguments.add(refer(responseType.displayName));
            }
            blocks.add(refer("send")
                .call([refer(_requestVar)], namedArguments, typeArguments)
                .returned
                .statement);

            b.body = new Block.of(blocks);

            return b;
          });
        }))
        ..implements.add(new Reference(friendlyName));
      if (jsonSearializables.length > 0)
        c.methods.add(new Method((b) {
          final List<Code> body = [
            new Code(
                "var converted = await converter?.decode(response, responseType);"),
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
          ]);
          b.body = new Block.of(body);
        }));
      return c;
    });

    final emitter = new DartEmitter();

    //final unformattedCode = classBuilder.accept(emitter).toString();
    return new DartFormatter().format('${classBuilder.accept(emitter)}');
  }

  String _getBaseClass(ConstantReader annotation) {
    final type = annotation.objectValue.type.name;
    switch (type) {
      case "AzureADApiDeclaration":
        return "${simple_auth.AzureADApi}";
      case "GoogleApiDeclaration":
        return "${simple_auth.GoogleApi}";
      case "GoogleApiKeyApiDeclaration":
        return "${simple_auth.GoogleApiKeyApi}";
      case "OAuthApiDeclaration":
        return "${simple_auth.OAuthApi}";
      default:
        return "${simple_auth.Api}";
    }
  }

  Code _generateJsonDeserialization(ClassElement element) {
    return new Code(
        "if(responseType == ${element.name}){ final d = await jsonConverter.decode(response,responseType); final body = new ${element.name}.fromJson(d.body as Map<String, dynamic>); return new Response(d.base,body as Value);}");
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
      case "AzureADApiDeclaration":
        {
          final azureTennant = annotation.peek("azureTennant")?.stringValue;
          final authorizationUrl = annotation
                  .peek("authorizationUrl")
                  ?.stringValue ??
              "https://login.microsoftonline.com/$azureTennant/oauth2/authorize";
          final tokenUrl = annotation.peek("tokenUrl")?.stringValue ??
              "https://login.microsoftonline.com/$azureTennant/oauth2/token";

          return new Constructor(
            (b) => b
              ..requiredParameters.addAll([
                new Parameter((b) => b
                  ..name = 'identifier'
                  ..type = new Reference("${String}")),
              ])
              ..optionalParameters.addAll([
                _createStringParameterFromAnnotation("clientId", annotation),
                _createStringParameterWithDefault(
                    "authorizationUrl", authorizationUrl),
                _createStringParameterWithDefault("tokenUrl", tokenUrl),
                _createStringParameterFromAnnotation("resource", annotation),
                _createStringParameterFromAnnotation(
                    "clientSecret", annotation),
                _createStringParameterFromAnnotation("redirectUrl", annotation),
              ]..addAll(_createBaseParameters(['scopes', 'client', 'converter', 'authStorage'])))
              ..initializers.addAll([
                const Code(
                    'super(identifier, clientId,authorizationUrl,tokenUrl,resource, clientSecret: clientSecret,redirectUrl: redirectUrl,scopes: scopes, client: client, converter: converter,authStorage:authStorage)'),
              ])
              ..body = new Code(body),
          );
        }
      case "GoogleApiDeclaration":
        {
          return new Constructor(
            (b) => b
              ..requiredParameters.addAll([
                new Parameter((b) => b
                  ..name = 'identifier'
                  ..type = new Reference("${String}")),
              ])
              ..optionalParameters.addAll([
                _createStringParameterFromAnnotation("clientId", annotation),
                _createStringParameterFromAnnotation(
                    "clientSecret", annotation),
                _createStringParameterFromAnnotation("redirectUrl", annotation)
              ]..addAll(_createBaseParameters(['scopes', 'client', 'converter', 'authStorage'])))
              ..initializers.addAll([
                const Code(
                    'super(identifier, clientId, clientSecret: clientSecret,redirectUrl: redirectUrl,scopes: scopes, client: client, converter: converter,authStorage:authStorage)'),
              ])
              ..body = new Code(body),
          );
        }

      case "GoogleApiKeyApiDeclaration":
        {
          return new Constructor(
            (b) => b
              ..requiredParameters.addAll([
                new Parameter((b) => b
                  ..name = 'identifier'
                  ..type = new Reference("${String}")),
              ])
              ..optionalParameters.addAll([
                _createStringParameterFromAnnotation("apiKey", annotation),
                _createStringParameterFromAnnotation("clientId", annotation),
                _createStringParameterFromAnnotation(
                    "clientSecret", annotation),
                _createStringParameterFromAnnotation("redirectUrl", annotation)
              ]..addAll(_createBaseParameters(['scopes', 'client', 'converter', 'authStorage'])))
              ..initializers.addAll([
                const Code(
                    'super(identifier,apiKey, clientId, clientSecret: clientSecret,redirectUrl: redirectUrl,scopes: scopes, client: client, converter: converter,authStorage:authStorage)'),
              ])
              ..body = new Code(body),
          );
        }
      case "OAuthApiDeclaration":
        {
          return new Constructor(
            (b) => b
              ..requiredParameters.addAll([
                new Parameter((b) => b
                  ..name = 'identifier'
                  ..type = new Reference("${String}")),
              ])
              ..optionalParameters.addAll([
                _createStringParameterFromAnnotation("clientId", annotation),
                _createStringParameterFromAnnotation(
                    "clientSecret", annotation),
                _createStringParameterFromAnnotation("tokenUrl", annotation),
                _createStringParameterFromAnnotation(
                    "authorizationUrl", annotation),
                _createStringParameterFromAnnotation("redirectUrl", annotation)
              ]..addAll(_createBaseParameters(['scopes', 'client', 'converter', 'authStorage'])))
              ..initializers.addAll([
                const Code(
                    'super(identifier,clientId,clientSecret,tokenUrl,authorizationUrl,redirectUrl:redirectUrl,scopes:scopes, client: client, converter: converter,authStorage:authStorage)'),
              ])
              ..body = new Code(body),
          );
        }
      default:
        return new Constructor(
          (b) => b
            ..optionalParameters.addAll(_createBaseParameters(['client', 'converter', 'authStorage']))
            ..initializers.addAll([
              const Code(
                  'super(identifier: identifier, client: client, converter: converter)'),
            ]),
        );
    }
  }

  Parameter _createStringParameterWithDefault(String name, String value) =>
      new Parameter((b) => b
        ..name = name
        ..type = new Reference("${String}")
        ..named = true
        ..defaultTo = new Code("'${value}'"));
  Parameter _createStringParameterFromAnnotation(
      String name, ConstantReader annotation) {
    final peekValue = annotation.peek(name);
    if (peekValue == null) {
      print(name);
      throw name;
    }
    final value = peekValue.stringValue;
    return new Parameter((b) => b
      ..name = name
      ..type = new Reference("${String}")
      ..defaultTo = new Code("'${value}'")
      ..named = true);
  }

  List<Parameter> _createBaseParameters(List<String> parameterNames) {
    
    var parameters = new List<Parameter>();
    for (String p in parameterNames) {
      switch (p) {
        case 'scopes':
          parameters.add(new Parameter((b) => b
                  ..name = 'scopes'
                  ..type = new Reference("${List}")
                  ..named = true));
          break;
        case 'identifier':
            parameters.add(new Parameter((b) => b
                ..name = 'identifier'
                ..type = new Reference("${String}")));
          break;
        case 'client':
          parameters.add(new Parameter((b) => b
                ..name = 'client'
                ..type = new Reference("http.Client")));
          break;
        case 'converter':
          parameters.add(new Parameter((b) => b
                ..name = 'converter'
                ..type = new Reference("${simple_auth.Converter}")));
          break;
        case 'authStorage':
        parameters.add(new Parameter((b) => b
                ..name = 'authStorage'
                ..type = new Reference("${simple_auth.AuthStorage}")));
          break;
        default:
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
    if (annot == null) return {};
    return {name: new ConstantReader(annot)};
  }

  Map<String, ConstantReader> _getAnnotations(MethodElement m, Type type) {
    var annot = {};
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

  DartType _getResponseType(DartType type) {
    final generic = _genericOf(type);
    if (generic == null ||
        _typeChecker(Map).isExactlyType(type) ||
        _typeChecker(List).isExactlyType(type)) {
      return type;
    }
    if (generic.isDynamic) {
      return null;
    }
    return _getResponseType(generic);
  }

  Expression _generateUrl(
      ConstantReader method, Map<String, ConstantReader> paths) {
    String value = "${method
                                .read("url")
                                .stringValue}";
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
    new PartBuilder([new SimpleAuthGenerator()],
        header: header, generatedExtension: ".simple_auth.dart");
