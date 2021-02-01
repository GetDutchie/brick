// GENERATED CODE DO NOT EDIT
// This file should NOT be version controlled and should not be manually edited.
part of '../brick.g.dart';

Future<Horse> _$HorseFromRest(Map<String, dynamic> data,
    {RestProvider provider, OfflineFirstWithRestRepository repository}) async {
  return Horse(
      name: data['name'] as String,
      mounties: await Future.wait<Mounty>(data['mounties']
              ?.map((d) => MountyAdapter()
                  .fromRest(d, provider: provider, repository: repository))
              ?.toList()
              ?.cast<Future<Mounty>>() ??
          []));
}

Future<Map<String, dynamic>> _$HorseToRest(Horse instance,
    {RestProvider provider, OfflineFirstWithRestRepository repository}) async {
  return {
    'name': instance.name,
    'mounties': await Future.wait<Map<String, dynamic>>(instance.mounties
            ?.map((s) => MountyAdapter()
                .toRest(s, provider: provider, repository: repository))
            ?.toList() ??
        [])
  };
}

Future<Horse> _$HorseFromSqlite(Map<String, dynamic> data,
    {SqliteProvider provider,
    OfflineFirstWithRestRepository repository}) async {
  return Horse(
      name: data['name'] == null ? null : data['name'] as String,
      mounties: (await provider?.rawQuery(
              'SELECT DISTINCT `f_Mounty_brick_id` FROM `_brick_Horse_mounties` WHERE l_Horse_brick_id = ?',
              [data['_brick_id'] as int])?.then((results) {
        final ids = results.map((r) => (r ?? {})['f_Mounty_brick_id']);
        return Future.wait<Mounty>(ids.map((primaryKey) => repository
            ?.getAssociation<Mounty>(
              Query.where('primaryKey', primaryKey, limit1: true),
            )
            ?.then((r) => (r?.isEmpty ?? true) ? null : r.first)));
      }))
          ?.toList()
          ?.cast<Mounty>())
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$HorseToSqlite(Horse instance,
    {SqliteProvider provider,
    OfflineFirstWithRestRepository repository}) async {
  return {'name': instance.name};
}

/// Construct a [Horse]
class HorseAdapter extends OfflineFirstWithRestAdapter<Horse> {
  HorseAdapter();

  String restEndpoint({query, instance}) => '';
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
    'mounties': RuntimeSqliteColumnDefinition(
      association: true,
      columnName: 'mounties',
      iterable: true,
      type: Mounty,
    )
  };
  Future<int> primaryKeyByUniqueColumns(
          Horse instance, DatabaseExecutor executor) async =>
      instance?.primaryKey;
  final String tableName = 'Horse';
  Future<void> afterSave(instance, {provider, repository}) async {
    if (instance.primaryKey != null) {
      await Future.wait<int>(instance.mounties?.map((s) async {
            final id = s?.primaryKey ??
                await provider?.upsert<Mounty>(s, repository: repository);
            return await provider?.rawInsert(
                'INSERT OR IGNORE INTO `_brick_Horse_mounties` (`l_Horse_brick_id`, `f_Mounty_brick_id`) VALUES (?, ?)',
                [instance.primaryKey, id]);
          }) ??
          []);
    }
  }

  Future<Horse> fromRest(Map<String, dynamic> input,
          {provider, repository}) async =>
      await _$HorseFromRest(input, provider: provider, repository: repository);
  Future<Map<String, dynamic>> toRest(Horse input,
          {provider, repository}) async =>
      await _$HorseToRest(input, provider: provider, repository: repository);
  Future<Horse> fromSqlite(Map<String, dynamic> input,
          {provider, repository}) async =>
      await _$HorseFromSqlite(input,
          provider: provider, repository: repository);
  Future<Map<String, dynamic>> toSqlite(Horse input,
          {provider, repository}) async =>
      await _$HorseToSqlite(input, provider: provider, repository: repository);
}
