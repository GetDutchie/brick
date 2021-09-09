part of '__mocks__.dart';

Future<Mounty> _$MountyFromRest(Map<String, dynamic> data,
    {required RestProvider provider, OfflineFirstWithRestRepository? repository}) async {
  return Mounty(name: data['name'] as String?);
}

Future<Map<String, dynamic>> _$MountyToRest(Mounty instance,
    {required RestProvider provider, OfflineFirstWithRestRepository? repository}) async {
  return {'name': instance.name};
}

Future<Mounty> _$MountyFromSqlite(Map<String, dynamic> data,
    {required SqliteProvider provider, OfflineFirstWithRestRepository? repository}) async {
  return Mounty(name: data['name'] == null ? null : data['name'] as String?)
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$MountyToSqlite(Mounty instance,
    {required SqliteProvider provider, OfflineFirstWithRestRepository? repository}) async {
  return {'name': instance.name};
}

/// Construct a [Mounty]
class MountyAdapter extends OfflineFirstWithRestAdapter<Mounty> {
  MountyAdapter();

  @override
  String? restEndpoint({query, instance}) => '/mounties';
  @override
  final String? fromKey = null;
  @override
  final String? toKey = null;
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
  Future<int?> primaryKeyByUniqueColumns(Mounty instance, DatabaseExecutor executor) async =>
      instance.primaryKey;
  @override
  final String tableName = 'Mounty';

  @override
  Future<Mounty> fromRest(Map<String, dynamic> input,
          {required provider, covariant OfflineFirstWithRestRepository? repository}) async =>
      await _$MountyFromRest(input, provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toRest(Mounty input,
          {required provider, covariant OfflineFirstWithRestRepository? repository}) async =>
      await _$MountyToRest(input, provider: provider, repository: repository);
  @override
  Future<Mounty> fromSqlite(Map<String, dynamic> input,
          {required provider, covariant OfflineFirstWithRestRepository? repository}) async =>
      await _$MountyFromSqlite(input, provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toSqlite(Mounty input,
          {required provider, covariant OfflineFirstWithRestRepository? repository}) async =>
      await _$MountyToSqlite(input, provider: provider, repository: repository);
}
