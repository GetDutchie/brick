// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<Horse> _$HorseFromRest(Map<String, dynamic> data,
    {required RestProvider provider, OfflineFirstWithRestRepository? repository}) async {
  return Horse(name: data['name'] as String?);
}

Future<Map<String, dynamic>> _$HorseToRest(Horse instance,
    {required RestProvider provider, OfflineFirstWithRestRepository? repository}) async {
  return {'name': instance.name};
}

Future<Horse> _$HorseFromSqlite(Map<String, dynamic> data,
    {required SqliteProvider provider, OfflineFirstWithRestRepository? repository}) async {
  return Horse(name: data['name'] == null ? null : data['name'] as String?)
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$HorseToSqlite(Horse instance,
    {required SqliteProvider provider, OfflineFirstWithRestRepository? repository}) async {
  return {'name': instance.name};
}

/// Construct a [Horse]
class HorseAdapter extends OfflineFirstWithRestAdapter<Horse> {
  HorseAdapter();

  @override
  final Map<String, RuntimeSqliteColumnDefinition> fieldsToSqliteColumns = {
    'primaryKey': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: '_brick_id',
      iterable: false,
      type: int,
    ),
    'name': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'name',
      iterable: false,
      type: String,
    )
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(Horse instance, DatabaseExecutor executor) async =>
      instance.primaryKey;
  @override
  final String tableName = 'Horse';

  @override
  Future<Horse> fromRest(Map<String, dynamic> input,
          {required provider, covariant OfflineFirstWithRestRepository? repository}) async =>
      await _$HorseFromRest(input, provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toRest(Horse input,
          {required provider, covariant OfflineFirstWithRestRepository? repository}) async =>
      await _$HorseToRest(input, provider: provider, repository: repository);
  @override
  Future<Horse> fromSqlite(Map<String, dynamic> input,
          {required provider, covariant OfflineFirstWithRestRepository? repository}) async =>
      await _$HorseFromSqlite(input, provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toSqlite(Horse input,
          {required provider, covariant OfflineFirstWithRestRepository? repository}) async =>
      await _$HorseToSqlite(input, provider: provider, repository: repository);
}
