import 'package:brick_sqlite/brick_sqlite.dart';

const output = r"""
// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<SqliteUnique> _$SqliteUniqueFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  SqliteFirstRepository? repository,
}) async {
  return SqliteUnique(someField: data['some_field'] as int)
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$SqliteUniqueToSqlite(
  SqliteUnique instance, {
  required SqliteProvider provider,
  SqliteFirstRepository? repository,
}) async {
  return {'some_field': instance.someField};
}

/// Construct a [SqliteUnique]
class SqliteUniqueAdapter extends SqliteAdapter<SqliteUnique> {
  SqliteUniqueAdapter();

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
    SqliteUnique instance,
    DatabaseExecutor executor,
  ) async {
    final results = await executor.rawQuery(
      '''
        SELECT * FROM `SqliteUnique` WHERE some_field = ? LIMIT 1''',
      [instance.someField],
    );

    // SQFlite returns [{}] when no results are found
    if (results.isEmpty || (results.length == 1 && results.first.isEmpty)) {
      return null;
    }

    return results.first['_brick_id'] as int;
  }

  @override
  final String tableName = 'SqliteUnique';

  @override
  Future<SqliteUnique> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant SqliteRepository? repository,
  }) async => await _$SqliteUniqueFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    SqliteUnique input, {
    required provider,
    covariant SqliteRepository? repository,
  }) async => await _$SqliteUniqueToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}
""";

@SqliteSerializable()
class SqliteUnique extends SqliteModel {
  @Sqlite(unique: true)
  final int someField;

  SqliteUnique(this.someField);
}
