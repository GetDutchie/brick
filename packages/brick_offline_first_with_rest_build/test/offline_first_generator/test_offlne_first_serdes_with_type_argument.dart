import 'package:brick_offline_first_abstract/abstract.dart';
import 'package:brick_offline_first_abstract/annotations.dart';

final output = r"""
// GENERATED CODE DO NOT EDIT
// This file should NOT be version controlled and should not be manually edited.
part of '../brick.g.dart';

Future<OfflineFirstSerdesWithTypeArgument>
    _$OfflineFirstSerdesWithTypeArgumentFromRest(Map<String, dynamic> data,
        {RestProvider provider, OfflineFirstRepository repository}) async {
  return OfflineFirstSerdesWithTypeArgument();
}

Future<Map<String, dynamic>> _$OfflineFirstSerdesWithTypeArgumentToRest(
    OfflineFirstSerdesWithTypeArgument instance,
    {RestProvider provider,
    OfflineFirstRepository repository}) async {
  return {};
}

Future<OfflineFirstSerdesWithTypeArgument>
    _$OfflineFirstSerdesWithTypeArgumentFromSqlite(Map<String, dynamic> data,
        {SqliteProvider provider, OfflineFirstRepository repository}) async {
  return OfflineFirstSerdesWithTypeArgument()
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$OfflineFirstSerdesWithTypeArgumentToSqlite(
    OfflineFirstSerdesWithTypeArgument instance,
    {SqliteProvider provider,
    OfflineFirstRepository repository}) async {
  return {};
}

/// Construct a [OfflineFirstSerdesWithTypeArgument]
class OfflineFirstSerdesWithTypeArgumentAdapter
    extends OfflineFirstAdapter<OfflineFirstSerdesWithTypeArgument> {
  OfflineFirstSerdesWithTypeArgumentAdapter();

  String restEndpoint({query, instance}) => '';
  final String fromKey = null;
  final String toKey = null;
  final Map<String, RuntimeSqliteColumnDefinition> fieldsToSqliteColumns = {
    'primaryKey': RuntimeSqliteColumnDefinition(
      association: false,
      columnName: '_brick_id',
      iterable: false,
      type: int,
    ),
    'someField': RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'some_field',
      iterable: false,
      type: SerdesWithTypeArgument,
    )
  };
  Future<int> primaryKeyByUniqueColumns(
          OfflineFirstSerdesWithTypeArgument instance,
          DatabaseExecutor executor) async =>
      instance?.primaryKey;
  final String tableName = 'OfflineFirstSerdesWithTypeArgument';

  Future<OfflineFirstSerdesWithTypeArgument> fromRest(
          Map<String, dynamic> input,
          {provider,
          repository}) async =>
      await _$OfflineFirstSerdesWithTypeArgumentFromRest(input,
          provider: provider, repository: repository);
  Future<Map<String, dynamic>> toRest(OfflineFirstSerdesWithTypeArgument input,
          {provider, repository}) async =>
      await _$OfflineFirstSerdesWithTypeArgumentToRest(input,
          provider: provider, repository: repository);
  Future<OfflineFirstSerdesWithTypeArgument> fromSqlite(
          Map<String, dynamic> input,
          {provider,
          repository}) async =>
      await _$OfflineFirstSerdesWithTypeArgumentFromSqlite(input,
          provider: provider, repository: repository);
  Future<Map<String, dynamic>> toSqlite(
          OfflineFirstSerdesWithTypeArgument input,
          {provider,
          repository}) async =>
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
