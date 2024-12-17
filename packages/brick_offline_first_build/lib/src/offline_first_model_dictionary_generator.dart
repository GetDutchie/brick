import 'package:brick_build/generators.dart' show ModelDictionaryGenerator;

///
class OfflineFirstModelDictionaryGenerator extends ModelDictionaryGenerator {
  /// The capitalized domain, e.g. `Rest`.
  final String remoteProviderName;

  @override
  String get requiredImports => """
// ignore: unused_import
import 'dart:convert';
import 'package:brick_sqlite/brick_sqlite.dart' show SqliteModel, SqliteAdapter, SqliteModelDictionary, RuntimeSqliteColumnDefinition, SqliteProvider;
import 'package:brick_${remoteProviderName.toLowerCase()}/brick_${remoteProviderName.toLowerCase()}.dart' show ${remoteProviderName}Provider, ${remoteProviderName}Model, ${remoteProviderName}Adapter, ${remoteProviderName}ModelDictionary;
// ignore: unused_import, unused_shown_name
import 'package:brick_offline_first/brick_offline_first.dart' show RuntimeOfflineFirstDefinition;
// ignore: unused_import, unused_shown_name
import 'package:sqflite_common/sqlite_api.dart' show DatabaseExecutor;""";

  /// All classes annotated with `@ConnectOfflineFirstWith$remoteProviderName`
  const OfflineFirstModelDictionaryGenerator(this.remoteProviderName);

  @override
  String generate(Map<String, String> classNamesToFileNames) {
    final adapters = adaptersFromFiles(classNamesToFileNames);
    final dictionary = dictionaryFromFiles(classNamesToFileNames);
    final models = modelsFromFiles(classNamesToFileNames);
    return '''
${ModelDictionaryGenerator.HEADER}
$requiredImports

$models

$adapters

/// $remoteProviderName mappings should only be used when initializing a [${remoteProviderName}Provider]
final Map<Type, ${remoteProviderName}Adapter<${remoteProviderName}Model>> ${remoteProviderName.toLowerCase()}Mappings = {
  $dictionary
};
final ${remoteProviderName.toLowerCase()}ModelDictionary = ${remoteProviderName}ModelDictionary(${remoteProviderName.toLowerCase()}Mappings);

/// Sqlite mappings should only be used when initializing a [SqliteProvider]
final Map<Type, SqliteAdapter<SqliteModel>> sqliteMappings = {
  $dictionary
};
final sqliteModelDictionary = SqliteModelDictionary(sqliteMappings);
''';
  }
}
