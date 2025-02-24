import 'package:brick_sqlite/brick_sqlite.dart';

const output = r"""
// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<FieldWithTypeArgument> _$FieldWithTypeArgumentFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  SqliteFirstRepository? repository,
}) async {
  return FieldWithTypeArgument(someField: jsonDecode(data['some_field']))
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$FieldWithTypeArgumentToSqlite(
  FieldWithTypeArgument instance, {
  required SqliteProvider provider,
  SqliteFirstRepository? repository,
}) async {
  return {'some_field': jsonEncode(instance.someField)};
}

/// Construct a [FieldWithTypeArgument]
class FieldWithTypeArgumentAdapter
    extends SqliteAdapter<FieldWithTypeArgument> {
  FieldWithTypeArgumentAdapter();

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
      type: Map,
    ),
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
    FieldWithTypeArgument instance,
    DatabaseExecutor executor,
  ) async => instance.primaryKey;
  @override
  final String tableName = 'FieldWithTypeArgument';

  @override
  Future<FieldWithTypeArgument> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant SqliteRepository? repository,
  }) async => await _$FieldWithTypeArgumentFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    FieldWithTypeArgument input, {
    required provider,
    covariant SqliteRepository? repository,
  }) async => await _$FieldWithTypeArgumentToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}
""";

@SqliteSerializable()
class FieldWithTypeArgument extends SqliteModel {
  final Map<String, dynamic> someField;

  FieldWithTypeArgument(this.someField);
}
