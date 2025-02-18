import 'package:brick_core/core.dart';
import 'package:brick_sqlite/src/db/migration.dart';
import 'package:brick_sqlite/src/db/migration_commands/migration_command.dart';
import 'package:brick_sqlite/src/models/sqlite_model.dart';
import 'package:brick_sqlite/src/runtime_sqlite_column_definition.dart';
import 'package:brick_sqlite/src/sqlite_provider.dart';
import 'package:sqflite_common/sqlite_api.dart';

/// Constructors that convert app models to and from Sqlite
abstract mixin class SqliteAdapter<TModel extends Model> implements Adapter<TModel> {
  /// Defaults to pluralized model name from the generator.
  /// If this property is changed after the table has been inserted,
  /// a [RenameTable] [MigrationCommand] must be included in the next [Migration].
  String get tableName;

  /// Hook invoked before the model is successfully entered in the SQLite database.
  /// Useful to update or save associations. This is invoked **before**
  /// `SqliteModel#beforeSave`.
  Future<void> beforeSave(
    TModel instance, {
    required SqliteProvider provider,
    ModelRepository<SqliteModel>? repository,
  }) async {}

  /// Hook invoked after the model is successfully entered in the SQLite database.
  /// Useful to update or save associations. This is invoked **before**
  /// `SqliteModel#afterSave`.
  Future<void> afterSave(
    TModel instance, {
    required SqliteProvider provider,
    ModelRepository<SqliteModel>? repository,
  }) async {}

  ///
  Future<TModel> fromSqlite(
    Map<String, dynamic> input, {
    required SqliteProvider provider,
    ModelRepository<SqliteModel>? repository,
  });

  ///
  Future<Map<String, dynamic>> toSqlite(
    TModel input, {
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
  Future<int?> primaryKeyByUniqueColumns(TModel instance, DatabaseExecutor executor);
}
