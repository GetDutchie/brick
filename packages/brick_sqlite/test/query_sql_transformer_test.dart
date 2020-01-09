import 'package:brick_core/core.dart' show Query, Where, WherePhrase;
import 'package:brick_sqlite_abstract/db.dart' show InsertTable;
import 'package:brick_sqlite/sqlite.dart';
import 'package:flutter_test/flutter_test.dart' show isMethodCall;
import 'package:sqflite/sqflite.dart' show Database, openDatabase;
import 'package:test/test.dart';
import 'package:brick_sqlite/testing.dart';
import 'package:flutter_test/flutter_test.dart' as ft;

import 'package:brick_sqlite/src/sqlite/query_sql_transformer.dart';
import '__mocks__.dart';

void main() {
  ft.TestWidgetsFlutterBinding.ensureInitialized();

  group("QuerySqlTransformer", () {
    Database db;
    final List<Map<String, dynamic>> responses = [
      {InsertTable.PRIMARY_KEY_COLUMN: 1, 'name': 'Thomas'},
      {InsertTable.PRIMARY_KEY_COLUMN: 2, 'name': 'Guy'},
      {'name': 'John'}
    ];

    setUpAll(() async {
      final provider = SqliteProvider('db.sqlite', modelDictionary: dictionary);
      StubSqlite(provider, responses: {
        DemoModel: responses,
      });
      db = await openDatabase("db.sqlite");
    });

    tearDown(StubSqlite.sqliteLogs.clear);

    void sqliteStatementExpectation(String statement, [List<dynamic> arguments]) {
      final matcher = isMethodCall("query",
          arguments: {"sql": statement, "arguments": arguments ?? [], "id": null});

      return expect(StubSqlite.sqliteLogs, contains(matcher));
    }

    test("empty", () async {
      final statement = "SELECT DISTINCT `DemoModel`.* FROM `DemoModel`";
      final sqliteQuery = QuerySqlTransformer<DemoModel>(modelDictionary: dictionary);
      await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);

      expect(statement, sqliteQuery.statement);
      sqliteStatementExpectation(statement);
    });

    test("where unserialized field", () {
      expect(
        () => QuerySqlTransformer<DemoModel>(
          modelDictionary: dictionary,
          query: Query.where('ignored_column', 1),
        ),
        throwsA(TypeMatcher<ArgumentError>()),
      );
    });

    test("where non association field", () async {
      final statement = 'SELECT DISTINCT `DemoModel`.* FROM `DemoModel` WHERE name = ?';
      final sqliteQuery = QuerySqlTransformer<DemoModel>(
        modelDictionary: dictionary,
        query: Query.where('name', 'Thomas'),
      );
      await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);

      expect(statement, sqliteQuery.statement);
      sqliteStatementExpectation(statement, ['Thomas']);
    });

    test("where association value is not map", () {
      expect(
        () => QuerySqlTransformer<DemoModel>(
          modelDictionary: dictionary,
          query: Query.where('assoc', 1),
        ),
        throwsA(TypeMatcher<ArgumentError>()),
      );
    });

    test("where association value is not map", () {
      expect(
        () => QuerySqlTransformer<DemoModel>(
          modelDictionary: dictionary,
          query: Query.where('assoc', 1),
        ),
        throwsA(TypeMatcher<ArgumentError>()),
      );
    });

    test("compound clause", () async {
      final statement =
          '''SELECT DISTINCT `DemoModel`.* FROM `DemoModel` WHERE (id = ? OR name = ?) AND (id = ? AND name = ?) OR (id = ? AND name = ?)''';
      final sqliteQuery = QuerySqlTransformer<DemoModel>(
        modelDictionary: dictionary,
        query: Query(where: [
          WherePhrase([
            Where<int>('id', 1, required: true),
            Where<String>('name', 'Guy', required: false),
          ]),
          WherePhrase([
            Where<int>('id', 1, required: true),
            Where<String>('name', 'Guy', required: true),
          ], required: true),
          WherePhrase([
            Where<int>('id', 1, required: true),
            Where<String>('name', 'Guy', required: true),
          ]),
        ]),
      );

      expect(sqliteQuery.statement, statement);
      await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);
      sqliteStatementExpectation(statement, [1, 'Guy', 1, 'Guy', 1, 'Guy']);
    });

    test("leading requirement with compound clauses", () async {
      final statement =
          'SELECT DISTINCT `DemoModel`.* FROM `DemoModel` WHERE id = ? AND (name = ? OR name = ?)';
      final sqliteQuery = QuerySqlTransformer<DemoModel>(
        modelDictionary: dictionary,
        query: Query(where: [
          Where('id', 1),
          WherePhrase([
            Where<String>('name', 'Thomas', required: false),
            Where<String>('name', 'Guy', required: false),
          ], required: true),
        ]),
      );

      expect(sqliteQuery.statement, statement);
      await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);
      sqliteStatementExpectation(statement, [1, 'Thomas', 'Guy']);
    });

    group("associations", () {
      test("simple", () async {
        final statement =
            '''SELECT DISTINCT `DemoModel`.* FROM `DemoModel` INNER JOIN `DemoModelAssoc` ON `DemoModel`.assoc_DemoModelAssoc_brick_id = `DemoModelAssoc`._brick_id WHERE `DemoModelAssoc`.id = ?''';
        final sqliteQuery = QuerySqlTransformer<DemoModel>(
          modelDictionary: dictionary,
          query: Query(where: [
            Where<Where>('assoc', Where<int>('id', 1)),
          ]),
        );

        expect(sqliteQuery.statement, statement);
        await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);
        sqliteStatementExpectation(statement, [1]);
      });

      test("OR", () async {
        final statement =
            '''SELECT DISTINCT `DemoModel`.* FROM `DemoModel` INNER JOIN `DemoModelAssoc` ON `DemoModel`.assoc_DemoModelAssoc_brick_id = `DemoModelAssoc`._brick_id WHERE (`DemoModelAssoc`.id = ? OR `DemoModelAssoc`.name = ?)''';
        final sqliteQuery = QuerySqlTransformer<DemoModel>(
          modelDictionary: dictionary,
          query: Query(where: [
            Where<WherePhrase>(
              'assoc',
              WherePhrase([
                Where<int>('id', 1, required: false),
                Where<String>('name', 'Guy', required: false),
              ]),
            ),
          ]),
        );

        expect(sqliteQuery.statement, statement);
        await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);
        sqliteStatementExpectation(statement, [1, 'Guy']);
      });

      test("one-to-many", () {
        final statement =
            '''SELECT DISTINCT `DemoModel`.* FROM `DemoModel` INNER JOIN `DemoModelAssoc` ON `DemoModel`.many_assoc LIKE "%," || `DemoModelAssoc`._brick_id || ",%" OR `DemoModel`.many_assoc LIKE "%," || `DemoModelAssoc`._brick_id || "]" OR `DemoModel`.many_assoc LIKE "[" || `DemoModelAssoc`._brick_id || "]" OR `DemoModel`.many_assoc LIKE "[" || `DemoModelAssoc`._brick_id || ",%" WHERE `DemoModelAssoc`.id = ?''';
        final sqliteQuery = QuerySqlTransformer<DemoModel>(
          modelDictionary: dictionary,
          query: Query(where: [
            Where(
              'manyAssoc',
              Where<int>('id', 1),
            ),
          ]),
        );

        expect(sqliteQuery.statement, statement);
      });
    });

    group("params", () {
      test("params.collate", () async {
        final statement = "SELECT DISTINCT `DemoModel`.* FROM `DemoModel` COLLATE NOCASE";
        final sqliteQuery = QuerySqlTransformer<DemoModel>(
          modelDictionary: dictionary,
          query: Query(params: {'collate': 'NOCASE'}),
        );
        await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);

        expect(statement, sqliteQuery.statement);
        sqliteStatementExpectation(statement);
      });

      test("params.groupBy", () async {
        final statement = "SELECT DISTINCT `DemoModel`.* FROM `DemoModel` GROUP BY id";
        final sqliteQuery = QuerySqlTransformer<DemoModel>(
          modelDictionary: dictionary,
          query: Query(params: {'groupBy': 'id'}),
        );
        await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);

        expect(statement, sqliteQuery.statement);
        sqliteStatementExpectation(statement);
      });

      test("params.having", () async {
        final statement = "SELECT DISTINCT `DemoModel`.* FROM `DemoModel` HAVING id";
        final sqliteQuery = QuerySqlTransformer<DemoModel>(
          modelDictionary: dictionary,
          query: Query(params: {'having': 'id'}),
        );
        await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);

        expect(statement, sqliteQuery.statement);
        sqliteStatementExpectation(statement);
      });

      test("params.limit", () async {
        final statement = "SELECT DISTINCT `DemoModel`.* FROM `DemoModel` LIMIT 1";
        final sqliteQuery = QuerySqlTransformer<DemoModel>(
          modelDictionary: dictionary,
          query: Query(params: {'limit': 1}),
        );
        await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);

        expect(statement, sqliteQuery.statement);
        sqliteStatementExpectation(statement);
      });

      test("params.offset", () async {
        final statement = "SELECT DISTINCT `DemoModel`.* FROM `DemoModel` LIMIT 1 OFFSET 1";
        final sqliteQuery = QuerySqlTransformer<DemoModel>(
          modelDictionary: dictionary,
          query: Query(params: {
            'limit': 1,
            'offset': 1,
          }),
        );
        await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);

        expect(statement, sqliteQuery.statement);
        sqliteStatementExpectation(statement);
      });

      test("params.orderBy", () async {
        final statement = "SELECT DISTINCT `DemoModel`.* FROM `DemoModel` ORDER BY id DESC";
        final sqliteQuery = QuerySqlTransformer<DemoModel>(
          modelDictionary: dictionary,
          query: Query(params: {'orderBy': 'id DESC'}),
        );
        await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);

        expect(statement, sqliteQuery.statement);
        sqliteStatementExpectation(statement);
      });

      test("fields convert to column names in params values", () async {
        final statement =
            'SELECT DISTINCT `DemoModel`.* FROM `DemoModel` ORDER BY complex_field_name ASC GROUP BY complex_field_name HAVING complex_field_name > 1000';
        final sqliteQuery = QuerySqlTransformer<DemoModel>(
          modelDictionary: dictionary,
          query: Query(params: {
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

    group("#values", () {
      test("boolean queries are converted", () {
        final statement =
            '''SELECT DISTINCT `DemoModel`.* FROM `DemoModel` WHERE name = ? OR name = ?''';
        final sqliteQuery = QuerySqlTransformer<DemoModel>(
          modelDictionary: dictionary,
          query: Query(where: [
            Where('name', true, required: false),
            Where('name', false, required: false),
          ]),
        );
        expect(sqliteQuery.statement, statement);
        expect(sqliteQuery.values, [1, 0]);
      });
    });
  });
}
