import 'package:brick_sqlite_abstract/annotations.dart';

final output = r'''
// GENERATED CODE DO NOT EDIT
// This file should NOT be version controlled and should not be manually edited.
part of '../brick.g.dart';

Future<ToFromJson> _$ToFromJsonFromSqlite(Map<String, dynamic> data,
    {required SqliteProvider provider,
    SqliteFirstRepository? repository}) async {
  return ToFromJson(
      assoc: data['assoc'] == null
          ? null
          : ToFromJsonAssoc.fromJson(jsonDecode(data['assoc'])))
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$ToFromJsonToSqlite(ToFromJson instance,
    {required SqliteProvider provider,
    SqliteFirstRepository? repository}) async {
  return {'assoc': jsonEncode(instance.assoc.toJson())};
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
    )
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
          ToFromJson instance, DatabaseExecutor executor) async =>
      instance.primaryKey;
  @override
  final String tableName = 'ToFromJson';

  @override
  Future<ToFromJson> fromSqlite(Map<String, dynamic> input,
          {required provider, covariant SqliteRepository? repository}) async =>
      await _$ToFromJsonFromSqlite(input,
          provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toSqlite(ToFromJson input,
          {required provider, covariant SqliteRepository? repository}) async =>
      await _$ToFromJsonToSqlite(input,
          provider: provider, repository: repository);
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
  final ToFromJsonAssoc? assoc;

  ToFromJson({
    this.assoc,
  });
}
