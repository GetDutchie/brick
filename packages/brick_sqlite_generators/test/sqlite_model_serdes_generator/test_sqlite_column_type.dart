import 'package:brick_sqlite/brick_sqlite.dart';

const output = r"""
// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<SqliteColumnType> _$SqliteColumnTypeFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  SqliteFirstRepository? repository,
}) async {
  return SqliteColumnType(someField: data['some_field'])
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$SqliteColumnTypeToSqlite(
  SqliteColumnType instance, {
  required SqliteProvider provider,
  SqliteFirstRepository? repository,
}) async {
  return {'some_field': instance.someField};
}

/// Construct a [SqliteColumnType]
class SqliteColumnTypeAdapter extends SqliteAdapter<SqliteColumnType> {
  SqliteColumnTypeAdapter();

  @override
  final Map<String, RuntimeSqliteColumnDefinition> fieldsToSqliteColumns = {
    'primaryKey': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: '_brick_id',
      iterable: false,
      type: int,
    ),
    'someField': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'some_field',
      iterable: false,
      type: int,
    ),
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
    SqliteColumnType instance,
    DatabaseExecutor executor,
  ) async => instance.primaryKey;
  @override
  final String tableName = 'SqliteColumnType';

  @override
  Future<SqliteColumnType> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant SqliteRepository? repository,
  }) async => await _$SqliteColumnTypeFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    SqliteColumnType input, {
    required provider,
    covariant SqliteRepository? repository,
  }) async => await _$SqliteColumnTypeToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}
""";

@SqliteSerializable()
class SqliteColumnType extends SqliteModel {
  @Sqlite(columnType: Column.blob)
  final int someField;

  SqliteColumnType(this.someField);
}
