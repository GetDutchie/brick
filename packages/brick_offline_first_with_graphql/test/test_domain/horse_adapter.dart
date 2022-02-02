part of '__mocks__.dart';

Future<Horse> _$HorseFromGraphql(Map<String, dynamic> data,
    {required GraphqlProvider provider, OfflineFirstWithGraphqlRepository? repository}) async {
  return Horse(
      name: data['name'] as String?,
      mounties: await Future.wait<Mounty>(data['mounties']
              ?.map(
                  (d) => MountyAdapter().fromGraphql(d, provider: provider, repository: repository))
              .toList() ??
          []));
}

Future<Map<String, dynamic>> _$HorseToGraphql(Horse instance,
    {required GraphqlProvider provider, OfflineFirstWithGraphqlRepository? repository}) async {
  return {
    'name': instance.name,
    'mounties': await Future.wait<Map<String, dynamic>>(instance.mounties
        .map((s) => MountyAdapter().toGraphql(s, provider: provider, repository: repository))
        .toList())
  };
}

Future<Horse> _$HorseFromSqlite(Map<String, dynamic> data,
    {required SqliteProvider provider, OfflineFirstWithGraphqlRepository? repository}) async {
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
          .toList())
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$HorseToSqlite(Horse instance,
    {required SqliteProvider provider, OfflineFirstWithGraphqlRepository? repository}) async {
  return {'name': instance.name};
}

/// Construct a [Horse]
class HorseAdapter extends OfflineFirstWithGraphqlAdapter<Horse> {
  HorseAdapter();
  @override
  final defaultDeleteOperation = parseString(
    r'''mutation DeleteDemoModel($input: DemoModel!) {
      deleteDemoModel(input: $input) {}
    }''',
  );

  @override
  final defaultQueryOperation = parseString(
    r'''query GetDemoModels() {
      getDemoModel() {}
    }''',
  );

  @override
  final defaultQueryFilteredOperation = parseString(
    r'''query GetDemoModels($input: DemoModelFilter) {
      getDemoModel(filter: $input) {}
    }''',
  );

  @override
  final defaultSubscriptionOperation = parseString(
    r'''subscription GetDemoModels() {
      getDemoModel() {}
    }''',
  );

  @override
  final defaultSubscriptionFilteredOperation = parseString(
    r'''subscription GetDemoModels($input: DemoModel) {
      getDemoModel(input: $input) {}
    }''',
  );

  @override
  final defaultUpsertOperation = parseString(
    r'''mutation UpsertDemoModels($input: DemoModel) {
      upsertDemoModel(input: $input) {}
    }''',
  );

  @override
  final Map<String, RuntimeGraphqlDefinition> fieldsToGraphqlRuntimeDefinition = {
    'primaryKey': const RuntimeGraphqlDefinition(
      association: false,
      documentNodeName: '_brick_id',
      iterable: false,
      type: int,
    ),
    'name': const RuntimeGraphqlDefinition(
      association: false,
      documentNodeName: 'name',
      iterable: false,
      type: String,
    ),
    'mounties': const RuntimeGraphqlDefinition(
      association: true,
      documentNodeName: 'mounties',
      iterable: true,
      type: Mounty,
    )
  };

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
      await Future.wait<int?>(instance.mounties.map((s) async {
        final id = s.primaryKey ?? await provider.upsert<Mounty>(s, repository: repository);
        return await provider.rawInsert(
            'INSERT OR IGNORE INTO `_brick_Horse_mounties` (`l_Horse_brick_id`, `f_Mounty_brick_id`) VALUES (?, ?)',
            [instance.primaryKey, id]);
      }));
    }
  }

  @override
  Future<Horse> fromGraphql(Map<String, dynamic> input,
          {required provider, covariant OfflineFirstWithGraphqlRepository? repository}) async =>
      await _$HorseFromGraphql(input, provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toGraphql(Horse input,
          {required provider, covariant OfflineFirstWithGraphqlRepository? repository}) async =>
      await _$HorseToGraphql(input, provider: provider, repository: repository);
  @override
  Future<Horse> fromSqlite(Map<String, dynamic> input,
          {required provider, covariant OfflineFirstWithGraphqlRepository? repository}) async =>
      await _$HorseFromSqlite(input, provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toSqlite(Horse input,
          {required provider, covariant OfflineFirstWithGraphqlRepository? repository}) async =>
      await _$HorseToSqlite(input, provider: provider, repository: repository);
}
