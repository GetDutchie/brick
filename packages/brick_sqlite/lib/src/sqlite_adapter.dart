import 'package:sqflite/sqflite.dart';

import 'package:brick_core/core.dart';
import 'package:brick_sqlite_abstract/db.dart';
import 'package:brick_sqlite_abstract/sqlite_model.dart';
import 'package:brick_sqlite/src/sqlite_provider.dart';
import 'package:brick_sqlite/src/runtime_sqlite_column_definition.dart';

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
    required SqliteProvider provider,
    ModelRepository<SqliteModel>? repository,
  }) async {}

  /// Hook invoked after the model is successfully entered in the SQLite database.
  /// Useful to update or save associations. This is invoked **before**
  /// `SqliteModel#afterSave`.
  Future<void> afterSave(
    _Model instance, {
    required SqliteProvider provider,
    ModelRepository<SqliteModel>? repository,
  }) async {}

  Future<_Model> fromSqlite(
    Map<String, dynamic> input, {
    required SqliteProvider provider,
    ModelRepository<SqliteModel>? repository,
  });
  Future<Map<String, dynamic>> toSqlite(
    _Model input, {
    required SqliteProvider provider,
    ModelRepository<SqliteModel>? repository,
  });

  /// A dictionary that connects field names to SQLite column properties.
  Map<String, RuntimeSqliteColumnDefinition> get fieldsToSqliteColumns;

  /// Find a record based on the existence of all contained fields annotated with
  /// `@Sqlite(unique: true)`. The Brick-defined primary key of the table is not included
  /// in the query. Returns the Brick-defined primary key of the discovered record.
  ///
  /// [executor] accepts a `Database` or `Transaction`.
  Future<int?> primaryKeyByUniqueColumns(_Model instance, DatabaseExecutor executor);
}
