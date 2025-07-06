import 'package:brick_sqlite/brick_sqlite.dart';

const output = r"""
// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<SqliteEnumAsString> _$SqliteEnumAsStringFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  SqliteFirstRepository? repository,
}) async {
  return SqliteEnumAsString(
    someField: MyEnum.values.byName(data['some_field'] as String),
    someFields: jsonDecode(
      data['some_fields'] ?? [],
    ).whereType<String>().map(MyEnum.values.byName).toList().cast<MyEnum>(),
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$SqliteEnumAsStringToSqlite(
  SqliteEnumAsString instance, {
  required SqliteProvider provider,
  SqliteFirstRepository? repository,
}) async {
  return {
    'some_field': instance.someField.name,
    'some_fields': jsonEncode(instance.someFields.map((s) => s.name).toList()),
  };
}

/// Construct a [SqliteEnumAsString]
class SqliteEnumAsStringAdapter extends SqliteAdapter<SqliteEnumAsString> {
  SqliteEnumAsStringAdapter();

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
      type: MyEnum,
    ),
    'someFields': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'some_fields',
      iterable: true,
      type: MyEnum,
    ),
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
    SqliteEnumAsString instance,
    DatabaseExecutor executor,
  ) async => instance.primaryKey;
  @override
  final String tableName = 'SqliteEnumAsString';

  @override
  Future<SqliteEnumAsString> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant SqliteRepository? repository,
  }) async => await _$SqliteEnumAsStringFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    SqliteEnumAsString input, {
    required provider,
    covariant SqliteRepository? repository,
  }) async => await _$SqliteEnumAsStringToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}
""";

enum MyEnum { first, second, third }

@SqliteSerializable()
class SqliteEnumAsString extends SqliteModel {
  @Sqlite(enumAsString: true)
  final MyEnum someField;

  @Sqlite(enumAsString: true)
  final List<MyEnum> someFields;

  SqliteEnumAsString(this.someField, this.someFields);
}
