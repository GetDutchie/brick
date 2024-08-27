// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<Horse> _$HorseFromSupabase(Map<String, dynamic> data,
    {required SupabaseProvider provider, OfflineFirstWithSupabaseRepository? repository}) async {
  return Horse(
      name: data['name'] as String?,
      mounties: await Future.wait<Mounty>(data['mounties']
              ?.map((d) =>
                  MountyAdapter().fromSupabase(d, provider: provider, repository: repository))
              .toList()
              .cast<Future<Mounty>>() ??
          []));
}

Future<Map<String, dynamic>> _$HorseToSupabase(Horse instance,
    {required SupabaseProvider provider, OfflineFirstWithSupabaseRepository? repository}) async {
  return {
    'name': instance.name,
    'mounties': await Future.wait<Map<String, dynamic>>(instance.mounties
            ?.map((s) => MountyAdapter().toSupabase(s, provider: provider, repository: repository))
            .toList() ??
        [])
  };
}

Future<Horse> _$HorseFromSqlite(Map<String, dynamic> data,
    {required SqliteProvider provider, OfflineFirstWithSupabaseRepository? repository}) async {
  return Horse(
      name: data['name'] == null ? null : data['name'] as String?,
      mounties: (await provider.rawQuery(
              'SELECT DISTINCT `f_Mounty_brick_id` FROM `_brick_Horse_mounties` WHERE l_Horse_brick_id = ?',
              [data['_brick_id'] as int]).then((results) {
        final ids = results.map((r) => r['f_Mounty_brick_id']);
        return Future.wait<Mounty>(ids.map((primaryKey) => repository!
            .getAssociation<Mounty>(
              Query.where('primaryKey', primaryKey, limit1: true),
            )
            .then((r) => r!.first)));
      }))
          .toList()
          .cast<Mounty>())
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$HorseToSqlite(Horse instance,
    {required SqliteProvider provider, OfflineFirstWithSupabaseRepository? repository}) async {
  return {'name': instance.name};
}

/// Construct a [Horse]
class HorseAdapter extends OfflineFirstWithSupabaseAdapter<Horse> {
  HorseAdapter();

  @override
  final defaultToNull = true;
  @override
  final fieldsToSupabaseColumns = {
    'name': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'name',
    ),
    'mounties': const RuntimeSupabaseColumnDefinition(
      association: true,
      columnName: 'mounties',
    )
  };
  @override
  final ignoreDuplicates = false;
  @override
  final uniqueFields = {};
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
    ),
    'mounties': const RuntimeSqliteColumnDefinition(
      association: true,
      columnName: 'mounties',
      iterable: true,
      type: Mounty,
    )
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(Horse instance, DatabaseExecutor executor) async =>
      instance.primaryKey;
  @override
  final String tableName = 'Horse';
  @override
  Future<void> afterSave(instance, {required provider, repository}) async {
    if (instance.primaryKey != null) {
      final mountiesOldColumns = await provider.rawQuery(
          'SELECT `f_Mounty_brick_id` FROM `_brick_Horse_mounties` WHERE `l_Horse_brick_id` = ?',
          [instance.primaryKey]);
      final mountiesOldIds = mountiesOldColumns.map((a) => a['f_Mounty_brick_id']);
      final mountiesNewIds = instance.mounties?.map((s) => s.primaryKey).whereType<int>() ?? [];
      final mountiesIdsToDelete = mountiesOldIds.where((id) => !mountiesNewIds.contains(id));

      await Future.wait<void>(mountiesIdsToDelete.map((id) async {
        return await provider.rawExecute(
            'DELETE FROM `_brick_Horse_mounties` WHERE `l_Horse_brick_id` = ? AND `f_Mounty_brick_id` = ?',
            [instance.primaryKey, id]).catchError((e) => null);
      }));

      await Future.wait<int?>(instance.mounties?.map((s) async {
            final id = s.primaryKey ?? await provider.upsert<Mounty>(s, repository: repository);
            return await provider.rawInsert(
                'INSERT OR IGNORE INTO `_brick_Horse_mounties` (`l_Horse_brick_id`, `f_Mounty_brick_id`) VALUES (?, ?)',
                [instance.primaryKey, id]);
          }) ??
          []);
    }
  }

  @override
  Future<Horse> fromSupabase(Map<String, dynamic> input,
          {required provider, covariant OfflineFirstWithSupabaseRepository? repository}) async =>
      await _$HorseFromSupabase(input, provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toSupabase(Horse input,
          {required provider, covariant OfflineFirstWithSupabaseRepository? repository}) async =>
      await _$HorseToSupabase(input, provider: provider, repository: repository);
  @override
  Future<Horse> fromSqlite(Map<String, dynamic> input,
          {required provider, covariant OfflineFirstWithSupabaseRepository? repository}) async =>
      await _$HorseFromSqlite(input, provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toSqlite(Horse input,
          {required provider, covariant OfflineFirstWithSupabaseRepository? repository}) async =>
      await _$HorseToSqlite(input, provider: provider, repository: repository);
}
