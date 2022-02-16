import 'package:brick_offline_first_with_rest_abstract/abstract.dart';
import 'package:brick_offline_first_with_rest_abstract/annotations.dart';

final output = r"""
// GENERATED CODE DO NOT EDIT
// This file should NOT be version controlled and should not be manually edited.
part of '../brick.g.dart';

Future<OfflineFirstSerdesWithTypeArgument>
    _$OfflineFirstSerdesWithTypeArgumentFromTest(Map<String, dynamic> data,
        {required TestProvider provider,
        OfflineFirstRepository? repository}) async {
  return OfflineFirstSerdesWithTypeArgument();
}

Future<Map<String, dynamic>> _$OfflineFirstSerdesWithTypeArgumentToTest(
    OfflineFirstSerdesWithTypeArgument instance,
    {required TestProvider provider,
    OfflineFirstRepository? repository}) async {
  return {};
}

Future<OfflineFirstSerdesWithTypeArgument>
    _$OfflineFirstSerdesWithTypeArgumentFromSqlite(Map<String, dynamic> data,
        {required SqliteProvider provider,
        OfflineFirstRepository? repository}) async {
  return OfflineFirstSerdesWithTypeArgument()
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$OfflineFirstSerdesWithTypeArgumentToSqlite(
    OfflineFirstSerdesWithTypeArgument instance,
    {required SqliteProvider provider,
    OfflineFirstRepository? repository}) async {
  return {};
}

/// Construct a [OfflineFirstSerdesWithTypeArgument]
class OfflineFirstSerdesWithTypeArgumentAdapter
    extends OfflineFirstAdapter<OfflineFirstSerdesWithTypeArgument> {
  OfflineFirstSerdesWithTypeArgumentAdapter();

  @override
  String? restEndpoint({query, instance}) => '';
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
      type: SerdesWithTypeArgument,
    )
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
          OfflineFirstSerdesWithTypeArgument instance,
          DatabaseExecutor executor) async =>
      instance.primaryKey;
  @override
  final String tableName = 'OfflineFirstSerdesWithTypeArgument';

  @override
  Future<OfflineFirstSerdesWithTypeArgument> fromTest(
          Map<String, dynamic> input,
          {required provider,
          covariant OfflineFirstRepository? repository}) async =>
      await _$OfflineFirstSerdesWithTypeArgumentFromTest(input,
          provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toTest(OfflineFirstSerdesWithTypeArgument input,
          {required provider,
          covariant OfflineFirstRepository? repository}) async =>
      await _$OfflineFirstSerdesWithTypeArgumentToTest(input,
          provider: provider, repository: repository);
  @override
  Future<OfflineFirstSerdesWithTypeArgument> fromSqlite(
          Map<String, dynamic> input,
          {required provider,
          covariant OfflineFirstRepository? repository}) async =>
      await _$OfflineFirstSerdesWithTypeArgumentFromSqlite(input,
          provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toSqlite(
          OfflineFirstSerdesWithTypeArgument input,
          {required provider,
          covariant OfflineFirstRepository? repository}) async =>
      await _$OfflineFirstSerdesWithTypeArgumentToSqlite(input,
          provider: provider, repository: repository);
}
""";

class SerdesWithTypeArgument<T> extends OfflineFirstSerdes {}

@ConnectOfflineFirstWithRest()
class OfflineFirstSerdesWithTypeArgument extends OfflineFirstWithRestModel {
  final SerdesWithTypeArgument<int> someField;

  OfflineFirstSerdesWithTypeArgument(this.someField);
}
