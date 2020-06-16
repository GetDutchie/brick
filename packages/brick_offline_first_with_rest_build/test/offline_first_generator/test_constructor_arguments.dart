import 'package:brick_offline_first_abstract/abstract.dart';
import 'package:brick_offline_first_abstract/annotations.dart';

@ConnectOfflineFirstWithRest()
class OfflineFirstGeneratorArguments extends OfflineFirstModel {}

final repositoryNameAdapterExpectation = r'''
// GENERATED CODE DO NOT EDIT
// This file should NOT be version controlled and should not be manually edited.
part of '../brick.g.dart';

Future<OfflineFirstGeneratorArguments> _$OfflineFirstGeneratorArgumentsFromRest(
    Map<String, dynamic> data,
    {RestProvider provider,
    MyCustomRepository repository}) async {
  return OfflineFirstGeneratorArguments();
}

Future<Map<String, dynamic>> _$OfflineFirstGeneratorArgumentsToRest(
    OfflineFirstGeneratorArguments instance,
    {RestProvider provider,
    MyCustomRepository repository}) async {
  return {};
}

Future<OfflineFirstGeneratorArguments>
    _$OfflineFirstGeneratorArgumentsFromSqlite(Map<String, dynamic> data,
        {SqliteProvider provider, MyCustomRepository repository}) async {
  return OfflineFirstGeneratorArguments()
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$OfflineFirstGeneratorArgumentsToSqlite(
    OfflineFirstGeneratorArguments instance,
    {SqliteProvider provider,
    MyCustomRepository repository}) async {
  return {};
}

/// Construct a [OfflineFirstGeneratorArguments]
class OfflineFirstGeneratorArgumentsAdapter
    extends OfflineFirstAdapter<OfflineFirstGeneratorArguments> {
  OfflineFirstGeneratorArgumentsAdapter();

  String restEndpoint({query, instance}) => '';
  final String fromKey = null;
  final String toKey = null;
  final Map<String, Map<String, dynamic>> fieldsToSqliteColumns = {
    'primaryKey': {
      'name': '_brick_id',
      'type': int,
      'iterable': false,
      'association': false,
    }
  };
  Future<int> primaryKeyByUniqueColumns(OfflineFirstGeneratorArguments instance,
          DatabaseExecutor executor) async =>
      null;
  final String tableName = 'OfflineFirstGeneratorArguments';
  Future<void> afterSave(instance, {provider, repository}) async {}

  Future<OfflineFirstGeneratorArguments> fromRest(Map<String, dynamic> input,
          {provider, repository}) async =>
      await _$OfflineFirstGeneratorArgumentsFromRest(input,
          provider: provider, repository: repository);
  Future<Map<String, dynamic>> toRest(OfflineFirstGeneratorArguments input,
          {provider, repository}) async =>
      await _$OfflineFirstGeneratorArgumentsToRest(input,
          provider: provider, repository: repository);
  Future<OfflineFirstGeneratorArguments> fromSqlite(Map<String, dynamic> input,
          {provider, repository}) async =>
      await _$OfflineFirstGeneratorArgumentsFromSqlite(input,
          provider: provider, repository: repository);
  Future<Map<String, dynamic>> toSqlite(OfflineFirstGeneratorArguments input,
          {provider, repository}) async =>
      await _$OfflineFirstGeneratorArgumentsToSqlite(input,
          provider: provider, repository: repository);
}
''';

final superAdapterNameAdapterExpectation = r'''
// GENERATED CODE DO NOT EDIT
// This file should NOT be version controlled and should not be manually edited.
part of '../brick.g.dart';

Future<OfflineFirstGeneratorArguments> _$OfflineFirstGeneratorArgumentsFromRest(
    Map<String, dynamic> data,
    {RestProvider provider,
    OfflineFirstRepository repository}) async {
  return OfflineFirstGeneratorArguments();
}

Future<Map<String, dynamic>> _$OfflineFirstGeneratorArgumentsToRest(
    OfflineFirstGeneratorArguments instance,
    {RestProvider provider,
    OfflineFirstRepository repository}) async {
  return {};
}

Future<OfflineFirstGeneratorArguments>
    _$OfflineFirstGeneratorArgumentsFromSqlite(Map<String, dynamic> data,
        {SqliteProvider provider, OfflineFirstRepository repository}) async {
  return OfflineFirstGeneratorArguments()
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$OfflineFirstGeneratorArgumentsToSqlite(
    OfflineFirstGeneratorArguments instance,
    {SqliteProvider provider,
    OfflineFirstRepository repository}) async {
  return {};
}

/// Construct a [OfflineFirstGeneratorArguments]
class OfflineFirstGeneratorArgumentsAdapter
    extends SuperDuperAdapter<OfflineFirstGeneratorArguments> {
  OfflineFirstGeneratorArgumentsAdapter();

  String restEndpoint({query, instance}) => '';
  final String fromKey = null;
  final String toKey = null;
  final Map<String, Map<String, dynamic>> fieldsToSqliteColumns = {
    'primaryKey': {
      'name': '_brick_id',
      'type': int,
      'iterable': false,
      'association': false,
    }
  };
  Future<int> primaryKeyByUniqueColumns(OfflineFirstGeneratorArguments instance,
          DatabaseExecutor executor) async =>
      null;
  final String tableName = 'OfflineFirstGeneratorArguments';
  Future<void> afterSave(instance, {provider, repository}) async {}

  Future<OfflineFirstGeneratorArguments> fromRest(Map<String, dynamic> input,
          {provider, repository}) async =>
      await _$OfflineFirstGeneratorArgumentsFromRest(input,
          provider: provider, repository: repository);
  Future<Map<String, dynamic>> toRest(OfflineFirstGeneratorArguments input,
          {provider, repository}) async =>
      await _$OfflineFirstGeneratorArgumentsToRest(input,
          provider: provider, repository: repository);
  Future<OfflineFirstGeneratorArguments> fromSqlite(Map<String, dynamic> input,
          {provider, repository}) async =>
      await _$OfflineFirstGeneratorArgumentsFromSqlite(input,
          provider: provider, repository: repository);
  Future<Map<String, dynamic>> toSqlite(OfflineFirstGeneratorArguments input,
          {provider, repository}) async =>
      await _$OfflineFirstGeneratorArgumentsToSqlite(input,
          provider: provider, repository: repository);
}
''';
