import 'package:brick_sqlite_abstract/annotations.dart';
import 'package:brick_sqlite_abstract/sqlite_model.dart';

final output = r"""
// GENERATED CODE DO NOT EDIT
// This file should NOT be version controlled and should not be manually edited.
part of '../brick.g.dart';

Future<SqliteUnique> _$SqliteUniqueFromSqlite(Map<String, dynamic> data,
    {SqliteProvider provider, SqliteFirstRepository repository}) async {
  return SqliteUnique(
      someField: data['some_field'] == null ? null : data['some_field'] as int)
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$SqliteUniqueToSqlite(SqliteUnique instance,
    {SqliteProvider provider, SqliteFirstRepository repository}) async {
  return {'some_field': instance.someField};
}

/// Construct a [SqliteUnique]
class SqliteUniqueAdapter extends SqliteAdapter<SqliteUnique> {
  SqliteUniqueAdapter();

  final Map<String, RuntimeSqliteColumnDefinition> fieldsToSqliteColumns = {
    'primaryKey': RuntimeSqliteColumnDefinition(
      association: false,
      columnName: '_brick_id',
      iterable: false,
      type: int,
    ),
    'someField': RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'some_field',
      iterable: false,
      type: int,
    )
  };
  Future<int> primaryKeyByUniqueColumns(
      SqliteUnique instance, DatabaseExecutor executor) async {
    final results = await executor.rawQuery('''
        SELECT * FROM `SqliteUnique` WHERE some_field = ? LIMIT 1''',
        [instance.someField]);

    // SQFlite returns [{}] when no results are found
    if (results?.isEmpty == true ||
        (results?.length == 1 && results?.first?.isEmpty == true)) return null;

    return results.first['_brick_id'];
  }

  final String tableName = 'SqliteUnique';

  Future<SqliteUnique> fromSqlite(Map<String, dynamic> input,
          {provider, repository}) async =>
      await _$SqliteUniqueFromSqlite(input,
          provider: provider, repository: repository);
  Future<Map<String, dynamic>> toSqlite(SqliteUnique input,
          {provider, repository}) async =>
      await _$SqliteUniqueToSqlite(input,
          provider: provider, repository: repository);
}
""";

@SqliteSerializable()
class SqliteUnique extends SqliteModel {
  @Sqlite(unique: true)
  final int someField;

  SqliteUnique(this.someField);
}
