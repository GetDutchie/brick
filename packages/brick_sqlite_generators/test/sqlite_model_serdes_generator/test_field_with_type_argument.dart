import 'package:brick_sqlite_abstract/annotations.dart';
import 'package:brick_sqlite_abstract/sqlite_model.dart';

final output = r"""
// GENERATED CODE DO NOT EDIT
// This file should NOT be version controlled and should not be manually edited.
part of '../brick.g.dart';

Future<FieldWithTypeArgument> _$FieldWithTypeArgumentFromSqlite(
    Map<String, dynamic> data,
    {SqliteProvider provider,
    SqliteFirstRepository repository}) async {
  return FieldWithTypeArgument(
      someField:
          data['some_field'] == null ? null : jsonDecode(data['some_field']))
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$FieldWithTypeArgumentToSqlite(
    FieldWithTypeArgument instance,
    {SqliteProvider provider,
    SqliteFirstRepository repository}) async {
  return {'some_field': jsonEncode(instance.someField ?? {})};
}

/// Construct a [FieldWithTypeArgument]
class FieldWithTypeArgumentAdapter
    extends SqliteAdapter<FieldWithTypeArgument> {
  FieldWithTypeArgumentAdapter();

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
      type: Map,
    ),
  };
  Future<int> primaryKeyByUniqueColumns(
          FieldWithTypeArgument instance, DatabaseExecutor executor) async =>
      instance?.primaryKey;
  final String tableName = 'FieldWithTypeArgument';

  Future<FieldWithTypeArgument> fromSqlite(Map<String, dynamic> input,
          {provider, repository}) async =>
      await _$FieldWithTypeArgumentFromSqlite(input,
          provider: provider, repository: repository);
  Future<Map<String, dynamic>> toSqlite(FieldWithTypeArgument input,
          {provider, repository}) async =>
      await _$FieldWithTypeArgumentToSqlite(input,
          provider: provider, repository: repository);
}
""";

@SqliteSerializable()
class FieldWithTypeArgument extends SqliteModel {
  final Map<String, dynamic> someField;

  FieldWithTypeArgument(this.someField);
}
