import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_supabase/brick_supabase.dart';

const output = r'''
// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<SupabaseOfflineFirstWhere> _$SupabaseOfflineFirstWhereFromSupabase(
  Map<String, dynamic> data, {
  required SupabaseProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return SupabaseOfflineFirstWhere(
    association: await repository!
        .getAssociation<Assoc>(
          Query(
            where: [Where.exact('id', data["association"]["id"])],
            limit: 1,
          ),
        )
        .then((r) => r!.first),
    associations: await Future.wait<Assoc>(
      data['associations']
              ?.map(
                (d) => AssocAdapter().fromSupabase(
                  d,
                  provider: provider,
                  repository: repository,
                ),
              )
              .toList()
              .cast<Future<Assoc>>() ??
          [],
    ),
    nullableAssociations: data['nullable_associations'] == null
        ? null
        : await Future.wait<Assoc>(
            data['nullable_associations']
                    ?.map(
                      (d) => AssocAdapter().fromSupabase(
                        d,
                        provider: provider,
                        repository: repository,
                      ),
                    )
                    .toList()
                    .cast<Future<Assoc>>() ??
                [],
          ),
  );
}

Future<Map<String, dynamic>> _$SupabaseOfflineFirstWhereToSupabase(
  SupabaseOfflineFirstWhere instance, {
  required SupabaseProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {
    'association': instance.association.id,
    'associations': await Future.wait<Map<String, dynamic>>(
      instance.associations
          .map(
            (s) => AssocAdapter().toSupabase(
              s,
              provider: provider,
              repository: repository,
            ),
          )
          .toList(),
    ),
    'nullable_associations': await Future.wait<Map<String, dynamic>>(
      instance.nullableAssociations
              ?.map(
                (s) => AssocAdapter().toSupabase(
                  s,
                  provider: provider,
                  repository: repository,
                ),
              )
              .toList() ??
          [],
    ),
  };
}

Future<SupabaseOfflineFirstWhere> _$SupabaseOfflineFirstWhereFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return SupabaseOfflineFirstWhere(
    association: (await repository!.getAssociation<Assoc>(
      Query.where(
        'primaryKey',
        data['association_Assoc_brick_id'] as int,
        limit1: true,
      ),
    ))!.first,
    associations:
        (await provider
                .rawQuery(
                  'SELECT DISTINCT `f_Assoc_brick_id` FROM `_brick_SupabaseOfflineFirstWhere_associations` WHERE l_SupabaseOfflineFirstWhere_brick_id = ?',
                  [data['_brick_id'] as int],
                )
                .then((results) {
                  final ids = results.map((r) => r['f_Assoc_brick_id']);
                  return Future.wait<Assoc>(
                    ids.map(
                      (primaryKey) => repository
                          .getAssociation<Assoc>(
                            Query.where('primaryKey', primaryKey, limit1: true),
                          )
                          .then((r) => r!.first),
                    ),
                  );
                }))
            .toList()
            .cast<Assoc>(),
    nullableAssociations:
        (await provider
                .rawQuery(
                  'SELECT DISTINCT `f_Assoc_brick_id` FROM `_brick_SupabaseOfflineFirstWhere_nullable_associations` WHERE l_SupabaseOfflineFirstWhere_brick_id = ?',
                  [data['_brick_id'] as int],
                )
                .then((results) {
                  final ids = results.map((r) => r['f_Assoc_brick_id']);
                  return Future.wait<Assoc>(
                    ids.map(
                      (primaryKey) => repository
                          .getAssociation<Assoc>(
                            Query.where('primaryKey', primaryKey, limit1: true),
                          )
                          .then((r) => r!.first),
                    ),
                  );
                }))
            .toList()
            .cast<Assoc>(),
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$SupabaseOfflineFirstWhereToSqlite(
  SupabaseOfflineFirstWhere instance, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {
    'association_Assoc_brick_id':
        instance.association.primaryKey ??
        await provider.upsert<Assoc>(
          instance.association,
          repository: repository,
        ),
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
        ),
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
    ),
    'associations': const RuntimeSupabaseColumnDefinition(
      association: true,
      columnName: 'associations',
      associationType: Assoc,
      associationIsNullable: false,
    ),
    'nullableAssociations': const RuntimeSupabaseColumnDefinition(
      association: true,
      columnName: 'nullable_associations',
      associationType: Assoc,
      associationIsNullable: true,
    ),
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
    ),
    'associations': const RuntimeSqliteColumnDefinition(
      association: true,
      columnName: 'associations',
      iterable: true,
      type: Assoc,
    ),
    'nullableAssociations': const RuntimeSqliteColumnDefinition(
      association: true,
      columnName: 'nullable_associations',
      iterable: true,
      type: Assoc,
    ),
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
    SupabaseOfflineFirstWhere instance,
    DatabaseExecutor executor,
  ) async => instance.primaryKey;
  @override
  final String tableName = 'SupabaseOfflineFirstWhere';
  @override
  Future<void> afterSave(instance, {required provider, repository}) async {
    if (instance.primaryKey != null) {
      final associationsOldColumns = await provider.rawQuery(
        'SELECT `f_Assoc_brick_id` FROM `_brick_SupabaseOfflineFirstWhere_associations` WHERE `l_SupabaseOfflineFirstWhere_brick_id` = ?',
        [instance.primaryKey],
      );
      final associationsOldIds = associationsOldColumns.map(
        (a) => a['f_Assoc_brick_id'],
      );
      final associationsNewIds = instance.associations
          .map((s) => s.primaryKey)
          .whereType<int>();
      final associationsIdsToDelete = associationsOldIds.where(
        (id) => !associationsNewIds.contains(id),
      );

      await Future.wait<void>(
        associationsIdsToDelete.map((id) async {
          return await provider
              .rawExecute(
                'DELETE FROM `_brick_SupabaseOfflineFirstWhere_associations` WHERE `l_SupabaseOfflineFirstWhere_brick_id` = ? AND `f_Assoc_brick_id` = ?',
                [instance.primaryKey, id],
              )
              .catchError((e) => null);
        }),
      );

      await Future.wait<int?>(
        instance.associations.map((s) async {
          final id =
              s.primaryKey ??
              await provider.upsert<Assoc>(s, repository: repository);
          return await provider.rawInsert(
            'INSERT OR IGNORE INTO `_brick_SupabaseOfflineFirstWhere_associations` (`l_SupabaseOfflineFirstWhere_brick_id`, `f_Assoc_brick_id`) VALUES (?, ?)',
            [instance.primaryKey, id],
          );
        }),
      );
    }

    if (instance.primaryKey != null) {
      final nullableAssociationsOldColumns = await provider.rawQuery(
        'SELECT `f_Assoc_brick_id` FROM `_brick_SupabaseOfflineFirstWhere_nullable_associations` WHERE `l_SupabaseOfflineFirstWhere_brick_id` = ?',
        [instance.primaryKey],
      );
      final nullableAssociationsOldIds = nullableAssociationsOldColumns.map(
        (a) => a['f_Assoc_brick_id'],
      );
      final nullableAssociationsNewIds =
          instance.nullableAssociations
              ?.map((s) => s.primaryKey)
              .whereType<int>() ??
          [];
      final nullableAssociationsIdsToDelete = nullableAssociationsOldIds.where(
        (id) => !nullableAssociationsNewIds.contains(id),
      );

      await Future.wait<void>(
        nullableAssociationsIdsToDelete.map((id) async {
          return await provider
              .rawExecute(
                'DELETE FROM `_brick_SupabaseOfflineFirstWhere_nullable_associations` WHERE `l_SupabaseOfflineFirstWhere_brick_id` = ? AND `f_Assoc_brick_id` = ?',
                [instance.primaryKey, id],
              )
              .catchError((e) => null);
        }),
      );

      await Future.wait<int?>(
        instance.nullableAssociations?.map((s) async {
              final id =
                  s.primaryKey ??
                  await provider.upsert<Assoc>(s, repository: repository);
              return await provider.rawInsert(
                'INSERT OR IGNORE INTO `_brick_SupabaseOfflineFirstWhere_nullable_associations` (`l_SupabaseOfflineFirstWhere_brick_id`, `f_Assoc_brick_id`) VALUES (?, ?)',
                [instance.primaryKey, id],
              );
            }) ??
            [],
      );
    }
  }

  @override
  Future<SupabaseOfflineFirstWhere> fromSupabase(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstRepository? repository,
  }) async => await _$SupabaseOfflineFirstWhereFromSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSupabase(
    SupabaseOfflineFirstWhere input, {
    required provider,
    covariant OfflineFirstRepository? repository,
  }) async => await _$SupabaseOfflineFirstWhereToSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<SupabaseOfflineFirstWhere> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstRepository? repository,
  }) async => await _$SupabaseOfflineFirstWhereFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    SupabaseOfflineFirstWhere input, {
    required provider,
    covariant OfflineFirstRepository? repository,
  }) async => await _$SupabaseOfflineFirstWhereToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}
''';

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(defaultToNull: false),
)
class SupabaseOfflineFirstWhere extends OfflineFirstModel {
  @OfflineFirst(where: {'id': 'data["association"]["id"]'})
  final Assoc association;

  final List<Assoc> associations;
  final List<Assoc>? nullableAssociations;

  SupabaseOfflineFirstWhere(this.association, this.associations, {this.nullableAssociations});
}

class Assoc extends OfflineFirstModel {
  @Supabase(unique: true)
  final String id;

  Assoc(this.id);
}
