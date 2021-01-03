import 'package:brick_sqlite_abstract/annotations.dart';
import 'package:brick_sqlite_abstract/sqlite_model.dart';

final output = r"""
// GENERATED CODE DO NOT EDIT
// This file should NOT be version controlled and should not be manually edited.
part of '../brick.g.dart';

Future<BooleanFields> _$BooleanFieldsFromSqlite(Map<String, dynamic> data,
    {SqliteProvider provider, SqliteFirstRepository repository}) async {
  return BooleanFields(
      someField: data['some_field'] == null ? null : data['some_field'] == 1,
      nullableField:
          data['nullable_field'] == null ? null : data['nullable_field'] == 1,
      multipleFields: data['multiple_fields'] == null
          ? null
          : jsonDecode(data['multiple_fields'])
              .map((d) => d == 1)
              ?.toList()
              ?.cast<bool>(),
      multipleNullableFields: data['multiple_nullable_fields'] == null
          ? null
          : jsonDecode(data['multiple_nullable_fields'])
              .map((d) => d == 1)
              ?.toList()
              ?.cast<bool>(),
      multipleFutureFields: data['multiple_future_fields'] == null
          ? null
          : jsonDecode(data['multiple_future_fields'])
              ?.toList()
              ?.cast<Future<bool>>())
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$BooleanFieldsToSqlite(BooleanFields instance,
    {SqliteProvider provider, SqliteFirstRepository repository}) async {
  return {
    'some_field':
        instance.someField == null ? null : (instance.someField ? 1 : 0),
    'nullable_field': instance.nullableField == null
        ? null
        : (instance.nullableField ? 1 : 0),
    'multiple_fields': jsonEncode(instance.multipleFields
        .map((b) => b == null ? null : (b ? 1 : 0))
        .toList()),
    'multiple_nullable_fields': jsonEncode(instance.multipleNullableFields
        .map((b) => b == null ? null : (b ? 1 : 0))
        .toList()),
    'multiple_future_fields':
        jsonEncode(await Future.wait<bool>(instance.multipleFutureFields) ?? [])
  };
}

/// Construct a [BooleanFields]
class BooleanFieldsAdapter extends SqliteAdapter<BooleanFields> {
  BooleanFieldsAdapter();

  final Map<String, Map<String, dynamic>> fieldsToSqliteColumns = {
    'primaryKey': SqliteColumnDefinition(
      association: false,
      iterable: false,
      name: '_brick_id',
      type: int,
    ),
    'someField': SqliteColumnDefinition(
      association: false,
      iterable: false,
      name: 'some_field',
      type: bool,
    ),
    'nullableField': SqliteColumnDefinition(
      association: false,
      iterable: false,
      name: 'nullable_field',
      type: bool,
    ),
    'multipleFields': SqliteColumnDefinition(
      association: false,
      iterable: true,
      name: 'multiple_fields',
      type: bool,
    ),
    'multipleNullableFields': SqliteColumnDefinition(
      association: false,
      iterable: true,
      name: 'multiple_nullable_fields',
      type: bool,
    ),
    'multipleFutureFields': SqliteColumnDefinition(
      association: false,
      iterable: true,
      name: 'multiple_future_fields',
      type: bool,
    ),
  };
  Future<int> primaryKeyByUniqueColumns(
          BooleanFields instance, DatabaseExecutor executor) async =>
      instance?.primaryKey;
  final String tableName = 'BooleanFields';

  Future<BooleanFields> fromSqlite(Map<String, dynamic> input,
          {provider, repository}) async =>
      await _$BooleanFieldsFromSqlite(input,
          provider: provider, repository: repository);
  Future<Map<String, dynamic>> toSqlite(BooleanFields input,
          {provider, repository}) async =>
      await _$BooleanFieldsToSqlite(input,
          provider: provider, repository: repository);
}
""";

@SqliteSerializable()
class BooleanFields extends SqliteModel {
  final bool someField;

  @Sqlite(nullable: true)
  final bool nullableField;

  final List<bool> multipleFields;

  @Sqlite(nullable: true)
  final List<bool> multipleNullableFields;

  final List<Future<bool>> multipleFutureFields;

  BooleanFields({
    this.someField,
    this.nullableField,
    this.multipleFields,
    this.multipleNullableFields,
    this.multipleFutureFields,
  });
}
