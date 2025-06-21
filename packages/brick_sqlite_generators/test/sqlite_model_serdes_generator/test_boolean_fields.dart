import 'package:brick_sqlite/brick_sqlite.dart';

const output = r"""
// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<BooleanFields> _$BooleanFieldsFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  SqliteFirstRepository? repository,
}) async {
  return BooleanFields(
    someField: data['some_field'] == null ? null : data['some_field'] == 1,
    nullableField: data['nullable_field'] == null
        ? null
        : data['nullable_field'] == 1,
    multipleFields: data['multiple_fields'] == null
        ? null
        : jsonDecode(
            data['multiple_fields'],
          ).map((d) => d == 1).toList().cast<bool>(),
    multipleNullableFields: data['multiple_nullable_fields'] == null
        ? null
        : jsonDecode(
            data['multiple_nullable_fields'],
          ).map((d) => d == 1).toList().cast<bool>(),
    multipleFutureFields: data['multiple_future_fields'] == null
        ? null
        : jsonDecode(
            data['multiple_future_fields'],
          ).toList().cast<Future<bool>>(),
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$BooleanFieldsToSqlite(
  BooleanFields instance, {
  required SqliteProvider provider,
  SqliteFirstRepository? repository,
}) async {
  return {
    'some_field': instance.someField == null
        ? null
        : (instance.someField! ? 1 : 0),
    'nullable_field': instance.nullableField == null
        ? null
        : (instance.nullableField! ? 1 : 0),
    'multiple_fields': jsonEncode(
      instance.multipleFields
          .map((b) => b == null ? null : (b! ? 1 : 0))
          .toList(),
    ),
    'multiple_nullable_fields': jsonEncode(
      instance.multipleNullableFields
          .map((b) => b == null ? null : (b! ? 1 : 0))
          .toList(),
    ),
    'multiple_future_fields': jsonEncode(
      await Future.wait<bool>(instance.multipleFutureFields) ?? [],
    ),
  };
}

/// Construct a [BooleanFields]
class BooleanFieldsAdapter extends SqliteAdapter<BooleanFields> {
  BooleanFieldsAdapter();

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
      type: bool,
    ),
    'nullableField': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'nullable_field',
      iterable: false,
      type: bool,
    ),
    'multipleFields': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'multiple_fields',
      iterable: true,
      type: bool,
    ),
    'multipleNullableFields': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'multiple_nullable_fields',
      iterable: true,
      type: bool,
    ),
    'multipleFutureFields': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'multiple_future_fields',
      iterable: true,
      type: bool,
    ),
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
    BooleanFields instance,
    DatabaseExecutor executor,
  ) async => instance.primaryKey;
  @override
  final String tableName = 'BooleanFields';

  @override
  Future<BooleanFields> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant SqliteRepository? repository,
  }) async => await _$BooleanFieldsFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    BooleanFields input, {
    required provider,
    covariant SqliteRepository? repository,
  }) async => await _$BooleanFieldsToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}
""";

@SqliteSerializable()
class BooleanFields extends SqliteModel {
  final bool? someField;

  @Sqlite(nullable: true)
  final bool? nullableField;

  final List<bool>? multipleFields;

  @Sqlite(nullable: true)
  final List<bool>? multipleNullableFields;

  final List<Future<bool>>? multipleFutureFields;

  BooleanFields({
    this.someField,
    this.nullableField,
    this.multipleFields,
    this.multipleNullableFields,
    this.multipleFutureFields,
  });
}
