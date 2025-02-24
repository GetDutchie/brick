import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';

@ConnectOfflineFirstWithRest()
class OfflineFirstGeneratorArguments extends OfflineFirstModel {}

const repositoryNameAdapterExpectation = r'''
// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<OfflineFirstGeneratorArguments> _$OfflineFirstGeneratorArgumentsFromTest(
  Map<String, dynamic> data, {
  required TestProvider provider,
  MyCustomRepository? repository,
}) async {
  return OfflineFirstGeneratorArguments();
}

Future<Map<String, dynamic>> _$OfflineFirstGeneratorArgumentsToTest(
  OfflineFirstGeneratorArguments instance, {
  required TestProvider provider,
  MyCustomRepository? repository,
}) async {
  return {};
}

Future<OfflineFirstGeneratorArguments>
_$OfflineFirstGeneratorArgumentsFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  MyCustomRepository? repository,
}) async {
  return OfflineFirstGeneratorArguments()
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$OfflineFirstGeneratorArgumentsToSqlite(
  OfflineFirstGeneratorArguments instance, {
  required SqliteProvider provider,
  MyCustomRepository? repository,
}) async {
  return {};
}

/// Construct a [OfflineFirstGeneratorArguments]
class OfflineFirstGeneratorArgumentsAdapter
    extends OfflineFirstAdapter<OfflineFirstGeneratorArguments> {
  OfflineFirstGeneratorArgumentsAdapter();

  @override
  final Map<String, RuntimeSqliteColumnDefinition> fieldsToSqliteColumns = {
    'primaryKey': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: '_brick_id',
      iterable: false,
      type: int,
    ),
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
    OfflineFirstGeneratorArguments instance,
    DatabaseExecutor executor,
  ) async => instance.primaryKey;
  @override
  final String tableName = 'OfflineFirstGeneratorArguments';

  @override
  Future<OfflineFirstGeneratorArguments> fromTest(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstRepository? repository,
  }) async => await _$OfflineFirstGeneratorArgumentsFromTest(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toTest(
    OfflineFirstGeneratorArguments input, {
    required provider,
    covariant OfflineFirstRepository? repository,
  }) async => await _$OfflineFirstGeneratorArgumentsToTest(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<OfflineFirstGeneratorArguments> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstRepository? repository,
  }) async => await _$OfflineFirstGeneratorArgumentsFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    OfflineFirstGeneratorArguments input, {
    required provider,
    covariant OfflineFirstRepository? repository,
  }) async => await _$OfflineFirstGeneratorArgumentsToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}
''';

const superAdapterNameAdapterExpectation = r'''
// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<OfflineFirstGeneratorArguments> _$OfflineFirstGeneratorArgumentsFromTest(
  Map<String, dynamic> data, {
  required TestProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return OfflineFirstGeneratorArguments();
}

Future<Map<String, dynamic>> _$OfflineFirstGeneratorArgumentsToTest(
  OfflineFirstGeneratorArguments instance, {
  required TestProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {};
}

Future<OfflineFirstGeneratorArguments>
_$OfflineFirstGeneratorArgumentsFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return OfflineFirstGeneratorArguments()
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$OfflineFirstGeneratorArgumentsToSqlite(
  OfflineFirstGeneratorArguments instance, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {};
}

/// Construct a [OfflineFirstGeneratorArguments]
class OfflineFirstGeneratorArgumentsAdapter
    extends SuperDuperAdapter<OfflineFirstGeneratorArguments> {
  OfflineFirstGeneratorArgumentsAdapter();

  @override
  final Map<String, RuntimeSqliteColumnDefinition> fieldsToSqliteColumns = {
    'primaryKey': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: '_brick_id',
      iterable: false,
      type: int,
    ),
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
    OfflineFirstGeneratorArguments instance,
    DatabaseExecutor executor,
  ) async => instance.primaryKey;
  @override
  final String tableName = 'OfflineFirstGeneratorArguments';

  @override
  Future<OfflineFirstGeneratorArguments> fromTest(
    Map<String, dynamic> input, {
    required provider,
    covariant SuperDuperRepository? repository,
  }) async => await _$OfflineFirstGeneratorArgumentsFromTest(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toTest(
    OfflineFirstGeneratorArguments input, {
    required provider,
    covariant SuperDuperRepository? repository,
  }) async => await _$OfflineFirstGeneratorArgumentsToTest(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<OfflineFirstGeneratorArguments> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant SuperDuperRepository? repository,
  }) async => await _$OfflineFirstGeneratorArgumentsFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    OfflineFirstGeneratorArguments input, {
    required provider,
    covariant SuperDuperRepository? repository,
  }) async => await _$OfflineFirstGeneratorArgumentsToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}
''';
