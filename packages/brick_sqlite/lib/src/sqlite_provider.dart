import 'package:brick_core/core.dart';
import 'package:brick_sqlite/src/db/migration.dart';
import 'package:brick_sqlite/src/db/migration_commands/insert_table.dart';
import 'package:brick_sqlite/src/db/migration_manager.dart';
import 'package:brick_sqlite/src/helpers/alter_column_helper.dart';
import 'package:brick_sqlite/src/helpers/query_sql_transformer.dart';
import 'package:brick_sqlite/src/models/sqlite_model.dart';
import 'package:brick_sqlite/src/sqlite_model_dictionary.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common/utils/utils.dart' as sqlite_utils;
import 'package:synchronized/synchronized.dart';

/// Retrieves from a SQLite database
class SqliteProvider<TProviderModel extends SqliteModel> implements Provider<TProviderModel> {
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

  /// Retrieves from a SQLite database
  SqliteProvider(
    this.dbName, {
    required this.databaseFactory,
    required this.modelDictionary,
  })  : _lock = Lock(reentrant: true),
        _logger = Logger('SqliteProvider');

  /// Remove record from SQLite. [query] is ignored.
  @override
  Future<int> delete<TModel extends TProviderModel>(
    TModel instance, {
    Query? query,
    ModelRepository<TProviderModel>? repository,
  }) async {
    final adapter = modelDictionary.adapterFor[TModel]!;
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

  /// Returns `true` if [TModel] exists in SQLite.
  ///
  /// If [Query.where] is `null`, existence for **any** record is executed.
  @override
  Future<bool> exists<TModel extends TProviderModel>({
    Query? query,
    ModelRepository<TProviderModel>? repository,
  }) async {
    final sqlQuery = QuerySqlTransformer<TModel>(
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
      statement = statement.replaceFirstMapped(
        RegExp(r'SELECT COUNT\(\*\) FROM ([\S]+)'),
        (match) =>
            'SELECT ${match.group(1)}.${InsertTable.PRIMARY_KEY_COLUMN} FROM ${match.group(1)}',
      );
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
  /// `orderBy: [OrderBy.asc('createdAt')]`. If the column cannot be found for the first value
  /// before a space, the value is left unchanged.
  ///
  /// In a more complex query using multiple tables and lookups like `createdAt ASC, name ASC`
  /// to produce `SELECT * FROM "TableName" ORDER BY created_at ASC, name ASC;`, `providerArgs` would
  /// equal `orderBy: [OrderBy.asc('created_at'), OrderBy.asc('name')]` with column names defined.
  /// As Brick manages column names, this is not recommended and should be written only when necessary.
  @override
  Future<List<TModel>> get<TModel extends TProviderModel>({
    Query? query,
    ModelRepository<TProviderModel>? repository,
  }) async {
    final sqlQuery = QuerySqlTransformer<TModel>(
      modelDictionary: modelDictionary,
      query: query,
    );
    return await rawGet<TModel>(
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

  /// The latest migration version committed to SQLite
  Future<int> lastMigrationVersion() async {
    final db = await getDb();

    // ensure migrations table exists
    await db.execute(
      'CREATE TABLE IF NOT EXISTS $_migrationVersionsTableName(version INTEGER PRIMARY KEY)',
    );

    final sqliteVersions = await db.query(
      _migrationVersionsTableName,
      distinct: true,
      orderBy: 'version DESC',
      limit: 1,
    );

    if (sqliteVersions.isEmpty) {
      return -1;
    }

    return sqliteVersions.first['version']! as int;
  }

  /// Update database structure with latest migrations. Note that this will run
  /// the [migrations] in the order provided.
  ///
  /// If [down] is `true`, the migrations will be run in reverse order.
  Future<void> migrate(List<Migration> migrations, {bool down = false}) async {
    final db = await getDb();

    // Ensure foreign keys are enabled
    await db.execute('PRAGMA foreign_keys = ON');

    final latestMigrationVersion = MigrationManager.latestMigrationVersion(migrations);
    final latestSqliteMigrationVersion = await lastMigrationVersion();

    // Guard if migration has already been committed.
    if (latestSqliteMigrationVersion == latestMigrationVersion && !down) {
      _logger.info('Already at latest migration version ($latestMigrationVersion)');
      return;
    }

    final migrationsToRun = down ? migrations.reversed.toList() : migrations;
    for (final migration in migrationsToRun) {
      final commands = down ? migration.down : migration.up;
      for (final command in commands) {
        _logger.finer(
          'Running migration (${migration.version}): ${command.statement ?? command.forGenerator}',
        );

        final alterCommand = AlterColumnHelper(command);
        await _lock.synchronized(() async {
          if (alterCommand.requiresSchema) {
            await alterCommand.execute(db);
          } else if (command.statement != null) {
            await db.execute(command.statement!);
          }
        });
      }

      if (down) {
        await db.rawDelete(
          'DELETE FROM $_migrationVersionsTableName WHERE version = ?',
          [migration.version],
        );
      } else {
        await db.rawInsert(
          'INSERT INTO $_migrationVersionsTableName(version) VALUES(?)',
          [migration.version],
        );
      }
    }
  }

  /// Fetch results for model with a custom SQL statement.
  /// It is recommended to use [get] whenever possible. **Advanced use only**.
  Future<List<TModel>> rawGet<TModel extends TProviderModel>(
    String sql,
    List arguments, {
    ModelRepository<TProviderModel>? repository,
  }) async {
    final adapter = modelDictionary.adapterFor[TModel]!;

    final results = await _lock.synchronized(() async => (await getDb()).rawQuery(sql, arguments));

    if (results.isEmpty || results.first.isEmpty) {
      // otherwise an empty sql result will generate a blank model
      return <TModel>[];
    }

    return await Future.wait<TModel>(
      results.map(
        (row) => adapter.fromSqlite(row, provider: this, repository: repository) as Future<TModel>,
      ),
    );
  }

  /// Execute a raw SQL statement. **Advanced use only**.
  Future<void> rawExecute(String sql, [List? arguments]) async =>
      await (await getDb()).execute(sql, arguments);

  /// Insert with a raw SQL statement. **Advanced use only**.
  Future<int> rawInsert(String sql, [List? arguments]) async =>
      await (await getDb()).rawInsert(sql, arguments);

  /// Query with a raw SQL statement. **Advanced use only**.
  Future<List<Map<String, Object?>>> rawQuery(String sql, [List? arguments]) async =>
      await (await getDb()).rawQuery(sql, arguments);

  /// Reset the DB by deleting and recreating it.
  ///
  /// **WARNING:** This is a destructive, irrevisible action.
  Future<void> resetDb() async {
    await (await getDb()).close();

    await databaseFactory.deleteDatabase(dbName);

    // recreate
    _openDb = null;
    await getDb();
  }

  /// Perform actions within a database transaction.
  /// **DO NOT** access `sqliteProvider` methods within [callback]. Instead,
  /// access DB methods and properties from [transaction]. **Advanced use only**.
  Future<T> transaction<T>(Future<T> Function(Transaction transaction) callback) async {
    final db = await getDb();
    return await _lock.synchronized(() async => await db.transaction<T>(callback));
  }

  /// Insert record into SQLite. Returns the primary key of the record inserted
  @override
  Future<int?> upsert<TModel extends TProviderModel>(
    TModel instance, {
    Query? query,
    ModelRepository<TProviderModel>? repository,
  }) async {
    final adapter = modelDictionary.adapterFor[TModel]!;
    final db = await getDb();

    await adapter.beforeSave(instance, provider: this, repository: repository);
    await instance.beforeSave(provider: this, repository: repository);
    final data = await adapter.toSqlite(instance, provider: this, repository: repository);

    final id = await _lock.synchronized(
      () async => await db.transaction<int?>((txn) async {
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
      }),
    );

    instance.primaryKey = id;
    await adapter.afterSave(instance, provider: this, repository: repository);
    await instance.afterSave(provider: this, repository: repository);
    return id;
  }
}
