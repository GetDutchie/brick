import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_supabase/brick_supabase.dart';

final output = r'''
// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<SupabaseOfflineFirstWhere> _$SupabaseOfflineFirstWhereFromSupabase(
    Map<String, dynamic> data,
    {required SupabaseProvider provider,
    OfflineFirstRepository? repository}) async {
  return SupabaseOfflineFirstWhere(
      association: await repository!
          .getAssociation<Assoc>(Query(
              where: [Where.exact('id', data["association"]["id"])],
              providerArgs: {'limit': 1}))
          .then((r) => r!.first));
}

Future<Map<String, dynamic>> _$SupabaseOfflineFirstWhereToSupabase(
    SupabaseOfflineFirstWhere instance,
    {required SupabaseProvider provider,
    OfflineFirstRepository? repository}) async {
  return {'association': instance.association.id};
}

Future<SupabaseOfflineFirstWhere> _$SupabaseOfflineFirstWhereFromSqlite(
    Map<String, dynamic> data,
    {required SqliteProvider provider,
    OfflineFirstRepository? repository}) async {
  return SupabaseOfflineFirstWhere(
      association: (await repository!.getAssociation<Assoc>(
    Query.where('primaryKey', data['association_Assoc_brick_id'] as int,
        limit1: true),
  ))!
          .first)
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$SupabaseOfflineFirstWhereToSqlite(
    SupabaseOfflineFirstWhere instance,
    {required SqliteProvider provider,
    OfflineFirstRepository? repository}) async {
  return {
    'association_Assoc_brick_id': instance.association.primaryKey ??
        await provider.upsert<Assoc>(instance.association,
            repository: repository)
  };
}

/// Construct a [SupabaseOfflineFirstWhere]
class SupabaseOfflineFirstWhereAdapter
    extends OfflineFirstAdapter<SupabaseOfflineFirstWhere> {
  SupabaseOfflineFirstWhereAdapter();

  @override
  final supabaseTableName = 'supabase_offline_first_wheres';
  @override
  final fieldsToOfflineFirstRuntimeDefinition =
      <String, RuntimeOfflineFirstDefinition>{
    'association': const RuntimeOfflineFirstDefinition(
      where: <String, String>{'id': 'data["association"]["id"]'},
    )
  };
  @override
  final defaultToNull = false;
  @override
  final fieldsToSupabaseColumns = {
    'association': const RuntimeSupabaseColumnDefinition(
      association: true,
      columnName: 'association',
      associationType: Assoc,
      associationIsNullable: false,
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
    'association': const RuntimeSqliteColumnDefinition(
      association: true,
      columnName: 'association_Assoc_brick_id',
      iterable: false,
      type: Assoc,
    )
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(SupabaseOfflineFirstWhere instance,
          DatabaseExecutor executor) async =>
      instance.primaryKey;
  @override
  final String tableName = 'SupabaseOfflineFirstWhere';

  @override
  Future<SupabaseOfflineFirstWhere> fromSupabase(Map<String, dynamic> input,
          {required provider,
          covariant OfflineFirstRepository? repository}) async =>
      await _$SupabaseOfflineFirstWhereFromSupabase(input,
          provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toSupabase(SupabaseOfflineFirstWhere input,
          {required provider,
          covariant OfflineFirstRepository? repository}) async =>
      await _$SupabaseOfflineFirstWhereToSupabase(input,
          provider: provider, repository: repository);
  @override
  Future<SupabaseOfflineFirstWhere> fromSqlite(Map<String, dynamic> input,
          {required provider,
          covariant OfflineFirstRepository? repository}) async =>
      await _$SupabaseOfflineFirstWhereFromSqlite(input,
          provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toSqlite(SupabaseOfflineFirstWhere input,
          {required provider,
          covariant OfflineFirstRepository? repository}) async =>
      await _$SupabaseOfflineFirstWhereToSqlite(input,
          provider: provider, repository: repository);
}
''';

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(defaultToNull: false),
)
class SupabaseOfflineFirstWhere extends OfflineFirstModel {
  @OfflineFirst(where: {'id': 'data["association"]["id"]'})
  final Assoc association;

  SupabaseOfflineFirstWhere(this.association);
}

class Assoc extends OfflineFirstModel {
  @Supabase(unique: true)
  final String id;

  Assoc(this.id);
}
