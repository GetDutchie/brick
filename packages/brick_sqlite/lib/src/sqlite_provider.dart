import 'dart:io';
import 'package:logging/logging.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common/utils/utils.dart' as sqlite_utils;

import 'package:brick_core/core.dart';
import 'package:brick_sqlite_abstract/db.dart';
import 'package:brick_sqlite_abstract/sqlite_model.dart';
export 'package:brick_sqlite_abstract/sqlite_model.dart';

import 'package:brick_sqlite/src/helpers/alter_column_helper.dart';
import 'package:brick_sqlite/src/helpers/query_sql_transformer.dart';
import 'package:brick_sqlite/src/sqlite_model_dictionary.dart';

import 'package:synchronized/synchronized.dart';
import 'package:meta/meta.dart';

/// Retrieves from a Sqlite database
class SqliteProvider implements Provider<SqliteModel> {
  /// Access the [SQLite](https://github.com/tekartik/sqflite/tree/master/sqflite_common_ffi),
  /// instance agnostically across platforms.
  @protected
  final DatabaseFactory databaseFactory;

  /// The file name for the database used.
  ///
  /// File names are encouraged unless the path exists (e.g. `myDb.sqlite`).
  /// When testing, consider using the `sqlite_common` constant
  /// `inMemoryDatabasePath`.
  final String dbName;

  /// Ensure commands are run synchronously. This significantly benefits stability while
  /// preventing database lockups (has a very, very minor performance expense).
  final Lock _lock;

  final Logger _logger;

  /// The glue between app models and generated adapters
  @override
  final SqliteModelDictionary modelDictionary;

  Future<Database>? _openDb;

  static const _migrationVersionsTableName = 'MigrationVersions';

  SqliteProvider(
    this.dbName, {
    required this.databaseFactory,
    required this.modelDictionary,
  })  : _lock = Lock(reentrant: true),
        _logger = Logger('SqliteProvider');

  /// Remove record from SQLite. [query] is ignored.
  @override
  Future<int> delete<_Model extends SqliteModel>(instance, {query, repository}) async {
    final adapter = modelDictionary.adapterFor[_Model]!;
    final db = await getDb();
    final existingPrimaryKey = await adapter.primaryKeyByUniqueColumns(instance, db);

    if (instance.isNewRecord || existingPrimaryKey == null) {
      throw ArgumentError(
        '$instance cannot be deleted because it does not exist in the SQLite database.',
      );
    }

    return await db.delete(
      '`${adapter.tableName}`',
      where: '${InsertTable.PRIMARY_KEY_COLUMN} = ?',
      whereArgs: [existingPrimaryKey],
    );
  }

  /// Returns `true` if [_Model] exists in SQLite.
  ///
  /// If [query.where] is `null`, existence for **any** record is executed.
  @override
  Future<bool> exists<_Model extends SqliteModel>({
    Query? query,
    ModelRepository<SqliteModel>? repository,
  }) async {
    final sqlQuery = QuerySqlTransformer<_Model>(
      modelDictionary: modelDictionary,
      query: query,
      selectStatement: false,
    );

    final offsetRegex = RegExp(r'OFFSET \d+');
    final offsetIsPresent = sqlQuery.statement.contains(offsetRegex);
    var statement = sqlQuery.statement;

    /// COUNT(*) does not function with OFFSET.
    /// Instead, when an OFFSET is defined, a single column managed by is queried
    /// and that result is counted via Dart
    if (offsetIsPresent) {
      statement = statement.replaceFirstMapped(RegExp(r'SELECT COUNT\(\*\) FROM ([\S]+)'), (match) {
        return 'SELECT ${match.group(1)}.${InsertTable.PRIMARY_KEY_COLUMN} FROM ${match.group(1)}';
      });
    }

    final countQuery = await (await getDb()).rawQuery(statement, sqlQuery.values);
    final count = offsetIsPresent ? countQuery.length : sqlite_utils.firstIntValue(countQuery);

    return (count ?? 0) > 0;
  }

  /// Fetch one time from the SQLite database
  /// Available query `providerArgs`:
  /// * `collate` - a SQL `COLLATE` clause
  /// * `groupBy` - a SQL `GROUP BY` clause
  /// * `having` - a SQL `HAVING` clause
  /// * `offset` - a SQL `OFFSET` clause
  /// * `orderBy` - a SQL `ORDER BY` clause
  ///
  /// Use field names not column names. For example, given a `final DateTime createdAt;` field:
  /// `providerArgs: { 'orderBy': 'createdAt ASC' }`. If the column cannot be found for the first value
  /// before a space, the value is left unchanged.
  ///
  /// In a more complex query using multiple tables and lookups like `createdAt ASC, name ASC`
  /// to produce `SELECT * FROM "TableName" ORDER BY created_at ASC, name ASC;`, `providerArgs` would
  /// equal `'providerArgs': { 'orderBy': 'created_at ASC, name ASC' }` with column names defined.
  /// As Brick manages column names, this is not recommended and should be written only when necessary.
  @override
  Future<List<_Model>> get<_Model extends SqliteModel>({
    query,
    repository,
  }) async {
    final sqlQuery = QuerySqlTransformer<_Model>(
      modelDictionary: modelDictionary,
      query: query,
    );
    return await rawGet<_Model>(
      sqlQuery.statement,
      sqlQuery.values,
      repository: repository,
    );
  }

  /// Access the latest instantiation of the database [safely](https://github.com/tekartik/sqflite/blob/master/sqflite/doc/opening_db.md#prevent-database-locked-issue).
  @protected
  Future<Database> getDb() {
    _openDb ??= databaseFactory.openDatabase(dbName);
    return _openDb!;
  }

  Future<int> lastMigrationVersion() async {
    final db = await getDb();

    // ensure migrations table exists
    await db.execute(
        'CREATE TABLE IF NOT EXISTS $_migrationVersionsTableName(version INTEGER PRIMARY KEY)');

    final sqliteVersions = await db.query(
      _migrationVersionsTableName,
      distinct: true,
      orderBy: 'version DESC',
      limit: 1,
    );

    if (sqliteVersions.isEmpty) {
      return -1;
    }

    return sqliteVersions.first['version'] as int;
  }

  /// Update database structure with latest migrations. Note that this will run
  /// the [migrations] in the order provided.
  Future<void> migrate(List<Migration> migrations) async {
    final db = await getDb();

    // Ensure foreign keys are enabled
    await db.execute('PRAGMA foreign_keys = ON');

    final latestMigrationVersion = MigrationManager.latestMigrationVersion(migrations);
    final latestSqliteMigrationVersion = await lastMigrationVersion();

    // Guard if migration has already been committed.
    if (latestSqliteMigrationVersion == latestMigrationVersion) {
      _logger.info('Already at latest migration version ($latestMigrationVersion)');
      return;
    }

    for (var migration in migrations) {
      for (var command in migration.up) {
        _logger.finer(
            'Running migration (${migration.version}): ${command.statement ?? command.forGenerator}');

        final alterCommand = AlterColumnHelper(command);
        await _lock.synchronized(() async {
          if (alterCommand.requiresSchema) {
            await alterCommand.execute(db);
          } else if (command.statement != null) {
            await db.execute(command.statement!);
          }
        });
      }

      await db.rawInsert(
        'INSERT INTO $_migrationVersionsTableName(version) VALUES(?)',
        [migration.version],
      );
    }
  }

  /// Fetch results for model with a custom SQL statement.
  /// It is recommended to use [get] whenever possible. **Advanced use only**.
  Future<List<_Model>> rawGet<_Model extends SqliteModel>(
    String sql,
    List arguments, {
    ModelRepository<SqliteModel>? repository,
  }) async {
    final adapter = modelDictionary.adapterFor[_Model]!;

    final results = await _lock.synchronized(() async {
      return (await getDb()).rawQuery(sql, arguments);
    });

    if (results.isEmpty || results.first.isEmpty) {
      // otherwise an empty sql result will generate a blank model
      return <_Model>[];
    }

    return await Future.wait<_Model>(
      results.map(
        (row) => adapter.fromSqlite(row, provider: this, repository: repository) as Future<_Model>,
      ),
    );
  }

  /// Execute a raw SQL statement. **Advanced use only**.
  Future<void> rawExecute(String sql, [List? arguments]) async {
    return await (await getDb()).execute(sql, arguments);
  }

  /// Insert with a raw SQL statement. **Advanced use only**.
  Future<int> rawInsert(String sql, [List? arguments]) async {
    return await (await getDb()).rawInsert(sql, arguments);
  }

  /// Query with a raw SQL statement. **Advanced use only**.
  Future<List<Map>> rawQuery(String sql, [List? arguments]) async {
    return await (await getDb()).rawQuery(sql, arguments);
  }

  /// Reset the DB by deleting and recreating it.
  ///
  /// **WARNING:** This is a destructive, irrevisible action.
  Future<void> resetDb() async {
    try {
      await (await getDb()).close();

      await databaseFactory.deleteDatabase(dbName);

      // recreate
      _openDb = null;
      await getDb();
    } on FileSystemException {
      // noop
    }
  }

  /// Insert record into SQLite. Returns the primary key of the record inserted
  @override
  Future<int?> upsert<_Model extends SqliteModel>(instance, {query, repository}) async {
    final adapter = modelDictionary.adapterFor[_Model]!;
    final db = await getDb();

    await adapter.beforeSave(instance, provider: this, repository: repository);
    await instance.beforeSave(provider: this, repository: repository);
    final data = await adapter.toSqlite(instance, provider: this, repository: repository);

    final id = await _lock.synchronized(() async {
      return await db.transaction<int?>((txn) async {
        final existingPrimaryKey = await adapter.primaryKeyByUniqueColumns(instance, txn);

        if (instance.isNewRecord && existingPrimaryKey == null) {
          return await txn.insert(
            '`${adapter.tableName}`',
            data,
          );
        }

        final primaryKey = existingPrimaryKey ?? instance.primaryKey;
        await txn.update(
          '`${adapter.tableName}`',
          data,
          where: '${InsertTable.PRIMARY_KEY_COLUMN} = ?',
          whereArgs: [primaryKey],
        );
        return primaryKey;
      });
    });

    instance.primaryKey = id;
    await adapter.afterSave(instance, provider: this, repository: repository);
    await instance.afterSave(provider: this, repository: repository);
    return id;
  }
}
