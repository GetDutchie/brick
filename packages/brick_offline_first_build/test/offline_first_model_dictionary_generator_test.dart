import 'package:test/test.dart';
import 'package:brick_offline_first_build/src/offline_first_model_dictionary_generator.dart';

void main() {
  group('OfflineFirstModelDictionaryGenerator', () {
    group('#generate', () {
      test('basic', () {
        final generated = OfflineFirstModelDictionaryGenerator('Rest')
            .generate({'Person': 'person.dart', 'User': 'path/user.dart'});
        final output = r'''
// GENERATED CODE DO NOT EDIT
// This file should NOT be version controlled and should not be manually edited.
// ignore: unused_import
import 'dart:convert';
import 'package:brick_sqlite/sqlite.dart' show SqliteModel, SqliteAdapter, SqliteModelDictionary, RuntimeSqliteColumnDefinition;
import 'package:brick_rest/rest.dart' show RestProvider, RestModel, RestAdapter, RestModelDictionary;
// ignore: unused_import, unused_shown_name
import 'package:sqflite/sqflite.dart' show DatabaseExecutor;

import 'models/person.dart';
import 'models/path/user.dart';

part 'adapters/person_adapter.g.dart';
part 'adapters/user_adapter.g.dart';

/// REST mappings should only be used when initializing a [RestProvider]
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
