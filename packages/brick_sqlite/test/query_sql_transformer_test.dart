import 'package:brick_core/query.dart';
import 'package:brick_sqlite/src/helpers/query_sql_transformer.dart';
import 'package:brick_sqlite/src/sqlite_provider_query.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common/src/mixin/factory.dart';
import 'package:test/test.dart';

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

  factory _FakeMethodCall.fromFactory(String method, dynamic arguments) =>
      _FakeMethodCall(method, arguments, rawFactory: true);

  @override
  String toString() {
    if (rawFactory) return '$method $arguments';
    return '$method {sql: $sqlStatement, arguments: $arguments, id: $id}';
  }
}

void main() {
  group('QuerySqlTransformer', () {
    late Database db;
    final sqliteLogs = <_FakeMethodCall>[];
    final stub = buildDatabaseFactory(
      invokeMethod: (String method, [dynamic arguments]) async {
        sqliteLogs.add(_FakeMethodCall.fromFactory(method, arguments));

        if (method == 'getDatabasesPath') return 'db.sqlite';
        if (method == 'openDatabase') return Future.value(1);
        return [];
      },
    );

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
        query: Query(
          where: [
            WherePhrase([
              const Where.exact('id', 1),
              const Or('name').isExactly('Guy'),
            ]),
            const WherePhrase(
              [
                Where.exact('id', 1),
                Where.exact('name', 'Guy'),
              ],
              isRequired: true,
            ),
            const WherePhrase([
              Where.exact('id', 1),
              Where.exact('name', 'Guy'),
            ]),
          ],
        ),
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
        query: Query(
          where: [
            const Where.exact('id', 1),
            WherePhrase(
              [
                const Or('name').isExactly('Thomas'),
                const Or('name').isExactly('Guy'),
              ],
              isRequired: true,
            ),
          ],
        ),
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
          query: Query(
            where: [
              const Where('name').doesNotContain('Thomas'),
            ],
          ),
        );

        expect(sqliteQuery.statement, statement);
        await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);
        sqliteStatementExpectation(statement, ['%Thomas%']);
      });

      test('.inIterable', () async {
        const statement =
            'SELECT DISTINCT `DemoModel`.* FROM `DemoModel` WHERE full_name IN (?, ?)';
        final sqliteQuery = QuerySqlTransformer<DemoModel>(
          modelDictionary: dictionary,
          query: Query(
            where: [
              const Where('name').isIn(['Thomas', 'Guy']),
            ],
          ),
        );

        expect(sqliteQuery.statement, statement);
        await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);
        sqliteStatementExpectation(statement, ['Thomas', 'Guy']);
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
          query: Query(
            where: [
              WherePhrase([
                const Where.exact('id', 1),
                const Or('name').isExactly('Guy'),
              ]),
              const WherePhrase(
                [
                  Where.exact('id', 1),
                  Where.exact('name', 'Guy'),
                ],
                isRequired: true,
              ),
              const WherePhrase([
                Where.exact('id', 1),
                Where.exact('name', 'Guy'),
              ]),
            ],
          ),
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
          query: const Query(
            where: [
              Where.exact('assoc', Where.exact('id', 1)),
            ],
          ),
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
          query: const Query(
            where: [
              Where.exact('assoc', Where.exact('id', 1)),
              Where.exact('id', 1),
            ],
          ),
          selectStatement: false,
        );

        expect(sqliteQuery.statement, statement);
        await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);
        sqliteStatementExpectation(statement, [1, 1]);
      });

      test('without any where arguments', () async {
        const statement = 'SELECT COUNT(*) FROM `DemoModel`';
        final sqliteQuery = QuerySqlTransformer<DemoModel>(
          modelDictionary: dictionary,
          query: const Query(
            where: [
              WherePhrase([], isRequired: false),
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
          query: const Query(
            where: [
              Where.exact('assoc', Where.exact('id', 1)),
            ],
          ),
        );

        expect(sqliteQuery.statement, statement);
        await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);
        sqliteStatementExpectation(statement, [1]);
      });

      test('same field', () async {
        const statement =
            'SELECT DISTINCT `DemoModel`.* FROM `DemoModel` INNER JOIN `DemoModelAssoc` ON `DemoModel`.assoc_DemoModelAssoc_brick_id = `DemoModelAssoc`._brick_id WHERE `DemoModelAssoc`.id = ? AND `DemoModel`.id = ? ORDER BY `DemoModel`.id ASC';
        final sqliteQuery = QuerySqlTransformer<DemoModel>(
          modelDictionary: dictionary,
          query: const Query(
            where: [
              Where.exact('assoc', Where.exact('id', 1)),
              Where.exact('id', 2),
            ],
            orderBy: [OrderBy.asc('id')],
          ),
        );

        expect(sqliteQuery.statement, statement);
        await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);
        sqliteStatementExpectation(statement, [1, 2]);
      });

      test('same field reverse order', () async {
        const statement =
            'SELECT DISTINCT `DemoModel`.* FROM `DemoModel` INNER JOIN `DemoModelAssoc` ON `DemoModel`.assoc_DemoModelAssoc_brick_id = `DemoModelAssoc`._brick_id WHERE `DemoModel`.id = ? AND `DemoModelAssoc`.id = ? ORDER BY `DemoModel`.id ASC';
        final sqliteQuery = QuerySqlTransformer<DemoModel>(
          modelDictionary: dictionary,
          query: const Query(
            where: [
              Where.exact('id', 2),
              Where.exact('assoc', Where.exact('id', 1)),
            ],
            orderBy: [OrderBy.asc('id')],
          ),
        );

        expect(sqliteQuery.statement, statement);
        await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);
        sqliteStatementExpectation(statement, [2, 1]);
      });

      test('nested association', () async {
        const statement =
            'SELECT DISTINCT `DemoModel`.* FROM `DemoModel` INNER JOIN `_brick_DemoModel_many_assoc` ON `DemoModel`._brick_id = `_brick_DemoModel_many_assoc`.l_DemoModel_brick_id INNER JOIN `DemoModelAssoc` ON `DemoModelAssoc`._brick_id = `_brick_DemoModel_many_assoc`.f_DemoModelAssoc_brick_id WHERE `DemoModelAssoc`.full_name = ?';
        final sqliteQuery = QuerySqlTransformer<DemoModel>(
          modelDictionary: dictionary,
          query: const Query(
            where: [
              Where.exact('manyAssoc', Where.exact('assoc', Where.exact('name', 1))),
            ],
          ),
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
          query: Query(
            where: [
              Where.exact(
                'assoc',
                WherePhrase([
                  const Or('id').isExactly(1),
                  const Or('name').isExactly('Guy'),
                ]),
              ),
            ],
          ),
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
          query: const Query(
            where: [
              Where.exact(
                'manyAssoc',
                Where.exact('id', 1),
              ),
            ],
          ),
        );

        expect(sqliteQuery.statement, statement);
      });
    });

    group('Query', () {
      test('#collate', () async {
        const statement = 'SELECT DISTINCT `DemoModel`.* FROM `DemoModel` COLLATE NOCASE';
        final sqliteQuery = QuerySqlTransformer<DemoModel>(
          modelDictionary: dictionary,
          query: const Query(forProviders: [SqliteProviderQuery(collate: 'NOCASE')]),
        );
        await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);

        expect(statement, sqliteQuery.statement);
        sqliteStatementExpectation(statement);
      });

      test('#groupBy', () async {
        const statement = 'SELECT DISTINCT `DemoModel`.* FROM `DemoModel` GROUP BY `DemoModel`.id';
        final sqliteQuery = QuerySqlTransformer<DemoModel>(
          modelDictionary: dictionary,
          query: const Query(forProviders: [SqliteProviderQuery(groupBy: 'id')]),
        );
        await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);

        expect(statement, sqliteQuery.statement);
        sqliteStatementExpectation(statement);
      });

      test('#having', () async {
        const statement = 'SELECT DISTINCT `DemoModel`.* FROM `DemoModel` HAVING `DemoModel`.id';
        final sqliteQuery = QuerySqlTransformer<DemoModel>(
          modelDictionary: dictionary,
          query: const Query(forProviders: [SqliteProviderQuery(having: 'id')]),
        );
        await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);

        expect(statement, sqliteQuery.statement);
        sqliteStatementExpectation(statement);
      });

      test('#limit', () async {
        const statement = 'SELECT DISTINCT `DemoModel`.* FROM `DemoModel` LIMIT 1';
        final sqliteQuery = QuerySqlTransformer<DemoModel>(
          modelDictionary: dictionary,
          query: const Query(limit: 1),
        );
        await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);

        expect(statement, sqliteQuery.statement);
        sqliteStatementExpectation(statement);
      });

      test('#limitBy is ignored', () async {
        const statement = 'SELECT DISTINCT `DemoModel`.* FROM `DemoModel`';
        final sqliteQuery = QuerySqlTransformer<DemoModel>(
          modelDictionary: dictionary,
          query: const Query(limitBy: [LimitBy(1, evaluatedField: 'name')]),
        );
        await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);

        expect(statement, sqliteQuery.statement);
        sqliteStatementExpectation(statement);
      });

      test('#offset', () async {
        const statement = 'SELECT DISTINCT `DemoModel`.* FROM `DemoModel` LIMIT 1 OFFSET 1';
        final sqliteQuery = QuerySqlTransformer<DemoModel>(
          modelDictionary: dictionary,
          query: const Query(limit: 1, offset: 1),
        );
        await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);

        expect(statement, sqliteQuery.statement);
        sqliteStatementExpectation(statement);
      });

      group('#orderBy', () {
        test('simple', () async {
          const statement =
              'SELECT DISTINCT `DemoModel`.* FROM `DemoModel` ORDER BY `DemoModel`.id DESC';
          final sqliteQuery = QuerySqlTransformer<DemoModel>(
            modelDictionary: dictionary,
            query: const Query(orderBy: [OrderBy.desc('id')]),
          );
          await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);

          expect(statement, sqliteQuery.statement);
          sqliteStatementExpectation(statement);
        });

        test('discovered columns share similar names', () async {
          const statement =
              'SELECT DISTINCT `DemoModel`.* FROM `DemoModel` ORDER BY `DemoModel`.last_name DESC';
          final sqliteQuery = QuerySqlTransformer<DemoModel>(
            modelDictionary: dictionary,
            query: const Query(orderBy: [OrderBy.desc('lastName')]),
          );
          await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);

          expect(statement, sqliteQuery.statement);
          sqliteStatementExpectation(statement);
        });

        test('expands field names to column names', () async {
          const statement =
              'SELECT DISTINCT `DemoModel`.* FROM `DemoModel` ORDER BY many_assoc DESC';
          final sqliteQuery = QuerySqlTransformer<DemoModel>(
            modelDictionary: dictionary,
            query: const Query(orderBy: [OrderBy.desc('manyAssoc')]),
          );
          await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);

          expect(statement, sqliteQuery.statement);
          sqliteStatementExpectation(statement);
        });

        test('compound values are expanded to column names', () async {
          const statement =
              'SELECT DISTINCT `DemoModel`.* FROM `DemoModel` ORDER BY many_assoc DESC, `DemoModel`.complex_field_name ASC';
          final sqliteQuery = QuerySqlTransformer<DemoModel>(
            modelDictionary: dictionary,
            query: const Query(
              orderBy: [OrderBy.desc('manyAssoc'), OrderBy.asc('complexFieldName')],
            ),
          );
          await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);

          expect(statement, sqliteQuery.statement);
          sqliteStatementExpectation(statement);
        });
      });

      test('fields convert to column names in providerArgs values', () async {
        const statement =
            'SELECT DISTINCT `DemoModel`.* FROM `DemoModel` ORDER BY `DemoModel`.complex_field_name ASC GROUP BY `DemoModel`.complex_field_name HAVING `DemoModel`.complex_field_name > 1000';
        final sqliteQuery = QuerySqlTransformer<DemoModel>(
          modelDictionary: dictionary,
          query: const Query(
            orderBy: [OrderBy.asc('complexFieldName')],
            forProviders: [
              SqliteProviderQuery(
                having: 'complexFieldName > 1000',
                groupBy: 'complexFieldName',
              ),
            ],
          ),
        );

        await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);

        expect(statement, sqliteQuery.statement);
        sqliteStatementExpectation(statement);
      });

      test('date time is converted', () async {
        const statement =
            'SELECT DISTINCT `DemoModel`.* FROM `DemoModel` ORDER BY datetime(`DemoModel`.simple_time) DESC';
        final sqliteQuery = QuerySqlTransformer<DemoModel>(
          modelDictionary: dictionary,
          query: const Query(orderBy: [OrderBy.desc('simpleTime')]),
        );
        await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);

        expect(statement, sqliteQuery.statement);
        sqliteStatementExpectation(statement);
      });

      // This behavior is not explicitly supported - field names should be used.
      // This is considered functionality behavior and is not guaranteed in
      // future Brick releases.
      // https://github.com/GetDutchie/brick/issues/429
      test('incorrectly cased columns are forwarded as is', () async {
        const statement =
            'SELECT DISTINCT `DemoModel`.* FROM `DemoModel` ORDER BY `DemoModel`.complex_field_name DESC';
        final sqliteQuery = QuerySqlTransformer<DemoModel>(
          modelDictionary: dictionary,
          query: const Query(orderBy: [OrderBy.desc('complex_field_name')]),
        );
        await db.rawQuery(sqliteQuery.statement, sqliteQuery.values);

        expect(statement, sqliteQuery.statement);
        sqliteStatementExpectation(statement);
      });

      test('ordering by association uses the specified model table', () async {
        const statement =
            'SELECT DISTINCT `DemoModel`.* FROM `DemoModel` ORDER BY `DemoModelAssoc`.full_name DESC';
        final sqliteQuery = QuerySqlTransformer<DemoModel>(
          modelDictionary: dictionary,
          query: const Query(orderBy: [OrderBy.desc('assoc', associationField: 'name')]),
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
          query: Query(
            where: [
              const Or('name').isExactly(true),
              const Or('name').isExactly(false),
            ],
          ),
        );
        expect(sqliteQuery.statement, statement);
        expect(sqliteQuery.values, [1, 0]);
      });
    });
  });
}
