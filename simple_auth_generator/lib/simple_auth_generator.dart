library simple_auth_generator.dart;

import 'package:build/build.dart';
import 'src/generator.dart';

Builder simple_authGeneratorFactory(BuilderOptions options) =>
    simple_authGeneratorFactoryBuilder(
        header: options.config['header'] as String);
