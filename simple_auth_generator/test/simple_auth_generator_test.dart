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
    var pubPackageMapProvider =new PubPackageMapProvider(PhysicalResourceProvider.INSTANCE, sdk);
    var packageMapInfo = pubPackageMapProvider.computePackageMap(
        PhysicalResourceProvider.INSTANCE.getResource(getPackagePath())
        as Folder);

    AnalysisEngine.instance.processRequiredPlugins();
    var context = AnalysisEngine.instance.createAnalysisContext()
      ..analysisOptions = options
      ..sourceFactory = new SourceFactory([
        new DartUriResolver(sdk),
        new ResourceUriResolver(PhysicalResourceProvider.INSTANCE),
        new PackageMapUriResolver(PhysicalResourceProvider.INSTANCE, packageMapInfo.packageMap)
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

//  test('run jsonResolver', () async {
//    var result = await runForElementNamed('JsonSerializableObject');
//
//    expect(result, "test");
//  });
  test('run generator', () async {
    var result = await runForElementNamed('YouTubeApiDefinition');

    expect(result, "test");
  });
}
