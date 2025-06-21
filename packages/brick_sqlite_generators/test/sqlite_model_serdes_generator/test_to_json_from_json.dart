import 'package:brick_sqlite/brick_sqlite.dart';

const output = r'''
// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<ToFromJson> _$ToFromJsonFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  SqliteFirstRepository? repository,
}) async {
  return ToFromJson(
    assoc: ToFromJsonAssoc.fromJson(
      jsonDecode(data['assoc'] as String) as String,
    ),
    assocNullable: data['assoc_nullable'] == null
        ? null
        : ToFromJsonAssoc.fromJson(
            jsonDecode(data['assoc_nullable'] as String) as String,
          ),
    assocIterable: jsonDecode(data['assoc_iterable'])
        .map((d) => ToFromJsonAssoc.fromJson(d as String))
        .toList()
        .cast<ToFromJsonAssoc>(),
    assocIterableNullable: data['assoc_iterable_nullable'] == null
        ? null
        : jsonDecode(data['assoc_iterable_nullable'] ?? '[]')
              .map((d) => ToFromJsonAssoc.fromJson(d as String))
              .toList()
              .cast<ToFromJsonAssoc>(),
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$ToFromJsonToSqlite(
  ToFromJson instance, {
  required SqliteProvider provider,
  SqliteFirstRepository? repository,
}) async {
  return {
    'assoc': jsonEncode(instance.assoc.toJson()),
    'assoc_nullable': instance.assocNullable != null
        ? jsonEncode(instance.assocNullable!.toJson())
        : null,
    'assoc_iterable': jsonEncode(instance.assocIterable),
    'assoc_iterable_nullable': instance.assocIterableNullable != null
        ? jsonEncode(instance.assocIterableNullable)
        : null,
  };
}

/// Construct a [ToFromJson]
class ToFromJsonAdapter extends SqliteAdapter<ToFromJson> {
  ToFromJsonAdapter();

  @override
  final Map<String, RuntimeSqliteColumnDefinition> fieldsToSqliteColumns = {
    'primaryKey': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: '_brick_id',
      iterable: false,
      type: int,
    ),
    'assoc': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'assoc',
      iterable: false,
      type: String,
    ),
    'assocNullable': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'assoc_nullable',
      iterable: false,
      type: String,
    ),
    'assocIterable': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'assoc_iterable',
      iterable: true,
      type: String,
    ),
    'assocIterableNullable': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'assoc_iterable_nullable',
      iterable: true,
      type: String,
    ),
    'ignoredIterable': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'ignored_iterable',
      iterable: true,
      type: String,
    ),
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
    ToFromJson instance,
    DatabaseExecutor executor,
  ) async => instance.primaryKey;
  @override
  final String tableName = 'ToFromJson';

  @override
  Future<ToFromJson> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant SqliteRepository? repository,
  }) async => await _$ToFromJsonFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    ToFromJson input, {
    required provider,
    covariant SqliteRepository? repository,
  }) async => await _$ToFromJsonToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}
''';

class ToFromJsonAssoc {
  final int? integer;

  ToFromJsonAssoc({
    this.integer,
  });

  String toJson() => integer.toString();

  factory ToFromJsonAssoc.fromJson(String data) => ToFromJsonAssoc(integer: int.tryParse(data));
}

@SqliteSerializable()
class ToFromJson {
  final ToFromJsonAssoc assoc;
  final ToFromJsonAssoc? assocNullable;
  final List<ToFromJsonAssoc> assocIterable;
  final List<ToFromJsonAssoc>? assocIterableNullable;

  @Sqlite(ignore: true)
  final List<ToFromJsonAssoc> ignoredIterable;

  ToFromJson({
    required this.assoc,
    required this.assocNullable,
    required this.assocIterable,
    required this.assocIterableNullable,
    required this.ignoredIterable,
  });
}
