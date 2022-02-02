import 'package:brick_offline_first_abstract/abstract.dart';
import 'package:brick_graphql/graphql.dart' show GraphqlSerializable;
import 'package:brick_offline_first_with_graphql_abstract/annotations.dart';

final output = r'''
// GENERATED CODE DO NOT EDIT
// This file should NOT be version controlled and should not be manually edited.
part of '../brick.g.dart';

Future<GraphqlConfigEndpoint> _$GraphqlConfigEndpointFromGraphql(
    Map<String, dynamic> data,
    {required GraphqlProvider provider,
    OfflineFirstRepository? repository}) async {
  return GraphqlConfigEndpoint(someField: data['some_field'] as int);
}

Future<Map<String, dynamic>> _$GraphqlConfigEndpointToGraphql(
    GraphqlConfigEndpoint instance,
    {required GraphqlProvider provider,
    OfflineFirstRepository? repository}) async {
  return {'some_field': instance.someField};
}

Future<GraphqlConfigEndpoint> _$GraphqlConfigEndpointFromSqlite(
    Map<String, dynamic> data,
    {required SqliteProvider provider,
    OfflineFirstRepository? repository}) async {
  return GraphqlConfigEndpoint(someField: data['some_field'] as int)
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$GraphqlConfigEndpointToSqlite(
    GraphqlConfigEndpoint instance,
    {required SqliteProvider provider,
    OfflineFirstRepository? repository}) async {
  return {'some_field': instance.someField};
}

/// Construct a [GraphqlConfigEndpoint]
class GraphqlConfigEndpointAdapter
    extends OfflineFirstAdapter<GraphqlConfigEndpoint> {
  GraphqlConfigEndpointAdapter();

  @override
  String? graphqlEndpoint({query, instance}) {
    return 'anEndpoint';
  }

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
    'someField': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'some_field',
      iterable: false,
      type: int,
    )
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
          GraphqlConfigEndpoint instance, DatabaseExecutor executor) async =>
      instance.primaryKey;
  @override
  final String tableName = 'GraphqlConfigEndpoint';

  @override
  Future<GraphqlConfigEndpoint> fromGraphql(Map<String, dynamic> input,
          {required provider,
          covariant OfflineFirstRepository? repository}) async =>
      await _$GraphqlConfigEndpointFromGraphql(input,
          provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toGraphql(GraphqlConfigEndpoint input,
          {required provider,
          covariant OfflineFirstRepository? repository}) async =>
      await _$GraphqlConfigEndpointToGraphql(input,
          provider: provider, repository: repository);
  @override
  Future<GraphqlConfigEndpoint> fromSqlite(Map<String, dynamic> input,
          {required provider,
          covariant OfflineFirstRepository? repository}) async =>
      await _$GraphqlConfigEndpointFromSqlite(input,
          provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toSqlite(GraphqlConfigEndpoint input,
          {required provider,
          covariant OfflineFirstRepository? repository}) async =>
      await _$GraphqlConfigEndpointToSqlite(input,
          provider: provider, repository: repository);
}
''';

@ConnectOfflineFirstWithGraphql(
  graphqlConfig: GraphqlSerializable(
    defaultDeleteOperation: null, // TODO
  ),
)
class GraphqlConfigEndpoint extends OfflineFirstModel {
  final int someField;

  GraphqlConfigEndpoint(this.someField);
}
