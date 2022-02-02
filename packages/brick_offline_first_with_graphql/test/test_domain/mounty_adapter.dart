part of '__mocks__.dart';

Future<Mounty> _$MountyFromGraphql(Map<String, dynamic> data,
    {required GraphqlProvider provider, OfflineFirstWithGraphqlRepository? repository}) async {
  return Mounty(name: data['name'] as String?);
}

Future<Map<String, dynamic>> _$MountyToGraphql(Mounty instance,
    {required GraphqlProvider provider, OfflineFirstWithGraphqlRepository? repository}) async {
  return {'name': instance.name};
}

Future<Mounty> _$MountyFromSqlite(Map<String, dynamic> data,
    {required SqliteProvider provider, OfflineFirstWithGraphqlRepository? repository}) async {
  return Mounty(name: data['name'] == null ? null : data['name'] as String?)
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$MountyToSqlite(Mounty instance,
    {required SqliteProvider provider, OfflineFirstWithGraphqlRepository? repository}) async {
  return {'name': instance.name};
}

/// Construct a [Mounty]
class MountyAdapter extends OfflineFirstWithGraphqlAdapter<Mounty> {
  MountyAdapter();
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
  final Map<String, RuntimeGraphqlDefinition> fieldsToGraphqlRuntimeDefinition = {
    'name': const RuntimeGraphqlDefinition(
      association: false,
      documentNodeName: 'name',
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
  Future<Mounty> fromGraphql(Map<String, dynamic> input,
          {required provider, covariant OfflineFirstWithGraphqlRepository? repository}) async =>
      await _$MountyFromGraphql(input, provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toGraphql(Mounty input,
          {required provider, covariant OfflineFirstWithGraphqlRepository? repository}) async =>
      await _$MountyToGraphql(input, provider: provider, repository: repository);
  @override
  Future<Mounty> fromSqlite(Map<String, dynamic> input,
          {required provider, covariant OfflineFirstWithGraphqlRepository? repository}) async =>
      await _$MountyFromSqlite(input, provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toSqlite(Mounty input,
          {required provider, covariant OfflineFirstWithGraphqlRepository? repository}) async =>
      await _$MountyToSqlite(input, provider: provider, repository: repository);
}
