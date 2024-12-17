import 'package:brick_offline_first_build/src/offline_first_model_dictionary_generator.dart';
import 'package:test/test.dart';

void main() {
  group('OfflineFirstModelDictionaryGenerator', () {
    group('#generate', () {
      test('basic', () {
        final generated = const OfflineFirstModelDictionaryGenerator('Rest')
            .generate({'Person': 'person.dart', 'User': 'path/user.dart'});
        const output = '''
// GENERATED CODE DO NOT EDIT
// ignore: unused_import
import 'dart:convert';
import 'package:brick_sqlite/brick_sqlite.dart' show SqliteModel, SqliteAdapter, SqliteModelDictionary, RuntimeSqliteColumnDefinition, SqliteProvider;
import 'package:brick_rest/brick_rest.dart' show RestProvider, RestModel, RestAdapter, RestModelDictionary;
// ignore: unused_import, unused_shown_name
import 'package:brick_offline_first/brick_offline_first.dart' show RuntimeOfflineFirstDefinition;
// ignore: unused_import, unused_shown_name
import 'package:sqflite_common/sqlite_api.dart' show DatabaseExecutor;

import 'person.dart';
import 'path/user.dart';

part 'adapters/person_adapter.g.dart';
part 'adapters/user_adapter.g.dart';

/// Rest mappings should only be used when initializing a [RestProvider]
final Map<Type, RestAdapter<RestModel>> restMappings = {
  Person: PersonAdapter(),
  User: UserAdapter()
};
final restModelDictionary = RestModelDictionary(restMappings);

/// Sqlite mappings should only be used when initializing a [SqliteProvider]
final Map<Type, SqliteAdapter<SqliteModel>> sqliteMappings = {
  Person: PersonAdapter(),
  User: UserAdapter()
};
final sqliteModelDictionary = SqliteModelDictionary(sqliteMappings);
''';

        expect(generated, output);
      });
    });
  });
}
