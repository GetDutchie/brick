part of '__mocks__.dart';

Future<Mounty> _$MountyFromGraphql(
  Map<String, dynamic> data, {
  required GraphqlProvider provider,
  OfflineFirstWithGraphqlRepository? repository,
}) async {
  return Mounty(name: data['name'] as String?);
}

Future<Map<String, dynamic>> _$MountyToGraphql(
  Mounty instance, {
  required GraphqlProvider provider,
  OfflineFirstWithGraphqlRepository? repository,
}) async {
  return {'name': instance.name};
}

Future<Mounty> _$MountyFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstWithGraphqlRepository? repository,
}) async {
  return Mounty(name: data['name'] == null ? null : data['name'] as String?)
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$MountyToSqlite(
  Mounty instance, {
  required SqliteProvider provider,
  OfflineFirstWithGraphqlRepository? repository,
}) async {
  return {'name': instance.name};
}

class MountyOperationTransformer extends GraphqlQueryOperationTransformer {
  @override
  GraphqlOperation get delete => const GraphqlOperation(
        document: r'''mutation DeleteDemoModel($input: DemoModelInput!) {
      deleteDemoModel(input: $input) {}
    }''',
      );

  @override
  GraphqlOperation get get {
    var document = '''query GetDemoModels() {
      getDemoModels() {}
    }''';

    if (query?.where != null) {
      document = r'''query GetDemoModel($input: DemoModelFilterInput) {
        getDemoModel(input: $input) {}
      }''';
    }
    return GraphqlOperation(document: document);
  }

  @override
  GraphqlOperation get subscribe {
    var document = '''subscription GetDemoModels() {
      getDemoModels() {}
    }''';

    if (query?.where != null) {
      document = r'''subscription GetDemoModels($input: DemoModelInput) {
      getDemoModels(input: $input) {}
    }''';
    }
    return GraphqlOperation(document: document);
  }

  @override
  GraphqlOperation get upsert => const GraphqlOperation(
        document: r'''mutation UpsertDemoModels($input: DemoModelInput) {
      upsertDemoModel(input: $input) {}
    }''',
      );

  const MountyOperationTransformer(super.query, GraphqlModel? super.instance);
}

/// Construct a [Mounty]
class MountyAdapter extends OfflineFirstWithGraphqlAdapter<Mounty> {
  @override
  final queryOperationTransformer = MountyOperationTransformer.new;

  MountyAdapter();

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
  };

  @override
  final fieldsToGraphqlRuntimeDefinition = <String, RuntimeGraphqlDefinition>{
    'name': const RuntimeGraphqlDefinition(
      documentNodeName: 'name',
      type: String,
    ),
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(Mounty instance, DatabaseExecutor executor) async =>
      instance.primaryKey;
  @override
  final tableName = 'Mounty';

  @override
  Future<Mounty> fromGraphql(
    Map<String, dynamic> input, {
    required GraphqlProvider provider,
    covariant OfflineFirstWithGraphqlRepository? repository,
  }) async =>
      await _$MountyFromGraphql(input, provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toGraphql(
    Mounty input, {
    required GraphqlProvider provider,
    covariant OfflineFirstWithGraphqlRepository? repository,
  }) async =>
      await _$MountyToGraphql(input, provider: provider, repository: repository);
  @override
  Future<Mounty> fromSqlite(
    Map<String, dynamic> input, {
    required SqliteProvider<SqliteModel> provider,
    covariant OfflineFirstWithGraphqlRepository? repository,
  }) async =>
      await _$MountyFromSqlite(input, provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toSqlite(
    Mounty input, {
    required SqliteProvider<SqliteModel> provider,
    covariant OfflineFirstWithGraphqlRepository? repository,
  }) async =>
      await _$MountyToSqlite(input, provider: provider, repository: repository);
}
