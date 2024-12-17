import 'package:brick_build/src/utils/string_helpers.dart';

/// Given a list of models, output generated code to use as `brick.g.dart` file
abstract class ModelDictionaryGenerator {
  /// As a part, adapters have access to imports in the model dictionary file
  /// so any methods that incorporate Type definitions should be listed here.
  /// For example, importing a `SqliteProvider` or a `DatabaseExecutor`.
  /// Consider adding analyzer ignores to disable 'unused_import' warnings.
  String get requiredImports => '';

  ///
  // ignore: constant_identifier_names
  static const HEADER = '// GENERATED CODE DO NOT EDIT';

  /// Given a list of models, output generated code to use as `brick.g.dart` file
  const ModelDictionaryGenerator();

  /// Adapter part imports
  String adaptersFromFiles(Map<String, String> classNamesToFileNames) => classNamesToFileNames.keys
      .map((k) => "part 'adapters/${StringHelpers.snakeCase(k)}_adapter.g.dart';")
      .join('\n');

  ///
  String dictionaryFromFiles(Map<String, String> classNamesToFileNames) =>
      classNamesToFileNames.keys.map((k) => '$k: ${k}Adapter()').join(',\n  ');

  /// Complete modelDictionary code, including imports
  /// [classNamesToFileNames] are filenames included to generate the import/export statements
  String generate(Map<String, String> classNamesToFileNames);

  /// Model imports
  String modelsFromFiles(Map<String, String> classNamesToFileNames) =>
      classNamesToFileNames.values.map((k) => "import '$k';").join('\n');
}
