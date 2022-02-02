import 'package:brick_offline_first_with_rest_abstract/annotations.dart';
import 'package:brick_offline_first_abstract/abstract.dart';
import 'package:brick_rest/rest.dart' show RestSerializable;

final output = r'''
// GENERATED CODE DO NOT EDIT
// This file should NOT be version controlled and should not be manually edited.
part of '../brick.g.dart';

Future<RestConfigEndpoint> _$RestConfigEndpointFromRest(
    Map<String, dynamic> data,
    {required RestProvider provider,
    OfflineFirstRepository? repository}) async {
  return RestConfigEndpoint(someField: data['some_field'] as int);
}

Future<Map<String, dynamic>> _$RestConfigEndpointToRest(
    RestConfigEndpoint instance,
    {required RestProvider provider,
    OfflineFirstRepository? repository}) async {
  return {'some_field': instance.someField};
}

Future<RestConfigEndpoint> _$RestConfigEndpointFromSqlite(
    Map<String, dynamic> data,
    {required SqliteProvider provider,
    OfflineFirstRepository? repository}) async {
  return RestConfigEndpoint(someField: data['some_field'] as int)
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$RestConfigEndpointToSqlite(
    RestConfigEndpoint instance,
    {required SqliteProvider provider,
    OfflineFirstRepository? repository}) async {
  return {'some_field': instance.someField};
}

/// Construct a [RestConfigEndpoint]
class RestConfigEndpointAdapter
    extends OfflineFirstAdapter<RestConfigEndpoint> {
  RestConfigEndpointAdapter();

  @override
  String? restEndpoint({query, instance}) {
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
          RestConfigEndpoint instance, DatabaseExecutor executor) async =>
      instance.primaryKey;
  @override
  final String tableName = 'RestConfigEndpoint';

  @override
  Future<RestConfigEndpoint> fromRest(Map<String, dynamic> input,
          {required provider,
          covariant OfflineFirstRepository? repository}) async =>
      await _$RestConfigEndpointFromRest(input,
          provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toRest(RestConfigEndpoint input,
          {required provider,
          covariant OfflineFirstRepository? repository}) async =>
      await _$RestConfigEndpointToRest(input,
          provider: provider, repository: repository);
  @override
  Future<RestConfigEndpoint> fromSqlite(Map<String, dynamic> input,
          {required provider,
          covariant OfflineFirstRepository? repository}) async =>
      await _$RestConfigEndpointFromSqlite(input,
          provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toSqlite(RestConfigEndpoint input,
          {required provider,
          covariant OfflineFirstRepository? repository}) async =>
      await _$RestConfigEndpointToSqlite(input,
          provider: provider, repository: repository);
}
''';

@ConnectOfflineFirstWithRest(
  restConfig: RestSerializable(
    endpoint: "{ return 'anEndpoint'; }",
    nullable: false,
  ),
)
class RestConfigEndpoint extends OfflineFirstModel {
  final int someField;

  RestConfigEndpoint(this.someField);
}
