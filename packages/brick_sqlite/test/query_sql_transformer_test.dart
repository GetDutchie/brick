import 'package:brick_core/query.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart' show isMethodCall;
import 'package:sqflite/sqflite.dart' show Database, openDatabase;
import 'package:test/test.dart';
import 'package:flutter_test/flutter_test.dart' as ft;

import 'package:brick_sqlite/src/sqlite/query_sql_transformer.dart';
import '__mocks__.dart';

void main() {
  ft.TestWidgetsFlutterBinding.ensureInitialized();

  group('QuerySqlTransformer', () {
    Database db;
    var sqliteLogs = <MethodCall>[];

    MethodChannel('com.tekartik.sqflite').setMockMethodCallHandler((methodCall) {
      sqliteLogs.add(methodCall);

      if (methodCall.method == 'getDatabasesPath') {
        return Future.value('db');
      }

      return Future.value(null);
    });

    setUpAll(() async {
      db = await openDatabase('db.sqlite');
    });

    tearDown(sqliteLogs.clear);

    void sqliteStatementExpectation(String statement, [List<dynamic> arguments]) {
      final matcher = isMethodCall('query',
          arguments: {'sql': statement, 'arguments': arguments ?? [], 'id': null});

      return expect(sqliteLogs, contains(matcher));
    }

    test('empty', () async {
      final statement = 'SELECT DISTINCT `DemoModel`.* FROM `DemoModel`';
      final sqliteQuery = QuerySqlTransformer<DemoModel>(modelDictionary: dictionary);
      await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);

      expect(statement, sqliteQuery.statement);
      sqliteStatementExpectation(statement);
    });

    test('where unserialized field', () {
      expect(
        () => QuerySqlTransformer<DemoModel>(
          modelDictionary: dictionary,
          query: Query.where('ignored_column', 1),
        ),
        throwsA(TypeMatcher<ArgumentError>()),
      );
    });

    test('where non association field', () async {
      final statement = 'SELECT DISTINCT `DemoModel`.* FROM `DemoModel` WHERE full_name = ?';
      final sqliteQuery = QuerySqlTransformer<DemoModel>(
        modelDictionary: dictionary,
        query: Query.where('name', 'Thomas'),
      );
      await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);

      expect(statement, sqliteQuery.statement);
      sqliteStatementExpectation(statement, ['Thomas']);
    });

    test('where association value is not map', () {
      expect(
        () => QuerySqlTransformer<DemoModel>(
          modelDictionary: dictionary,
          query: Query.where('assoc', 1),
        ),
        throwsA(TypeMatcher<ArgumentError>()),
      );
    });

    test('where association value is not map', () {
      expect(
        () => QuerySqlTransformer<DemoModel>(
          modelDictionary: dictionary,
          query: Query.where('assoc', 1),
        ),
        throwsA(TypeMatcher<ArgumentError>()),
      );
    });

    test('compound clause', () async {
      final statement =
          '''SELECT DISTINCT `DemoModel`.* FROM `DemoModel` WHERE (id = ? OR full_name = ?) AND (id = ? AND full_name = ?) OR (id = ? AND full_name = ?)''';
      final sqliteQuery = QuerySqlTransformer<DemoModel>(
        modelDictionary: dictionary,
        query: Query(where: [
          WherePhrase([
            Where.exact('id', 1),
            Or('name').isExactly('Guy'),
          ]),
          WherePhrase([
            Where.exact('id', 1),
            Where.exact('name', 'Guy'),
          ], required: true),
          WherePhrase([
            Where.exact('id', 1),
            Where.exact('name', 'Guy'),
          ]),
        ]),
      );

      expect(sqliteQuery.statement, statement);
      await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);
      sqliteStatementExpectation(statement, [1, 'Guy', 1, 'Guy', 1, 'Guy']);
    });

    test('leading requirement with compound clauses', () async {
      final statement =
          'SELECT DISTINCT `DemoModel`.* FROM `DemoModel` WHERE id = ? AND (full_name = ? OR full_name = ?)';
      final sqliteQuery = QuerySqlTransformer<DemoModel>(
        modelDictionary: dictionary,
        query: Query(where: [
          Where.exact('id', 1),
          WherePhrase([
            Or('name').isExactly('Thomas'),
            Or('name').isExactly('Guy'),
          ], required: true),
        ]),
      );

      expect(sqliteQuery.statement, statement);
      await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);
      sqliteStatementExpectation(statement, [1, 'Thomas', 'Guy']);
    });

    group('associations', () {
      test('simple', () async {
        final statement =
            '''SELECT DISTINCT `DemoModel`.* FROM `DemoModel` INNER JOIN `DemoModelAssoc` ON `DemoModel`.assoc_DemoModelAssoc_brick_id = `DemoModelAssoc`._brick_id WHERE `DemoModelAssoc`.id = ?''';
        final sqliteQuery = QuerySqlTransformer<DemoModel>(
          modelDictionary: dictionary,
          query: Query(where: [
            Where.exact('assoc', Where.exact('id', 1)),
          ]),
        );

        expect(sqliteQuery.statement, statement);
        await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);
        sqliteStatementExpectation(statement, [1]);
      });

      test('OR', () async {
        final statement =
            '''SELECT DISTINCT `DemoModel`.* FROM `DemoModel` INNER JOIN `DemoModelAssoc` ON `DemoModel`.assoc_DemoModelAssoc_brick_id = `DemoModelAssoc`._brick_id WHERE (`DemoModelAssoc`.id = ? OR `DemoModelAssoc`.full_name = ?)''';
        final sqliteQuery = QuerySqlTransformer<DemoModel>(
          modelDictionary: dictionary,
          query: Query(where: [
            Where.exact(
              'assoc',
              WherePhrase([
                Or('id').isExactly(1),
                Or('name').isExactly('Guy'),
              ]),
            ),
          ]),
        );

        expect(sqliteQuery.statement, statement);
        await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);
        sqliteStatementExpectation(statement, [1, 'Guy']);
      });

      test('one-to-many', () {
        final statement =
            '''SELECT DISTINCT `DemoModel`.* FROM `DemoModel` INNER JOIN `DemoModelAssoc` ON INNER JOIN `_brick_DemoModel_many_assoc` ON `DemoModel`._brick_id = `_brick_DemoModel_many_assoc`.DemoModel_brick_id WHERE `DemoModelAssoc`.id = ?''';
        final sqliteQuery = QuerySqlTransformer<DemoModel>(
          modelDictionary: dictionary,
          query: Query(where: [
            Where.exact(
              'manyAssoc',
              Where.exact('id', 1),
            ),
          ]),
        );

        expect(sqliteQuery.statement, statement);
      });
    });

    group('providerArgs', () {
      test('providerArgs.collate', () async {
        final statement = 'SELECT DISTINCT `DemoModel`.* FROM `DemoModel` COLLATE NOCASE';
        final sqliteQuery = QuerySqlTransformer<DemoModel>(
          modelDictionary: dictionary,
          query: Query(providerArgs: {'collate': 'NOCASE'}),
        );
        await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);

        expect(statement, sqliteQuery.statement);
        sqliteStatementExpectation(statement);
      });

      test('providerArgs.groupBy', () async {
        final statement = 'SELECT DISTINCT `DemoModel`.* FROM `DemoModel` GROUP BY id';
        final sqliteQuery = QuerySqlTransformer<DemoModel>(
          modelDictionary: dictionary,
          query: Query(providerArgs: {'groupBy': 'id'}),
        );
        await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);

        expect(statement, sqliteQuery.statement);
        sqliteStatementExpectation(statement);
      });

      test('providerArgs.having', () async {
        final statement = 'SELECT DISTINCT `DemoModel`.* FROM `DemoModel` HAVING id';
        final sqliteQuery = QuerySqlTransformer<DemoModel>(
          modelDictionary: dictionary,
          query: Query(providerArgs: {'having': 'id'}),
        );
        await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);

        expect(statement, sqliteQuery.statement);
        sqliteStatementExpectation(statement);
      });

      test('providerArgs.limit', () async {
        final statement = 'SELECT DISTINCT `DemoModel`.* FROM `DemoModel` LIMIT 1';
        final sqliteQuery = QuerySqlTransformer<DemoModel>(
          modelDictionary: dictionary,
          query: Query(providerArgs: {'limit': 1}),
        );
        await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);

        expect(statement, sqliteQuery.statement);
        sqliteStatementExpectation(statement);
      });

      test('providerArgs.offset', () async {
        final statement = 'SELECT DISTINCT `DemoModel`.* FROM `DemoModel` LIMIT 1 OFFSET 1';
        final sqliteQuery = QuerySqlTransformer<DemoModel>(
          modelDictionary: dictionary,
          query: Query(providerArgs: {
            'limit': 1,
            'offset': 1,
          }),
        );
        await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);

        expect(statement, sqliteQuery.statement);
        sqliteStatementExpectation(statement);
      });

      group('providerArgs.orderBy', () {
        test('simple', () async {
          final statement = 'SELECT DISTINCT `DemoModel`.* FROM `DemoModel` ORDER BY id DESC';
          final sqliteQuery = QuerySqlTransformer<DemoModel>(
            modelDictionary: dictionary,
            query: Query(providerArgs: {'orderBy': 'id DESC'}),
          );
          await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);

          expect(statement, sqliteQuery.statement);
          sqliteStatementExpectation(statement);
        });

        test('discovered columns share similar names', () async {
          final statement =
              'SELECT DISTINCT `DemoModel`.* FROM `DemoModel` ORDER BY last_name DESC';
          final sqliteQuery = QuerySqlTransformer<DemoModel>(
            modelDictionary: dictionary,
            query: Query(providerArgs: {'orderBy': 'lastName DESC'}),
          );
          await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);

          expect(statement, sqliteQuery.statement);
          sqliteStatementExpectation(statement);
        });
      });

      test('providerArgs.orderBy expands field names to column names', () async {
        final statement = 'SELECT DISTINCT `DemoModel`.* FROM `DemoModel` ORDER BY many_assoc DESC';
        final sqliteQuery = QuerySqlTransformer<DemoModel>(
          modelDictionary: dictionary,
          query: Query(providerArgs: {'orderBy': 'manyAssoc DESC'}),
        );
        await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);

        expect(statement, sqliteQuery.statement);
        sqliteStatementExpectation(statement);
      });

      test('fields convert to column names in providerArgs values', () async {
        final statement =
            'SELECT DISTINCT `DemoModel`.* FROM `DemoModel` ORDER BY complex_field_name ASC GROUP BY complex_field_name HAVING complex_field_name > 1000';
        final sqliteQuery = QuerySqlTransformer<DemoModel>(
          modelDictionary: dictionary,
          query: Query(providerArgs: {
            'orderBy': 'complexFieldName ASC',
            'having': 'complexFieldName > 1000',
            'groupBy': 'complexFieldName',
          }),
        );

        await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);

        expect(statement, sqliteQuery.statement);
        sqliteStatementExpectation(statement);
      });
    });

    group('#values', () {
      test('boolean queries are converted', () {
        final statement =
            '''SELECT DISTINCT `DemoModel`.* FROM `DemoModel` WHERE full_name = ? OR full_name = ?''';
        final sqliteQuery = QuerySqlTransformer<DemoModel>(
          modelDictionary: dictionary,
          query: Query(where: [
            Or('name').isExactly(true),
            Or('name').isExactly(false),
          ]),
        );
        expect(sqliteQuery.statement, statement);
        expect(sqliteQuery.values, [1, 0]);
      });
    });
  });
}
