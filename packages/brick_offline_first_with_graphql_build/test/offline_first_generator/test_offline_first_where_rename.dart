import 'package:brick_graphql/brick_graphql.dart' show Graphql, GraphqlSerializable;
import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:brick_offline_first_with_graphql/brick_offline_first_with_graphql.dart';

const output = r'''
// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<GraphqlConfigEndpoint> _$GraphqlConfigEndpointFromGraphql(
  Map<String, dynamic> data, {
  required GraphqlProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return GraphqlConfigEndpoint(
    someField: await repository!
        .getAssociation<Assoc>(
          Query(where: [Where.exact('name', data['name'])], limit: 1),
        )
        .then((r) => r!.first),
  );
}

Future<Map<String, dynamic>> _$GraphqlConfigEndpointToGraphql(
  GraphqlConfigEndpoint instance, {
  required GraphqlProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {'name': instance.someField.name};
}

Future<GraphqlConfigEndpoint> _$GraphqlConfigEndpointFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return GraphqlConfigEndpoint(
    someField: (await repository!.getAssociation<Assoc>(
      Query.where(
        'primaryKey',
        data['some_field_Assoc_brick_id'] as int,
        limit1: true,
      ),
    ))!.first,
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$GraphqlConfigEndpointToSqlite(
  GraphqlConfigEndpoint instance, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {
    'some_field_Assoc_brick_id':
        instance.someField.primaryKey ??
        await provider.upsert<Assoc>(
          instance.someField,
          repository: repository,
        ),
  };
}

/// Construct a [GraphqlConfigEndpoint]
class GraphqlConfigEndpointAdapter
    extends OfflineFirstAdapter<GraphqlConfigEndpoint> {
  GraphqlConfigEndpointAdapter();

  @override
  final fieldsToOfflineFirstRuntimeDefinition =
      <String, RuntimeOfflineFirstDefinition>{
        'someField': const RuntimeOfflineFirstDefinition(
          where: <String, String>{'name': "data['name']"},
        ),
      };
  @override
  final fieldsToGraphqlRuntimeDefinition = <String, RuntimeGraphqlDefinition>{
    'someField': const RuntimeGraphqlDefinition(
      association: false,
      documentNodeName: 'name',
      iterable: false,
      subfields: <String, Map<String, dynamic>>{},
      type: Object,
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
    'someField': const RuntimeSqliteColumnDefinition(
      association: true,
      columnName: 'some_field_Assoc_brick_id',
      iterable: false,
      type: Assoc,
    ),
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
    GraphqlConfigEndpoint instance,
    DatabaseExecutor executor,
  ) async => instance.primaryKey;
  @override
  final String tableName = 'GraphqlConfigEndpoint';

  @override
  Future<GraphqlConfigEndpoint> fromGraphql(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstRepository? repository,
  }) async => await _$GraphqlConfigEndpointFromGraphql(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toGraphql(
    GraphqlConfigEndpoint input, {
    required provider,
    covariant OfflineFirstRepository? repository,
  }) async => await _$GraphqlConfigEndpointToGraphql(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<GraphqlConfigEndpoint> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstRepository? repository,
  }) async => await _$GraphqlConfigEndpointFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    GraphqlConfigEndpoint input, {
    required provider,
    covariant OfflineFirstRepository? repository,
  }) async => await _$GraphqlConfigEndpointToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}
''';

@ConnectOfflineFirstWithGraphql(
  graphqlConfig: GraphqlSerializable.defaults,
)
class GraphqlConfigEndpoint extends OfflineFirstModel {
  @OfflineFirst(where: {'name': "data['name']"})
  @Graphql(name: 'name')
  final Assoc someField;

  GraphqlConfigEndpoint(this.someField);
}

@ConnectOfflineFirstWithGraphql()
class Assoc extends OfflineFirstModel {
  final String? name;
  Assoc({this.name});
}
