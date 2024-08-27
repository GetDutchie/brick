// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<Mounty> _$MountyFromSupabase(Map<String, dynamic> data,
    {required SupabaseProvider provider, OfflineFirstWithSupabaseRepository? repository}) async {
  return Mounty(
      name: data['name'] as String?,
      email: data['email'] as String?,
      hat: data['hat'] == null
          ? null
          : await HatAdapter()
              .fromSupabase(data['hat'], provider: provider, repository: repository));
}

Future<Map<String, dynamic>> _$MountyToSupabase(Mounty instance,
    {required SupabaseProvider provider, OfflineFirstWithSupabaseRepository? repository}) async {
  return {
    'name': instance.name,
    'email': instance.email,
    'hat': instance.hat != null
        ? await HatAdapter().toSupabase(instance.hat!, provider: provider, repository: repository)
        : null
  };
}

Future<Mounty> _$MountyFromSqlite(Map<String, dynamic> data,
    {required SqliteProvider provider, OfflineFirstWithSupabaseRepository? repository}) async {
  return Mounty(
      name: data['name'] == null ? null : data['name'] as String?,
      email: data['email'] == null ? null : data['email'] as String?,
      hat: data['hat_Hat_brick_id'] == null
          ? null
          : (data['hat_Hat_brick_id'] > -1
              ? (await repository?.getAssociation<Hat>(
                  Query.where('primaryKey', data['hat_Hat_brick_id'] as int, limit1: true),
                ))
                  ?.first
              : null))
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$MountyToSqlite(Mounty instance,
    {required SqliteProvider provider, OfflineFirstWithSupabaseRepository? repository}) async {
  return {
    'name': instance.name,
    'email': instance.email,
    'hat_Hat_brick_id': instance.hat != null
        ? instance.hat!.primaryKey ??
            await provider.upsert<Hat>(instance.hat!, repository: repository)
        : null
  };
}

/// Construct a [Mounty]
class MountyAdapter extends OfflineFirstWithSupabaseAdapter<Mounty> {
  MountyAdapter();

  @override
  final defaultToNull = true;
  @override
  final fieldsToSupabaseColumns = {
    'name': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'name',
    ),
    'email': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'email',
    ),
    'hat': const RuntimeSupabaseColumnDefinition(
      association: true,
      associationType: Hat,
      columnName: 'hat',
    )
  };
  @override
  final ignoreDuplicates = false;
  @override
  final uniqueFields = {};
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
    'email': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'email',
      iterable: false,
      type: String,
    ),
    'hat': const RuntimeSqliteColumnDefinition(
      association: true,
      columnName: 'hat_Hat_brick_id',
      iterable: false,
      type: Hat,
    )
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(Mounty instance, DatabaseExecutor executor) async =>
      instance.primaryKey;
  @override
  final String tableName = 'Mounty';

  @override
  Future<Mounty> fromSupabase(Map<String, dynamic> input,
          {required provider, covariant OfflineFirstWithSupabaseRepository? repository}) async =>
      await _$MountyFromSupabase(input, provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toSupabase(Mounty input,
          {required provider, covariant OfflineFirstWithSupabaseRepository? repository}) async =>
      await _$MountyToSupabase(input, provider: provider, repository: repository);
  @override
  Future<Mounty> fromSqlite(Map<String, dynamic> input,
          {required provider, covariant OfflineFirstWithSupabaseRepository? repository}) async =>
      await _$MountyFromSqlite(input, provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toSqlite(Mounty input,
          {required provider, covariant OfflineFirstWithSupabaseRepository? repository}) async =>
      await _$MountyToSqlite(input, provider: provider, repository: repository);
}
