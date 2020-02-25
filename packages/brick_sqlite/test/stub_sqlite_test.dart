import 'package:brick_core/query.dart';
import 'package:brick_sqlite_abstract/db.dart';
import 'package:brick_sqlite/sqlite.dart';
import 'package:brick_sqlite/testing.dart';
import 'package:flutter/services.dart';
import 'package:test/test.dart';
import 'package:flutter_test/flutter_test.dart' as ft;

import '__mocks__.dart';

void main() {
  ft.TestWidgetsFlutterBinding.ensureInitialized();

  group('StubSqlite', () {
    group('.returnFromResponses', () {
      final List<Map<String, dynamic>> responses = [
        {'name': 'Thomas'},
        {'name': 'Guy'},
      ];

      test('insert', () {
        final result = StubSqlite.returnFromResponses(
          responses: responses,
          tableName: 'MyTable',
          methodCall: MethodCall('insert', {'sql': 'INSERT INTO `MyTable`'}),
        );
        expect(result, 3);
      });

      test('count', () {
        final result = StubSqlite.returnFromResponses(
          responses: responses,
          tableName: 'MyTable',
          methodCall: MethodCall('select', {'sql': 'SELECT COUNT(*) FROM `MyTable`'}),
        );
        expect(result, [
          {'COUNT(*)': 2}
        ]);
      });

      group('delete', () {
        test('simple', () {
          final result = StubSqlite.returnFromResponses(
            responses: responses,
            tableName: 'MyTable',
            methodCall: MethodCall('delete', {'sql': 'DELETE FROM `MyTable`'}),
          );
          expect(result, 2);
        });

        test('query by string', () {
          final result = StubSqlite.returnFromResponses(
            responses: responses,
            tableName: 'MyTable',
            methodCall: MethodCall('delete', {
              'sql': 'DELETE FROM `MyTable` WHERE name = ?',
              'arguments': ['Thomas']
            }),
          );
          expect(result, 1);
        });

        test('query doesn\'t match string', () {
          final result = StubSqlite.returnFromResponses(
            responses: responses,
            tableName: 'MyTable',
            methodCall: MethodCall('delete', {
              'sql': 'DELETE FROM `MyTable` WHERE name = ?',
              'arguments': ['Alice']
            }),
          );
          expect(result, 0);
        });
      });

      group('select', () {
        test('simple', () {
          final result = StubSqlite.returnFromResponses(
            responses: responses,
            tableName: 'MyTable',
            methodCall: MethodCall('select', {'sql': 'SELECT DISTINCT * FROM `MyTable`'}),
          );
          expect(result, responses);
        });

        test('query by string', () {
          final result = StubSqlite.returnFromResponses(
            responses: responses,
            tableName: 'MyTable',
            methodCall: MethodCall('select', {
              'sql': 'SELECT DISTINCT * FROM `MyTable` WHERE name = ?',
              'arguments': ['Thomas']
            }),
          );
          expect(result, [
            {'name': 'Thomas', InsertTable.PRIMARY_KEY_COLUMN: 1}
          ]);
        });

        test('query doesn\'t match string', () {
          final result = StubSqlite.returnFromResponses(
            responses: responses,
            tableName: 'MyTable',
            methodCall: MethodCall('select', {
              'sql': 'SELECT DISTINCT * FROM `MyTable` WHERE name = ?',
              'arguments': ['Alice']
            }),
          );
          expect(result, [{}]);
        });

        test('query by bool', () async {
          final provider = SqliteProvider('db.sqlite', modelDictionary: dictionary);
          final responses = [
            {InsertTable.PRIMARY_KEY_COLUMN: 1, 'name': 'Thomas', 'simple_bool': false},
            {InsertTable.PRIMARY_KEY_COLUMN: 2, 'name': 'Guy', 'simple_bool': true},
          ];

          StubSqlite(provider, responses: {DemoModel: responses});
          final results = await provider.get<DemoModel>(
            query: Query.where('simpleBool', false),
          );
          expect(results, isNotEmpty);
          expect(results.first.name, 'Thomas');
        });
      });

      test('update', () {}, skip: true);
    });
  });

  test('.statementIncludesModel', () {
    final select = StubSqlite.statementIncludesModel(
        'MyTable', MethodCall('select', {'sql': 'SELECT * FROM `MyTable`'}));
    final insert = StubSqlite.statementIncludesModel(
        'MyTable', MethodCall('insert', {'sql': 'INSERT INTO `MyTable`'}));
    final delete = StubSqlite.statementIncludesModel(
        'MyTable', MethodCall('insert', {'sql': 'DELETE FROM `MyTable`'}));

    expect(select, isTrue);
    expect(insert, isTrue);
    expect(delete, isTrue);
  });

  test('.addPrimaryKeysToResponses', () {
    final List<Map<String, dynamic>> responses = [
      {'name': 'Thomas'},
      {'name': 'Guy'},
    ];

    final convertedResponses = StubSqlite.addPrimaryKeysToResponses(responses);
    expect(convertedResponses, [
      {InsertTable.PRIMARY_KEY_COLUMN: 1, 'name': 'Thomas'},
      {InsertTable.PRIMARY_KEY_COLUMN: 2, 'name': 'Guy'},
    ]);
  });

  test('.convertBoolValuesToInt', () {
    final responses = [
      {'name': 'Thomas', 'simple_bool': false},
      {'name': 'Guy', 'simple_bool': true},
    ];

    final convertedResponses = StubSqlite.convertBoolValuesToInt(responses);
    expect(convertedResponses, [
      {'name': 'Thomas', 'simple_bool': 0},
      {'name': 'Guy', 'simple_bool': 1},
    ]);
  });

  test('.queryToMap', () {
    final methodArguments = {
      'sql':
          'SELECT * FROM atable WHERE name = ? AND simple_bool = ? OR (another_column = ? AND other_column = ?) LIMIT 1 ORDER BY name ASC',
      'arguments': ['Thomas', true, 1, 17],
    };

    final queryAsMap = StubSqlite.queryToMap(methodArguments);
    expect(queryAsMap, {
      'name': 'Thomas',
      'simple_bool': true,
      'another_column': 1,
      'other_column': 17,
    });
  });
}
