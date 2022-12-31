import 'package:brick_core/query.dart';
import 'package:test/test.dart';
import 'package:sqflite_common/src/mixin/factory.dart';
import 'package:sqflite_common/sqlite_api.dart';

import 'package:brick_sqlite/src/helpers/query_sql_transformer.dart';
import '__mocks__.dart';

class _FakeMethodCall {
  final String method;
  final String? sqlStatement;
  final dynamic arguments;
  final int? id;
  final bool rawFactory;

  _FakeMethodCall(
    this.method,
    this.arguments, {
    this.sqlStatement,
    this.id,
    this.rawFactory = false,
  });

  factory _FakeMethodCall.fromFactory(String method, dynamic arguments) {
    return _FakeMethodCall(method, arguments, rawFactory: true);
  }

  @override
  String toString() {
    if (rawFactory) return '$method $arguments';
    return '$method {sql: $sqlStatement, arguments: $arguments, id: $id}';
  }
}

void main() {
  group('QuerySqlTransformer', () {
    late Database db;
    var sqliteLogs = <_FakeMethodCall>[];
    final stub = buildDatabaseFactory(invokeMethod: (String method, [dynamic arguments]) async {
      sqliteLogs.add(_FakeMethodCall.fromFactory(method, arguments));

      if (method == 'getDatabasesPath') return 'db.sqlite';
      if (method == 'openDatabase') return Future.value(1);
      return [];
    });

    setUpAll(() async {
      db = await stub.openDatabase('db.sqlite');
    });

    tearDown(sqliteLogs.clear);

    void sqliteStatementExpectation(String statement, [List<dynamic>? arguments]) {
      final matcher = _FakeMethodCall('query', arguments ?? [], sqlStatement: statement, id: 1);

      return expect(sqliteLogs.map((l) => l.toString()), contains(matcher.toString()));
    }

    test('empty', () async {
      const statement = 'SELECT DISTINCT `DemoModel`.* FROM `DemoModel`';
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
        throwsA(const TypeMatcher<ArgumentError>()),
      );
    });

    test('where non association field', () async {
      const statement = 'SELECT DISTINCT `DemoModel`.* FROM `DemoModel` WHERE full_name = ?';
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
        throwsA(const TypeMatcher<ArgumentError>()),
      );
    });

    test('compound clause', () async {
      const statement =
          '''SELECT DISTINCT `DemoModel`.* FROM `DemoModel` WHERE (id = ? OR full_name = ?) AND (id = ? AND full_name = ?) OR (id = ? AND full_name = ?)''';
      final sqliteQuery = QuerySqlTransformer<DemoModel>(
        modelDictionary: dictionary,
        query: Query(where: [
          WherePhrase([
            Where.exact('id', 1),
            const Or('name').isExactly('Guy'),
          ]),
          WherePhrase([
            Where.exact('id', 1),
            Where.exact('name', 'Guy'),
          ], isRequired: true),
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
      const statement =
          'SELECT DISTINCT `DemoModel`.* FROM `DemoModel` WHERE id = ? AND (full_name = ? OR full_name = ?)';
      final sqliteQuery = QuerySqlTransformer<DemoModel>(
        modelDictionary: dictionary,
        query: Query(where: [
          Where.exact('id', 1),
          WherePhrase([
            const Or('name').isExactly('Thomas'),
            const Or('name').isExactly('Guy'),
          ], isRequired: true),
        ]),
      );

      expect(sqliteQuery.statement, statement);
      await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);
      sqliteStatementExpectation(statement, [1, 'Thomas', 'Guy']);
    });

    group('Compare', () {
      test('.doesNotContain', () async {
        const statement =
            'SELECT DISTINCT `DemoModel`.* FROM `DemoModel` WHERE full_name NOT LIKE ?';
        final sqliteQuery = QuerySqlTransformer<DemoModel>(
          modelDictionary: dictionary,
          query: Query(where: [
            const Where('name').doesNotContain('Thomas'),
          ]),
        );

        expect(sqliteQuery.statement, statement);
        await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);
        sqliteStatementExpectation(statement, ['%Thomas%']);
      });
    });

    group('SELECT COUNT', () {
      test('basic', () async {
        const statement = 'SELECT COUNT(*) FROM `DemoModel`';
        final sqliteQuery = QuerySqlTransformer<DemoModel>(
          modelDictionary: dictionary,
          selectStatement: false,
        );

        expect(sqliteQuery.statement, statement);
        await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);
        sqliteStatementExpectation(statement);
      });

      test('simple', () async {
        const statement =
            'SELECT COUNT(*) FROM `DemoModel` WHERE (id = ? OR full_name = ?) AND (id = ? AND full_name = ?) OR (id = ? AND full_name = ?)';
        final sqliteQuery = QuerySqlTransformer<DemoModel>(
          modelDictionary: dictionary,
          query: Query(where: [
            WherePhrase([
              Where.exact('id', 1),
              const Or('name').isExactly('Guy'),
            ]),
            WherePhrase([
              Where.exact('id', 1),
              Where.exact('name', 'Guy'),
            ], isRequired: true),
            WherePhrase([
              Where.exact('id', 1),
              Where.exact('name', 'Guy'),
            ]),
          ]),
          selectStatement: false,
        );

        expect(sqliteQuery.statement, statement);
        await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);
        sqliteStatementExpectation(statement, [1, 'Guy', 1, 'Guy', 1, 'Guy']);
      });

      test('associations', () async {
        const statement =
            'SELECT COUNT(*) FROM `DemoModel` INNER JOIN `DemoModelAssoc` ON `DemoModel`.assoc_DemoModelAssoc_brick_id = `DemoModelAssoc`._brick_id WHERE `DemoModelAssoc`.id = ?';
        final sqliteQuery = QuerySqlTransformer<DemoModel>(
          modelDictionary: dictionary,
          query: Query(where: [
            Where.exact('assoc', Where.exact('id', 1)),
          ]),
          selectStatement: false,
        );

        expect(sqliteQuery.statement, statement);
        await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);
        sqliteStatementExpectation(statement, [1]);
      });

      test('same-named fields on associations', () async {
        const statement =
            'SELECT COUNT(*) FROM `DemoModel` INNER JOIN `DemoModelAssoc` ON `DemoModel`.assoc_DemoModelAssoc_brick_id = `DemoModelAssoc`._brick_id WHERE `DemoModelAssoc`.id = ? AND `DemoModel`.id = ?';
        final sqliteQuery = QuerySqlTransformer<DemoModel>(
          modelDictionary: dictionary,
          query: Query(where: [
            Where.exact('assoc', Where.exact('id', 1)),
            Where.exact('id', 1),
          ]),
          selectStatement: false,
        );

        expect(sqliteQuery.statement, statement);
        await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);
        sqliteStatementExpectation(statement, [1, 1]);
      });

      test('without any where arguments', () async {
        const statement = 'SELECT COUNT(*) FROM `DemoModel`';
        String? nilValue;
        final sqliteQuery = QuerySqlTransformer<DemoModel>(
          modelDictionary: dictionary,
          query: Query(
            where: [
              WherePhrase([
                if (nilValue != null) const And('name').isExactly('John'),
              ], isRequired: false),
            ],
          ),
          selectStatement: false,
        );

        expect(sqliteQuery.statement, statement);
        await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);
        sqliteStatementExpectation(statement, []);
      });
    });

    group('associations', () {
      test('simple', () async {
        const statement =
            'SELECT DISTINCT `DemoModel`.* FROM `DemoModel` INNER JOIN `DemoModelAssoc` ON `DemoModel`.assoc_DemoModelAssoc_brick_id = `DemoModelAssoc`._brick_id WHERE `DemoModelAssoc`.id = ?';
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

      test('nested association', () async {
        const statement =
            'SELECT DISTINCT `DemoModel`.* FROM `DemoModel` INNER JOIN `_brick_DemoModel_many_assoc` ON `DemoModel`._brick_id = `_brick_DemoModel_many_assoc`.l_DemoModel_brick_id INNER JOIN `DemoModelAssoc` ON `DemoModelAssoc`._brick_id = `_brick_DemoModel_many_assoc`.f_DemoModelAssoc_brick_id WHERE `DemoModelAssoc`.full_name = ?';
        final sqliteQuery = QuerySqlTransformer<DemoModel>(
          modelDictionary: dictionary,
          query: Query(where: [
            Where.exact('manyAssoc', Where.exact('assoc', Where.exact('name', 1))),
          ]),
        );

        expect(sqliteQuery.statement, statement);
        await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);
        sqliteStatementExpectation(statement, [1]);
      });

      test('OR', () async {
        const statement =
            'SELECT DISTINCT `DemoModel`.* FROM `DemoModel` INNER JOIN `DemoModelAssoc` ON `DemoModel`.assoc_DemoModelAssoc_brick_id = `DemoModelAssoc`._brick_id WHERE (`DemoModelAssoc`.id = ? OR `DemoModelAssoc`.full_name = ?)';
        final sqliteQuery = QuerySqlTransformer<DemoModel>(
          modelDictionary: dictionary,
          query: Query(where: [
            Where.exact(
              'assoc',
              WherePhrase([
                const Or('id').isExactly(1),
                const Or('name').isExactly('Guy'),
              ]),
            ),
          ]),
        );

        expect(sqliteQuery.statement, statement);
        await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);
        sqliteStatementExpectation(statement, [1, 'Guy']);
      });

      test('one-to-many', () {
        const statement =
            'SELECT DISTINCT `DemoModel`.* FROM `DemoModel` INNER JOIN `_brick_DemoModel_many_assoc` ON `DemoModel`._brick_id = `_brick_DemoModel_many_assoc`.l_DemoModel_brick_id INNER JOIN `DemoModelAssoc` ON `DemoModelAssoc`._brick_id = `_brick_DemoModel_many_assoc`.f_DemoModelAssoc_brick_id WHERE `DemoModelAssoc`.id = ?';
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
        const statement = 'SELECT DISTINCT `DemoModel`.* FROM `DemoModel` COLLATE NOCASE';
        final sqliteQuery = QuerySqlTransformer<DemoModel>(
          modelDictionary: dictionary,
          query: Query(providerArgs: {'collate': 'NOCASE'}),
        );
        await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);

        expect(statement, sqliteQuery.statement);
        sqliteStatementExpectation(statement);
      });

      test('providerArgs.groupBy', () async {
        const statement = 'SELECT DISTINCT `DemoModel`.* FROM `DemoModel` GROUP BY id';
        final sqliteQuery = QuerySqlTransformer<DemoModel>(
          modelDictionary: dictionary,
          query: Query(providerArgs: {'groupBy': 'id'}),
        );
        await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);

        expect(statement, sqliteQuery.statement);
        sqliteStatementExpectation(statement);
      });

      test('providerArgs.having', () async {
        const statement = 'SELECT DISTINCT `DemoModel`.* FROM `DemoModel` HAVING id';
        final sqliteQuery = QuerySqlTransformer<DemoModel>(
          modelDictionary: dictionary,
          query: Query(providerArgs: {'having': 'id'}),
        );
        await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);

        expect(statement, sqliteQuery.statement);
        sqliteStatementExpectation(statement);
      });

      test('providerArgs.limit', () async {
        const statement = 'SELECT DISTINCT `DemoModel`.* FROM `DemoModel` LIMIT 1';
        final sqliteQuery = QuerySqlTransformer<DemoModel>(
          modelDictionary: dictionary,
          query: Query(providerArgs: {'limit': 1}),
        );
        await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);

        expect(statement, sqliteQuery.statement);
        sqliteStatementExpectation(statement);
      });

      test('providerArgs.offset', () async {
        const statement = 'SELECT DISTINCT `DemoModel`.* FROM `DemoModel` LIMIT 1 OFFSET 1';
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
          const statement = 'SELECT DISTINCT `DemoModel`.* FROM `DemoModel` ORDER BY id DESC';
          final sqliteQuery = QuerySqlTransformer<DemoModel>(
            modelDictionary: dictionary,
            query: Query(providerArgs: {'orderBy': 'id DESC'}),
          );
          await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);

          expect(statement, sqliteQuery.statement);
          sqliteStatementExpectation(statement);
        });

        test('discovered columns share similar names', () async {
          const statement =
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
        const statement = 'SELECT DISTINCT `DemoModel`.* FROM `DemoModel` ORDER BY many_assoc DESC';
        final sqliteQuery = QuerySqlTransformer<DemoModel>(
          modelDictionary: dictionary,
          query: Query(providerArgs: {'orderBy': 'manyAssoc DESC'}),
        );
        await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);

        expect(statement, sqliteQuery.statement);
        sqliteStatementExpectation(statement);
      });

      test('providerArgs.orderBy compound values are expanded to column names', () async {
        const statement =
            'SELECT DISTINCT `DemoModel`.* FROM `DemoModel` ORDER BY many_assoc DESC, complex_field_name ASC';
        final sqliteQuery = QuerySqlTransformer<DemoModel>(
          modelDictionary: dictionary,
          query: Query(providerArgs: {
            'orderBy': 'manyAssoc DESC, complexFieldName ASC',
          }),
        );
        await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);

        expect(statement, sqliteQuery.statement);
        sqliteStatementExpectation(statement);
      });

      test('fields convert to column names in providerArgs values', () async {
        const statement =
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

      test('date time is converted', () async {
        final statement =
            'SELECT DISTINCT `DemoModel`.* FROM `DemoModel` ORDER BY datetime(simple_time) DESC';
        final sqliteQuery = QuerySqlTransformer<DemoModel>(
          modelDictionary: dictionary,
          query: Query(providerArgs: {'orderBy': 'simpleTime DESC'}),
        );
        await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);

        expect(statement, sqliteQuery.statement);
        sqliteStatementExpectation(statement);
      });
    });

    group('#values', () {
      test('boolean queries are converted', () {
        const statement =
            '''SELECT DISTINCT `DemoModel`.* FROM `DemoModel` WHERE full_name = ? OR full_name = ?''';
        final sqliteQuery = QuerySqlTransformer<DemoModel>(
          modelDictionary: dictionary,
          query: Query(where: [
            const Or('name').isExactly(true),
            const Or('name').isExactly(false),
          ]),
        );
        expect(sqliteQuery.statement, statement);
        expect(sqliteQuery.values, [1, 0]);
      });
    });
  });
}
