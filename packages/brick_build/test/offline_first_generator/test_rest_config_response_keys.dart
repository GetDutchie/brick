import 'package:brick_offline_first_abstract/annotations.dart';
import 'package:brick_offline_first_abstract/abstract.dart';

final output = r'''
// GENERATED CODE DO NOT EDIT
// This file should NOT be version controlled and should not be manually edited.
part of '../brick.g.dart';

Future<RestConfigResponseKeys> _$RestConfigResponseKeysFromRest(
    Map<String, dynamic> data,
    {RestProvider provider,
    OfflineFirstRepository repository}) async {
  return RestConfigResponseKeys(someField: data['some_field'] as int);
}

Future<Map<String, dynamic>> _$RestConfigResponseKeysToRest(
    RestConfigResponseKeys instance,
    {RestProvider provider,
    OfflineFirstRepository repository}) async {
  return {'some_field': instance.someField};
}

Future<RestConfigResponseKeys> _$RestConfigResponseKeysFromSqlite(
    Map<String, dynamic> data,
    {SqliteProvider provider,
    OfflineFirstRepository repository}) async {
  return RestConfigResponseKeys(
      someField: data['some_field'] == null ? null : data['some_field'] as int)
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$RestConfigResponseKeysToSqlite(
    RestConfigResponseKeys instance,
    {SqliteProvider provider,
    OfflineFirstRepository repository}) async {
  return {'some_field': instance.someField};
}

/// Construct a [RestConfigResponseKeys]
class RestConfigResponseKeysAdapter
    extends OfflineFirstAdapter<RestConfigResponseKeys> {
  RestConfigResponseKeysAdapter();

  String restEndpoint({query, instance}) => "";
  final String fromKey = "users";
  final String toKey = "user";
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
          RestConfigResponseKeys instance, DatabaseExecutor executor) async =>
      null;
  final String tableName = "RestConfigResponseKeys";

  Future<RestConfigResponseKeys> fromRest(Map<String, dynamic> input,
          {provider, repository}) async =>
      await _$RestConfigResponseKeysFromRest(input,
          provider: provider, repository: repository);
  Future<Map<String, dynamic>> toRest(RestConfigResponseKeys input,
          {provider, repository}) async =>
      await _$RestConfigResponseKeysToRest(input,
          provider: provider, repository: repository);
  Future<RestConfigResponseKeys> fromSqlite(Map<String, dynamic> input,
          {provider, repository}) async =>
      await _$RestConfigResponseKeysFromSqlite(input,
          provider: provider, repository: repository);
  Future<Map<String, dynamic>> toSqlite(RestConfigResponseKeys input,
          {provider, repository}) async =>
      await _$RestConfigResponseKeysToSqlite(input,
          provider: provider, repository: repository);
}
''';

@ConnectOfflineFirst(restConfig: RestSerializable(fromKey: 'users', toKey: 'user'))
class RestConfigResponseKeys extends OfflineFirstModel {
  final int someField;

  RestConfigResponseKeys(this.someField);
}
