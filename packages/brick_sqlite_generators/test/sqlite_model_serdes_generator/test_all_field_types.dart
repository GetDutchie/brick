import 'package:brick_sqlite/brick_sqlite.dart';

enum Casing { snake, camel }

const output = r'''
// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<AllFieldTypes> _$AllFieldTypesFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  SqliteFirstRepository? repository,
}) async {
  return AllFieldTypes(
    integer: data['integer'] == null ? null : data['integer'] as int?,
    boolean: data['boolean'] == null ? null : data['boolean'] == 1,
    dub: data['dub'] == null ? null : data['dub'] as double?,
    enumField: data['enum_field'] == null
        ? null
        : (data['enum_field'] > -1
              ? Casing.values[data['enum_field'] as int]
              : null),
    enumList: jsonDecode(data['enum_list'])
        .map((d) => d as int > -1 ? Casing.values[d] : null)
        .whereType<Casing>()
        .toList()
        .cast<Casing>(),
    longerCamelizedVariable: data['longer_camelized_variable'] == null
        ? null
        : data['longer_camelized_variable'] as String?,
    map: jsonDecode(data['map']),
    nullableList: data['nullable_list'] == null
        ? null
        : jsonDecode(data['nullable_list']).toList().cast<int>(),
    nullableMap: data['nullable_map'] == null
        ? null
        : jsonDecode(data['nullable_map']),
    string: data['string'] == null ? null : data['string'] as String?,
    stringSet: jsonDecode(data['string_set']).toSet().cast<String>(),
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$AllFieldTypesToSqlite(
  AllFieldTypes instance, {
  required SqliteProvider provider,
  SqliteFirstRepository? repository,
}) async {
  return {
    'integer': instance.integer,
    'boolean': instance.boolean == null ? null : (instance.boolean! ? 1 : 0),
    'dub': instance.dub,
    'enum_field': instance.enumField != null
        ? Casing.values.indexOf(instance.enumField!)
        : null,
    'enum_list': jsonEncode(
      instance.enumList.map((s) => Casing.values.indexOf(s)).toList(),
    ),
    'longer_camelized_variable': instance.longerCamelizedVariable,
    'map': jsonEncode(instance.map),
    'nullable_list': instance.nullableList == null
        ? null
        : jsonEncode(instance.nullableList),
    'nullable_map': instance.nullableMap != null
        ? jsonEncode(instance.nullableMap)
        : null,
    'string': instance.string,
    'string_set': jsonEncode(instance.stringSet.toList()),
  };
}

/// Construct a [AllFieldTypes]
class AllFieldTypesAdapter extends SqliteAdapter<AllFieldTypes> {
  AllFieldTypesAdapter();

  @override
  final Map<String, RuntimeSqliteColumnDefinition> fieldsToSqliteColumns = {
    'primaryKey': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: '_brick_id',
      iterable: false,
      type: int,
    ),
    'integer': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'integer',
      iterable: false,
      type: int,
    ),
    'boolean': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'boolean',
      iterable: false,
      type: bool,
    ),
    'dub': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'dub',
      iterable: false,
      type: double,
    ),
    'enumField': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'enum_field',
      iterable: false,
      type: Casing,
    ),
    'enumList': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'enum_list',
      iterable: true,
      type: Casing,
    ),
    'longerCamelizedVariable': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'longer_camelized_variable',
      iterable: false,
      type: String,
    ),
    'map': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'map',
      iterable: false,
      type: Map,
    ),
    'nullableList': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'nullable_list',
      iterable: true,
      type: int,
    ),
    'nullableMap': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'nullable_map',
      iterable: false,
      type: Map,
    ),
    'string': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'string',
      iterable: false,
      type: String,
    ),
    'stringSet': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'string_set',
      iterable: true,
      type: String,
    ),
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
    AllFieldTypes instance,
    DatabaseExecutor executor,
  ) async => instance.primaryKey;
  @override
  final String tableName = 'AllFieldTypes';

  @override
  Future<AllFieldTypes> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant SqliteRepository? repository,
  }) async => await _$AllFieldTypesFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    AllFieldTypes input, {
    required provider,
    covariant SqliteRepository? repository,
  }) async => await _$AllFieldTypesToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}
''';

/// [SqliteSerializable] **does not** produce code.
/// A `const` class is required from an non-relative import,
/// and [SqliteSerializable] was arbitrarily chosen for this test.
/// This will do nothing outside of this exact test suite.
@SqliteSerializable()
class AllFieldTypes {
  AllFieldTypes({
    this.integer,
    this.boolean,
    this.dub,
    this.enumField,
    required this.enumList,
    this.longerCamelizedVariable,
    this.nullableList,
    this.nullableMap,
    required this.map,
    this.string,
    required this.stringSet,
  });

  final int? integer;
  final bool? boolean;
  final double? dub;
  final Casing? enumField;
  final List<Casing> enumList;
  final String? longerCamelizedVariable;
  final Map<String, dynamic> map;
  final List<int>? nullableList;
  final Map<String, dynamic>? nullableMap;
  final String? string;
  final Set<String> stringSet;
}
