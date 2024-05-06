part of '__mocks__.dart';

Future<Mounty> _$MountyFromTest(
  Map<String, dynamic> data, {
  required TestProvider provider,
  OfflineFirstWithTestRepository? repository,
}) async {
  return Mounty(name: data['name'] as String?);
}

Future<Map<String, dynamic>> _$MountyToTest(
  Mounty instance, {
  required TestProvider provider,
  OfflineFirstWithTestRepository? repository,
}) async {
  return {'name': instance.name};
}

Future<Mounty> _$MountyFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstWithTestRepository? repository,
}) async {
  return Mounty(name: data['name'] == null ? null : data['name'] as String?)
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$MountyToSqlite(
  Mounty instance, {
  required SqliteProvider provider,
  OfflineFirstWithTestRepository? repository,
}) async {
  return {'name': instance.name};
}

/// Construct a [Mounty]
class MountyAdapter extends OfflineFirstWithTestAdapter<Mounty> {
  MountyAdapter();

  @override
  final Map<String, RuntimeSqliteColumnDefinition> fieldsToSqliteColumns = {
    'primaryKey': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: '_brick_id',
      iterable: false,
      type: int,
    ),
    'name': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'name',
      iterable: false,
      type: String,
    ),
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(Mounty instance, DatabaseExecutor executor) async =>
      instance.primaryKey;
  @override
  final String tableName = 'Mounty';

  @override
  Future<Mounty> fromTest(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithTestRepository? repository,
  }) async =>
      await _$MountyFromTest(input, provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toTest(
    Mounty input, {
    required provider,
    covariant OfflineFirstWithTestRepository? repository,
  }) async =>
      await _$MountyToTest(input, provider: provider, repository: repository);
  @override
  Future<Mounty> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithTestRepository? repository,
  }) async =>
      await _$MountyFromSqlite(input, provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toSqlite(
    Mounty input, {
    required provider,
    covariant OfflineFirstWithTestRepository? repository,
  }) async =>
      await _$MountyToSqlite(input, provider: provider, repository: repository);
}
