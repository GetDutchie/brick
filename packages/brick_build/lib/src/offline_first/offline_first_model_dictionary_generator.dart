import 'package:brick_build/src/model_dictionary_generator.dart';

class OfflineFirstModelDictionaryGenerator extends ModelDictionaryGenerator {
  @override
  final requiredImports = """
// ignore: unused_import
import 'dart:convert';
import 'package:brick_sqlite/sqlite.dart' show SqliteModel, SqliteAdapter, SqliteModelDictionary;
import 'package:brick_rest/rest.dart' show RestProvider, RestModel, RestAdapter, RestModelDictionary;
// ignore: unused_import, unused_shown_name
import 'package:brick_core/core.dart' show Query, QueryAction;
// ignore: unused_import, unused_shown_name
import 'package:sqflite/sqflite.dart' show DatabaseExecutor;""";

  /// All classes annotated with `@ConnectOfflineFirst`
  const OfflineFirstModelDictionaryGenerator();

  String generate(Map<String, String> classNamesToFileNames) {
    final adapters = adaptersFromFiles(classNamesToFileNames);
    final dictionary = dictionaryFromFiles(classNamesToFileNames);
    final models = modelsFromFiles(classNamesToFileNames);
    return """
${ModelDictionaryGenerator.HEADER}
$requiredImports

$models

$adapters

/// REST mappings should only be used when initializing a [RestProvider]
final Map<Type, RestAdapter<RestModel>> restMappings = {
  $dictionary
};
final restModelDictionary = RestModelDictionary(restMappings);

/// Sqlite mappings should only be used when initializizing a [SqliteProvider]
final Map<Type, SqliteAdapter<SqliteModel>> sqliteMappings = {
  $dictionary
};
final sqliteModelDictionary = SqliteModelDictionary(sqliteMappings);
""";
  }
}
