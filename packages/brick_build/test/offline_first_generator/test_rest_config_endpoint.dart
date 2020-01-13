import 'package:brick_offline_first_abstract/annotations.dart';
import 'package:brick_offline_first_abstract/abstract.dart';
import 'package:brick_rest/rest.dart' show RestSerializable;

final output = r'''
// GENERATED CODE DO NOT EDIT
// This file should NOT be version controlled and should not be manually edited.
part of '../brick.g.dart';

Future<RestConfigEndpoint> _$RestConfigEndpointFromRest(
    Map<String, dynamic> data,
    {RestProvider provider,
    OfflineFirstRepository repository}) async {
  return RestConfigEndpoint(someField: data['some_field'] as int);
}

Future<Map<String, dynamic>> _$RestConfigEndpointToRest(
    RestConfigEndpoint instance,
    {RestProvider provider,
    OfflineFirstRepository repository}) async {
  return {'some_field': instance.someField};
}

Future<RestConfigEndpoint> _$RestConfigEndpointFromSqlite(
    Map<String, dynamic> data,
    {SqliteProvider provider,
    OfflineFirstRepository repository}) async {
  return RestConfigEndpoint(
      someField: data['some_field'] == null ? null : data['some_field'] as int)
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$RestConfigEndpointToSqlite(
    RestConfigEndpoint instance,
    {SqliteProvider provider,
    OfflineFirstRepository repository}) async {
  return {'some_field': instance.someField};
}

/// Construct a [RestConfigEndpoint]
class RestConfigEndpointAdapter
    extends OfflineFirstAdapter<RestConfigEndpoint> {
  RestConfigEndpointAdapter();

  String restEndpoint({query, instance}) {
    return 'anEndpoint';
  }

  final String fromKey = null;
  final String toKey = null;
  final Map<String, Map<String, dynamic>> fieldsToSqliteColumns = {
    "primaryKey": {
      "name": "_brick_id",
      "type": int,
      "iterable": false,
      "association": false,
    },
    "someField": {
      "name": "some_field",
      "type": int,
      "iterable": false,
      "association": false,
    }
  };
  Future<int> primaryKeyByUniqueColumns(
          RestConfigEndpoint instance, DatabaseExecutor executor) async =>
      null;
  final String tableName = "RestConfigEndpoint";

  Future<RestConfigEndpoint> fromRest(Map<String, dynamic> input,
          {provider, repository}) async =>
      await _$RestConfigEndpointFromRest(input,
          provider: provider, repository: repository);
  Future<Map<String, dynamic>> toRest(RestConfigEndpoint input,
          {provider, repository}) async =>
      await _$RestConfigEndpointToRest(input,
          provider: provider, repository: repository);
  Future<RestConfigEndpoint> fromSqlite(Map<String, dynamic> input,
          {provider, repository}) async =>
      await _$RestConfigEndpointFromSqlite(input,
          provider: provider, repository: repository);
  Future<Map<String, dynamic>> toSqlite(RestConfigEndpoint input,
          {provider, repository}) async =>
      await _$RestConfigEndpointToSqlite(input,
          provider: provider, repository: repository);
}
''';

@ConnectOfflineFirst(
    restConfig: RestSerializable(endpoint: "{ return 'anEndpoint'; }", nullable: false))
class RestConfigEndpoint extends OfflineFirstModel {
  final int someField;

  RestConfigEndpoint(this.someField);
}
