part of '__mocks__.dart';

Future<Horse> _$HorseFromRest(
  Map<String, dynamic> data, {
  required RestProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return Horse(
    name: data['name'] as String?,
    mounties: await Future.wait<Mounty>(
      data['mounties']
              ?.map((d) => MountyAdapter().fromRest(d, provider: provider, repository: repository))
              .toList() ??
          [],
    ),
  );
}

Future<Map<String, dynamic>> _$HorseToRest(
  Horse instance, {
  required RestProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return {
    'name': instance.name,
    'mounties': await Future.wait<Map<String, dynamic>>(
      instance.mounties
          .map((s) => MountyAdapter().toRest(s, provider: provider, repository: repository))
          .toList(),
    ),
  };
}

Future<Horse> _$HorseFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return Horse(
    name: data['name'] == null ? null : data['name'] as String?,
    mounties: (await provider.rawQuery(
      'SELECT DISTINCT `f_Mounty_brick_id` FROM `_brick_Horse_mounties` WHERE l_Horse_brick_id = ?',
      [data['_brick_id'] as int],
    ).then((results) {
      final ids = results.map((r) => r['f_Mounty_brick_id']);
      return Future.wait<Mounty>(
        ids.map(
          (primaryKey) => repository!
              .getAssociation<Mounty>(
                Query.where('primaryKey', primaryKey, limit1: true),
              )
              .then((r) => r!.first),
        ),
      );
    }))
        .toList(),
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$HorseToSqlite(
  Horse instance, {
  required SqliteProvider provider,
  OfflineFirstWithRestRepository? repository,
}) async {
  return {'name': instance.name};
}

/// Construct a [Horse]
class HorseAdapter extends OfflineFirstWithRestAdapter<Horse> {
  HorseAdapter();

  @override
  final fieldsToSqliteColumns = <String, RuntimeSqliteColumnDefinition>{
    'primaryKey': const RuntimeSqliteColumnDefinition(
      columnName: '_brick_id',
      type: int,
    ),
    'name': const RuntimeSqliteColumnDefinition(
      columnName: 'name',
      type: String,
    ),
    'mounties': const RuntimeSqliteColumnDefinition(
      association: true,
      columnName: 'mounties',
      iterable: true,
      type: Mounty,
    ),
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(Horse instance, DatabaseExecutor executor) async =>
      instance.primaryKey;
  @override
  final tableName = 'Horse';
  @override
  Future<void> afterSave(
    Horse instance, {
    required SqliteProvider<SqliteModel> provider,
    ModelRepository<SqliteModel>? repository,
  }) async {
    if (instance.primaryKey != null) {
      await Future.wait<int?>(
        instance.mounties.map((s) async {
          final id = s.primaryKey ?? await provider.upsert<Mounty>(s, repository: repository);
          return await provider.rawInsert(
            'INSERT OR IGNORE INTO `_brick_Horse_mounties` (`l_Horse_brick_id`, `f_Mounty_brick_id`) VALUES (?, ?)',
            [instance.primaryKey, id],
          );
        }),
      );
    }
  }

  @override
  Future<Horse> fromRest(
    Map<String, dynamic> input, {
    required RestProvider provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async =>
      await _$HorseFromRest(input, provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toRest(
    Horse input, {
    required RestProvider provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async =>
      await _$HorseToRest(input, provider: provider, repository: repository);
  @override
  Future<Horse> fromSqlite(
    Map<String, dynamic> input, {
    required SqliteProvider<SqliteModel> provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async =>
      await _$HorseFromSqlite(input, provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toSqlite(
    Horse input, {
    required SqliteProvider<SqliteModel> provider,
    covariant OfflineFirstWithRestRepository? repository,
  }) async =>
      await _$HorseToSqlite(input, provider: provider, repository: repository);
}
