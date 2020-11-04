import 'dart:io';
import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:sqflite/sqflite.dart';

import 'package:brick_core/core.dart';
import 'package:brick_sqlite_abstract/db.dart';
import 'package:brick_sqlite_abstract/sqlite_model.dart';
export 'package:brick_sqlite_abstract/sqlite_model.dart';

import 'package:brick_sqlite/src/sqlite/alter_column_helper.dart';
import 'package:brick_sqlite/src/sqlite/query_sql_transformer.dart';

import 'package:synchronized/synchronized.dart';
import 'package:meta/meta.dart';

/// Associates app models with their [SqliteAdapter]
class SqliteModelDictionary extends ModelDictionary<SqliteModel, SqliteAdapter<SqliteModel>> {
  const SqliteModelDictionary(Map<Type, SqliteAdapter<SqliteModel>> mappings) : super(mappings);
}

/// Retrieves from a Sqlite database
class SqliteProvider implements Provider<SqliteModel> {
  static const String MIGRATION_VERSIONS_TABLE_NAME = 'MigrationVersions';

  /// Access the [SQLite](https://github.com/tekartik/sqflite/tree/master/sqflite_common_ffi),
  /// instance agnostically across platforms. If [databaseFactory] is null, the default
  /// Flutter SQFlite will be used.
  @protected
  final DatabaseFactory databaseFactory;

  /// The file name for the database used.
  ///
  /// When [databaseFactory] is present, this is the **entire** path name.
  /// With [databaseFactory], this is most commonly the
  /// `sqlite_common` constant `inMemoryDatabasePath`.
  final String dbName;

  /// The glue between app models and generated adapters
  @override
  final SqliteModelDictionary modelDictionary;

  /// Ensure commands are run synchronously. This significantly benefits stability while
  /// preventing database lockups (has a very, very minor performance expense).
  final Lock _lock;

  final Logger _logger;

  SqliteProvider(
    this.dbName, {
    this.databaseFactory,
    this.modelDictionary,
  })  : _lock = Lock(reentrant: true),
        _logger = Logger('SqliteProvider');

  Database _openDb;
  Future<Database> get _db async {
    if (_openDb?.isOpen == true) return _openDb;

    if (databaseFactory != null) {
      return _openDb = await databaseFactory.openDatabase(dbName);
    }

    return _openDb = await openDatabase(dbName);
  }

  /// Remove record from SQLite. [query] is ignored.
  @override
  Future<int> delete<_Model extends SqliteModel>(instance, {query, repository}) async {
    final adapter = modelDictionary.adapterFor[_Model];
    final db = await _db;
    final existingPrimaryKey = await adapter.primaryKeyByUniqueColumns(instance, db);

    if (instance.isNewRecord || existingPrimaryKey == null) {
      throw ArgumentError(
        '$instance cannot be deleted because it does not exist in the SQLite database.',
      );
    }

    final primaryKey = existingPrimaryKey ?? instance.primaryKey;

    return await db.delete(
      '`${adapter.tableName}`',
      where: '${InsertTable.PRIMARY_KEY_COLUMN} = ?',
      whereArgs: [primaryKey],
    );
  }

  /// Returns `true` if [_Model] exists in SQLite.
  ///
  /// If [query.where] is `null`, existence for **any** record is executed.
  Future<bool> exists<_Model extends SqliteModel>({
    Query query,
    ModelRepository<SqliteModel> repository,
  }) async {
    if (!_supportsArgs(query)) return false;
    final sqlQuery = QuerySqlTransformer<_Model>(
      modelDictionary: modelDictionary,
      query: query,
      selectStatement: false,
    );
    final countQuery = await (await _db).rawQuery(sqlQuery.statement, sqlQuery.values);

    final count = Sqflite.firstIntValue(countQuery ?? []) ?? 0;
    return count > 0;
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

  Future<int> lastMigrationVersion() async {
    final db = await _db;

    // ensure migrations table exists
    await db.execute(
        'CREATE TABLE IF NOT EXISTS $MIGRATION_VERSIONS_TABLE_NAME(version INTEGER PRIMARY KEY)');

    final sqliteVersions = await db.query(
      MIGRATION_VERSIONS_TABLE_NAME,
      distinct: true,
      orderBy: 'version DESC',
      limit: 1,
    );

    if (sqliteVersions == null || sqliteVersions.isEmpty) {
      return -1;
    }

    return sqliteVersions.first['version'];
  }

  /// Update database structure with latest migrations. Note that this will run
  /// the [migrations] in the order provided.
  Future<void> migrate(List<Migration> migrations) async {
    final db = await _db;

    // Ensure foreign keys are enabled
    await db.execute('PRAGMA foreign_keys = ON');

    final latestMigrationVersion = MigrationManager.latestMigrationVersion(migrations);
    final latestSqliteMigrationVersion = await lastMigrationVersion();

    // Guard if migration has already been committed.
    if (latestSqliteMigrationVersion == latestMigrationVersion) {
      _logger.info('Already at latest migration version ($latestMigrationVersion)');
      return null;
    }

    for (var migration in migrations) {
      for (var command in migration.up) {
        _logger.finer(
            'Running migration (${migration.version}): ${command.statement ?? command.forGenerator}');

        final alterCommand = AlterColumnHelper(command);
        await _lock.synchronized(() async {
          if (alterCommand.requiresSchema) {
            await alterCommand.execute(db);
          } else {
            await db.execute(command.statement);
          }
        });
      }

      await db.rawInsert(
        'INSERT INTO $MIGRATION_VERSIONS_TABLE_NAME(version) VALUES(?)',
        [migration.version],
      );
    }
  }

  /// Fetch results for model with a custom SQL statement.
  /// It is recommended to use [get] whenever possible. **Advanced use only**.
  Future<List<_Model>> rawGet<_Model extends SqliteModel>(
    String sql,
    List arguments, {
    ModelRepository<SqliteModel> repository,
  }) async {
    final adapter = modelDictionary.adapterFor[_Model];

    final results = await _lock.synchronized(() async {
      return (await _db).rawQuery(sql, arguments);
    });

    if (results.isEmpty || results.first.isEmpty) {
      // otherwise an empty sql result will generate a blank model
      return <_Model>[];
    }

    return await Future.wait<_Model>(
      results.map((row) => adapter.fromSqlite(row, provider: this, repository: repository)),
    );
  }

  /// Execute a raw SQL statement. **Advanced use only**.
  Future<void> rawExecute(String sql, [List arguments]) async {
    return await (await _db).execute(sql, arguments);
  }

  /// Insert with a raw SQL statement. **Advanced use only**.
  Future<int> rawInsert(String sql, [List arguments]) async {
    return await (await _db).rawInsert(sql, arguments);
  }

  /// Query with a raw SQL statement. **Advanced use only**.
  Future<List<Map>> rawQuery(String sql, [List arguments]) async {
    return await (await _db).rawQuery(sql, arguments);
  }

  /// Reset the DB by deleting and recreating it.
  ///
  /// **WARNING:** This is a destructive, irrevisible action.
  Future<void> resetDb() async {
    try {
      await (await _db).close();

      if (databaseFactory == null) {
        await deleteDatabase(dbName);
      } else {
        await databaseFactory.deleteDatabase(dbName);
      }

      // recreate
      await _db;
    } on FileSystemException {
      // noop
    }
  }

  /// Insert record into SQLite. Returns the primary key of the record inserted
  @override
  Future<int> upsert<_Model extends SqliteModel>(instance, {query, repository}) async {
    if (instance == null) return NEW_RECORD_ID;

    final adapter = modelDictionary.adapterFor[_Model];
    final db = await _db;

    await adapter.beforeSave(instance, provider: this, repository: repository);
    await instance.beforeSave(provider: this, repository: repository);
    final data = await adapter.toSqlite(instance, provider: this, repository: repository);

    final id = await _lock.synchronized(() async {
      return await db.transaction<int>((txn) async {
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

  /// brick_sqlite 0.1.0 changed the storage of iterable siblings from a JSON-encoded string to
  /// a proper joins table entity. This method migrates from pre-0.1.0 to the new API.
  /// It should be run after `migrate`. For more, see the [CHANGELOG notes](https://github.com/greenbits/brick/blob/master/packages/brick_sqlite/CHANGELOG.md#010).
  ///
  /// This method will be eventually deprecated and removed.
  @deprecated
  Future<void> migrateFromStringToJoinsTable(
    String columnName,
    String localTableName,
    String foreignTableName,
  ) async {
    final db = await _db;

    final rawIds = await db
        .rawQuery('SELECT $columnName, ${InsertTable.PRIMARY_KEY_COLUMN} FROM `$localTableName`');
    for (var result in rawIds) {
      final ids = jsonDecode(result[columnName] ?? '[]');
      for (var id in ids) {
        // ignore deleted associations as they'll throw contraint exceptions
        final hasAssociation = await db.rawQuery(
            'SELECT DISTINCT ${InsertTable.PRIMARY_KEY_COLUMN} FROM `$foreignTableName` WHERE ${InsertTable.PRIMARY_KEY_COLUMN} = $id LIMIT 1');
        if (hasAssociation.isNotEmpty) {
          await db.rawInsert(
            'INSERT OR IGNORE INTO `${InsertForeignKey.joinsTableName(columnName, localTableName: localTableName)}` (`${InsertForeignKey.joinsTableLocalColumnName(localTableName)}`, `${InsertForeignKey.joinsTableForeignColumnName(foreignTableName)}`) VALUES (?, ?)',
            [result[InsertTable.PRIMARY_KEY_COLUMN], id],
          );
        }
      }
    }
  }

  /// Ensure that the provided `providerArgs` are support by this provider.
  ///
  /// Available query `providerArgs`:
  /// * `collate` - a SQL `COLLATE` clause
  /// * `groupBy` - a SQL `GROUP BY` clause
  /// * `having` - a SQL `HAVING` clause
  /// * `offset` - a SQL `OFFSET` clause
  /// * `limit` - a SQL `LIMIT` clause
  /// * `orderBy` - a SQL `ORDER BY` clause
  bool _supportsArgs(Query query) {
    if (query?.providerArgs == null) return true;

    final supportedArgs = [
      'collate',
      'groupBy',
      'having',
      'limit',
      'offset',
      'orderBy',
    ];

    return query.providerArgs.keys.every((paramKey) {
      return supportedArgs.contains(paramKey);
    });
  }
}

/// Constructors that convert app models to and from Sqlite
abstract class SqliteAdapter<_Model extends Model> implements Adapter<_Model> {
  /// Defaults to pluralized model name from the generator.
  /// If this property is changed after the table has been inserted,
  /// a [RenameTable] [MigrationCommand] must be included in the next [Migration].
  String get tableName;

  /// Hook invoked before the model is successfully entered in the SQLite database.
  /// Useful to update or save associations. This is invoked **before**
  /// `SqliteModel#beforeSave`.
  Future<void> beforeSave(
    _Model instance, {
    SqliteProvider provider,
    ModelRepository<SqliteModel> repository,
  }) async {}

  /// Hook invoked after the model is successfully entered in the SQLite database.
  /// Useful to update or save associations. This is invoked **before**
  /// `SqliteModel#afterSave`.
  Future<void> afterSave(
    _Model instance, {
    SqliteProvider provider,
    ModelRepository<SqliteModel> repository,
  }) async {}

  Future<_Model> fromSqlite(
    Map<String, dynamic> data, {
    SqliteProvider provider,
    ModelRepository<SqliteModel> repository,
  });
  Future<Map<String, dynamic>> toSqlite(
    _Model data, {
    SqliteProvider provider,
    ModelRepository<SqliteModel> repository,
  });

  /// A dictionary that connects field names to SQLite column names.
  Map<String, Map<String, dynamic>> fieldsToSqliteColumns;

  /// Find a record based on the existence of all contained fields annotated with
  /// `@Sqlite(unique: true)`. The Brick-defined primary key of the table is not included
  /// in the query. Returns the Brick-defined primary key of the discovered record.
  ///
  /// [executor] accepts a `Database` or `Transaction`.
  Future<int> primaryKeyByUniqueColumns(_Model instance, DatabaseExecutor executor);
}
