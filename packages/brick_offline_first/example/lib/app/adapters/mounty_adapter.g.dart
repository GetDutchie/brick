// GENERATED CODE DO NOT EDIT
// This file should NOT be version controlled and should not be manually edited.
part of '../brick.g.dart';

Future<Mounty> _$MountyFromRest(Map<String, dynamic> data,
    {RestProvider provider, OfflineFirstWithRestRepository repository}) async {
  return Mounty(
      name: data['name'] as String,
      email: data['email'] as String,
      hat: Hat.fromRest(data['hat']));
}

Future<Map<String, dynamic>> _$MountyToRest(Mounty instance,
    {RestProvider provider, OfflineFirstWithRestRepository repository}) async {
  return {
    'name': instance.name,
    'email': instance.email,
    'hat': instance.hat?.toRest()
  };
}

Future<Mounty> _$MountyFromSqlite(Map<String, dynamic> data,
    {SqliteProvider provider,
    OfflineFirstWithRestRepository repository}) async {
  return Mounty(
      name: data['name'] == null ? null : data['name'] as String,
      email: data['email'] == null ? null : data['email'] as String,
      hat: data['hat'] == null ? null : Hat.fromSqlite(data['hat'] as String))
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$MountyToSqlite(Mounty instance,
    {SqliteProvider provider,
    OfflineFirstWithRestRepository repository}) async {
  return {
    'name': instance.name,
    'email': instance.email,
    'hat': instance.hat?.toSqlite()
  };
}

/// Construct a [Mounty]
class MountyAdapter extends OfflineFirstWithRestAdapter<Mounty> {
  MountyAdapter();

  String restEndpoint({query, instance}) => "/mounties";
  final String fromKey = null;
  final String toKey = null;
  final Map<String, RuntimeSqliteColumnDefinition> fieldsToSqliteColumns = {
    'primaryKey': RuntimeSqliteColumnDefinition(
      association: false,
      columnName: '_brick_id',
      iterable: false,
      type: int,
    ),
    'name': RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'name',
      iterable: false,
      type: String,
    ),
    'email': RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'email',
      iterable: false,
      type: String,
    ),
    'hat': RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'hat',
      iterable: false,
      type: Hat,
    )
  };
  Future<int> primaryKeyByUniqueColumns(
          Mounty instance, DatabaseExecutor executor) async =>
      instance?.primaryKey;
  final String tableName = 'Mounty';

  Future<Mounty> fromRest(Map<String, dynamic> input,
          {provider, repository}) async =>
      await _$MountyFromRest(input, provider: provider, repository: repository);
  Future<Map<String, dynamic>> toRest(Mounty input,
          {provider, repository}) async =>
      await _$MountyToRest(input, provider: provider, repository: repository);
  Future<Mounty> fromSqlite(Map<String, dynamic> input,
          {provider, repository}) async =>
      await _$MountyFromSqlite(input,
          provider: provider, repository: repository);
  Future<Map<String, dynamic>> toSqlite(Mounty input,
          {provider, repository}) async =>
      await _$MountyToSqlite(input, provider: provider, repository: repository);
}
