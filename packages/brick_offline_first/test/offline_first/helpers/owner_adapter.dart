part of '__mocks__.dart';

Future<Owner> _$OwnerFromTest(
  Map<String, dynamic> data, {
  required TestProvider provider,
  OfflineFirstWithTestRepository? repository,
}) async {
  return Owner(
    name: data['name'] as String?,
  );
}

Future<Map<String, dynamic>> _$OwnerToTest(
  Owner instance, {
  required TestProvider provider,
  OfflineFirstWithTestRepository? repository,
}) async {
  return {
    'name': instance.name,
  };
}

Future<Owner> _$OwnerFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstWithTestRepository? repository,
}) async {
  return Owner(
    name: data['name'] == null ? null : data['name'] as String?,
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$OwnerToSqlite(
  Owner instance, {
  required SqliteProvider provider,
  OfflineFirstWithTestRepository? repository,
}) async {
  return {'name': instance.name};
}

/// Construct a [Owner]
class OwnerAdapter extends OfflineFirstWithTestAdapter<Owner> {
  OwnerAdapter();

  @override
  final fieldsToSqliteColumns = <String, RuntimeSqliteColumnDefinition>{
    'primaryKey': const RuntimeSqliteColumnDefinition(
      columnName: '_brick_id',
      type: int,
    ),
    'name': const RuntimeSqliteColumnDefinition(
      columnName: 'name',
      type: String,
    ),
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
          Owner instance, DatabaseExecutor executor,) async =>
      instance.primaryKey;
  @override
  final tableName = 'Owner';

  @override
  Future<Owner> fromTest(
    Map<String, dynamic> input, {
    required TestProvider provider,
    covariant OfflineFirstWithTestRepository? repository,
  }) async =>
      await _$OwnerFromTest(input, provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toTest(
    Owner input, {
    required TestProvider provider,
    covariant OfflineFirstWithTestRepository? repository,
  }) async =>
      await _$OwnerToTest(input, provider: provider, repository: repository);
  @override
  Future<Owner> fromSqlite(
    Map<String, dynamic> input, {
    required SqliteProvider<SqliteModel> provider,
    covariant OfflineFirstWithTestRepository? repository,
  }) async =>
      await _$OwnerFromSqlite(input,
          provider: provider, repository: repository,);
  @override
  Future<Map<String, dynamic>> toSqlite(
    Owner input, {
    required SqliteProvider<SqliteModel> provider,
    covariant OfflineFirstWithTestRepository? repository,
  }) async =>
      await _$OwnerToSqlite(input, provider: provider, repository: repository);
}
