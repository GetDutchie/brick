import 'package:brick_sqlite_abstract/annotations.dart';
import 'package:brick_sqlite_abstract/sqlite_model.dart';

final output = r"""
// GENERATED CODE DO NOT EDIT
// This file should NOT be version controlled and should not be manually edited.
part of '../brick.g.dart';

Future<SqliteColumnType> _$SqliteColumnTypeFromSqlite(Map<String, dynamic> data,
    {SqliteProvider provider, SqliteFirstRepository repository}) async {
  return SqliteColumnType(
      someField: data['some_field'] == null ? null : data['some_field'] as int)
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$SqliteColumnTypeToSqlite(
    SqliteColumnType instance,
    {SqliteProvider provider,
    SqliteFirstRepository repository}) async {
  return {'some_field': instance.someField};
}

/// Construct a [SqliteColumnType]
class SqliteColumnTypeAdapter extends SqliteAdapter<SqliteColumnType> {
  SqliteColumnTypeAdapter();

  final Map<String, RuntimeSqliteColumnDefinition> fieldsToSqliteColumns = {
    'primaryKey': RuntimeSqliteColumnDefinition(
      association: false,
      iterable: false,
      name: '_brick_id',
      type: int,
    ),
    'someField': RuntimeSqliteColumnDefinition(
      association: false,
      iterable: false,
      name: 'some_field',
      type: int,
    )
  };
  Future<int> primaryKeyByUniqueColumns(
          SqliteColumnType instance, DatabaseExecutor executor) async =>
      null;
  final String tableName = 'SqliteColumnType';

  Future<SqliteColumnType> fromSqlite(Map<String, dynamic> input,
          {provider, repository}) async =>
      await _$SqliteColumnTypeFromSqlite(input,
          provider: provider, repository: repository);
  Future<Map<String, dynamic>> toSqlite(SqliteColumnType input,
          {provider, repository}) async =>
      await _$SqliteColumnTypeToSqlite(input,
          provider: provider, repository: repository);
}
""";

@SqliteSerializable()
class SqliteColumnType extends SqliteModel {
  @Sqlite(columnType: Column.blob)
  final int someField;

  SqliteColumnType(this.someField);
}
