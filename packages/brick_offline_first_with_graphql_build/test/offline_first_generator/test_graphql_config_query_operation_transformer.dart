import 'package:brick_graphql/brick_graphql.dart';
import 'package:brick_offline_first_with_graphql/brick_offline_first_with_graphql.dart';

const output = r'''
// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<QueryOperationTransformerExample>
_$QueryOperationTransformerExampleFromGraphql(
  Map<String, dynamic> data, {
  required GraphqlProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return QueryOperationTransformerExample(name: data['name'] as String);
}

Future<Map<String, dynamic>> _$QueryOperationTransformerExampleToGraphql(
  QueryOperationTransformerExample instance, {
  required GraphqlProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {'name': instance.name};
}

Future<QueryOperationTransformerExample>
_$QueryOperationTransformerExampleFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return QueryOperationTransformerExample(name: data['name'] as String)
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$QueryOperationTransformerExampleToSqlite(
  QueryOperationTransformerExample instance, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {'name': instance.name};
}

/// Construct a [QueryOperationTransformerExample]
class QueryOperationTransformerExampleAdapter
    extends OfflineFirstAdapter<QueryOperationTransformerExample> {
  QueryOperationTransformerExampleAdapter();

  @override
  final queryOperationTransformer =
      QueryOperationTransformerExampleTransformer.new;
  @override
  final fieldsToGraphqlRuntimeDefinition = <String, RuntimeGraphqlDefinition>{
    'name': const RuntimeGraphqlDefinition(
      association: false,
      documentNodeName: 'name',
      iterable: false,
      subfields: <String, Map<String, dynamic>>{},
      type: String,
    ),
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
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
    QueryOperationTransformerExample instance,
    DatabaseExecutor executor,
  ) async => instance.primaryKey;
  @override
  final String tableName = 'QueryOperationTransformerExample';

  @override
  Future<QueryOperationTransformerExample> fromGraphql(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstRepository? repository,
  }) async => await _$QueryOperationTransformerExampleFromGraphql(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toGraphql(
    QueryOperationTransformerExample input, {
    required provider,
    covariant OfflineFirstRepository? repository,
  }) async => await _$QueryOperationTransformerExampleToGraphql(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<QueryOperationTransformerExample> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstRepository? repository,
  }) async => await _$QueryOperationTransformerExampleFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    QueryOperationTransformerExample input, {
    required provider,
    covariant OfflineFirstRepository? repository,
  }) async => await _$QueryOperationTransformerExampleToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}
''';

class QueryOperationTransformerExampleTransformer extends GraphqlQueryOperationTransformer {
  @override
  GraphqlOperation get get => const GraphqlOperation(
        document: '''
          query {
            getAll()
          }
        ''',
      );

  const QueryOperationTransformerExampleTransformer(super.query, GraphqlModel? super.instance);
}

@ConnectOfflineFirstWithGraphql(
  graphqlConfig: GraphqlSerializable(
    queryOperationTransformer: QueryOperationTransformerExampleTransformer.new,
  ),
)
class QueryOperationTransformerExample extends GraphqlModel {
  final String name;
  QueryOperationTransformerExample(this.name);
}
