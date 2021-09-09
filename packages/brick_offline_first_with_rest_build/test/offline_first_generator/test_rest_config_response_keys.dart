import 'package:brick_offline_first_abstract/annotations.dart';
import 'package:brick_offline_first_abstract/abstract.dart';
import 'package:brick_rest/rest.dart' show RestSerializable;

final output = r'''
// ignore_for_file: unnecessary_non_null_assertion
// ignore_for_file: invalid_null_aware_operator

// GENERATED CODE DO NOT EDIT
// This file should NOT be version controlled and should not be manually edited.
part of '../brick.g.dart';

Future<RestConfigResponseKeys> _$RestConfigResponseKeysFromRest(
    Map<String, dynamic> data,
    {required RestProvider provider,
    OfflineFirstRepository? repository}) async {
  return RestConfigResponseKeys(someField: data['some_field'] as int);
}

Future<Map<String, dynamic>> _$RestConfigResponseKeysToRest(
    RestConfigResponseKeys instance,
    {required RestProvider provider,
    OfflineFirstRepository? repository}) async {
  return {'some_field': instance.someField};
}

Future<RestConfigResponseKeys> _$RestConfigResponseKeysFromSqlite(
    Map<String, dynamic> data,
    {required SqliteProvider provider,
    OfflineFirstRepository? repository}) async {
  return RestConfigResponseKeys(someField: data['some_field'] as int)
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$RestConfigResponseKeysToSqlite(
    RestConfigResponseKeys instance,
    {required SqliteProvider provider,
    OfflineFirstRepository? repository}) async {
  return {'some_field': instance.someField};
}

/// Construct a [RestConfigResponseKeys]
class RestConfigResponseKeysAdapter
    extends OfflineFirstAdapter<RestConfigResponseKeys> {
  RestConfigResponseKeysAdapter();

  @override
  String? restEndpoint({query, instance}) => '';
  @override
  final String? fromKey = 'users';
  @override
  final String? toKey = 'user';
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
          RestConfigResponseKeys instance, DatabaseExecutor executor) async =>
      instance.primaryKey;
  @override
  final String tableName = 'RestConfigResponseKeys';

  @override
  Future<RestConfigResponseKeys> fromRest(Map<String, dynamic> input,
          {required provider,
          covariant OfflineFirstRepository? repository}) async =>
      await _$RestConfigResponseKeysFromRest(input,
          provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toRest(RestConfigResponseKeys input,
          {required provider,
          covariant OfflineFirstRepository? repository}) async =>
      await _$RestConfigResponseKeysToRest(input,
          provider: provider, repository: repository);
  @override
  Future<RestConfigResponseKeys> fromSqlite(Map<String, dynamic> input,
          {required provider,
          covariant OfflineFirstRepository? repository}) async =>
      await _$RestConfigResponseKeysFromSqlite(input,
          provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toSqlite(RestConfigResponseKeys input,
          {required provider,
          covariant OfflineFirstRepository? repository}) async =>
      await _$RestConfigResponseKeysToSqlite(input,
          provider: provider, repository: repository);
}
''';

@ConnectOfflineFirstWithRest(restConfig: RestSerializable(fromKey: 'users', toKey: 'user'))
class RestConfigResponseKeys extends OfflineFirstModel {
  final int someField;

  RestConfigResponseKeys(this.someField);
}
