import 'package:brick_offline_first/brick_offline_first.dart' show OfflineFirstModel;
import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:brick_sqlite/brick_sqlite.dart';

@ConnectOfflineFirstWithRest()
class OneToManyAssociation extends OfflineFirstModel {
  OneToManyAssociation({
    required this.assoc,
    this.nullableAssoc,
  });

  final List<SqliteAssoc> assoc;

  final List<SqliteAssoc>? nullableAssoc;
}

@ConnectOfflineFirstWithRest()
class SqliteAssoc extends OfflineFirstModel {
  @Rest(ignore: true)
  @Sqlite(ignore: true)
  int key = -1;
}

const output = r'''
// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<OneToManyAssociation> _$OneToManyAssociationFromTest(
  Map<String, dynamic> data, {
  required TestProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return OneToManyAssociation(
    assoc: await Future.wait<SqliteAssoc>(
      data['assoc']
              ?.map(
                (d) => SqliteAssocAdapter().fromTest(
                  d,
                  provider: provider,
                  repository: repository,
                ),
              )
              .toList()
              .cast<Future<SqliteAssoc>>() ??
          [],
    ),
    nullableAssoc: data['nullable_assoc'] == null
        ? null
        : await Future.wait<SqliteAssoc>(
            data['nullable_assoc']
                    ?.map(
                      (d) => SqliteAssocAdapter().fromTest(
                        d,
                        provider: provider,
                        repository: repository,
                      ),
                    )
                    .toList()
                    .cast<Future<SqliteAssoc>>() ??
                [],
          ),
  );
}

Future<Map<String, dynamic>> _$OneToManyAssociationToTest(
  OneToManyAssociation instance, {
  required TestProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {
    'assoc': await Future.wait<Map<String, dynamic>>(
      instance.assoc
          .map(
            (s) => SqliteAssocAdapter().toTest(
              s,
              provider: provider,
              repository: repository,
            ),
          )
          .toList(),
    ),
    'nullable_assoc': await Future.wait<Map<String, dynamic>>(
      instance.nullableAssoc
              ?.map(
                (s) => SqliteAssocAdapter().toTest(
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

Future<OneToManyAssociation> _$OneToManyAssociationFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return OneToManyAssociation(
    assoc:
        (await provider
                .rawQuery(
                  'SELECT DISTINCT `f_SqliteAssoc_brick_id` FROM `_brick_OneToManyAssociation_assoc` WHERE l_OneToManyAssociation_brick_id = ?',
                  [data['_brick_id'] as int],
                )
                .then((results) {
                  final ids = results.map((r) => r['f_SqliteAssoc_brick_id']);
                  return Future.wait<SqliteAssoc>(
                    ids.map(
                      (primaryKey) => repository!
                          .getAssociation<SqliteAssoc>(
                            Query.where('primaryKey', primaryKey, limit1: true),
                          )
                          .then((r) => r!.first),
                    ),
                  );
                }))
            .toList()
            .cast<SqliteAssoc>(),
    nullableAssoc:
        (await provider
                .rawQuery(
                  'SELECT DISTINCT `f_SqliteAssoc_brick_id` FROM `_brick_OneToManyAssociation_nullable_assoc` WHERE l_OneToManyAssociation_brick_id = ?',
                  [data['_brick_id'] as int],
                )
                .then((results) {
                  final ids = results.map((r) => r['f_SqliteAssoc_brick_id']);
                  return Future.wait<SqliteAssoc>(
                    ids.map(
                      (primaryKey) => repository!
                          .getAssociation<SqliteAssoc>(
                            Query.where('primaryKey', primaryKey, limit1: true),
                          )
                          .then((r) => r!.first),
                    ),
                  );
                }))
            .toList()
            .cast<SqliteAssoc>(),
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$OneToManyAssociationToSqlite(
  OneToManyAssociation instance, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {};
}

/// Construct a [OneToManyAssociation]
class OneToManyAssociationAdapter
    extends OfflineFirstAdapter<OneToManyAssociation> {
  OneToManyAssociationAdapter();

  @override
  final Map<String, RuntimeSqliteColumnDefinition> fieldsToSqliteColumns = {
    'primaryKey': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: '_brick_id',
      iterable: false,
      type: int,
    ),
    'assoc': const RuntimeSqliteColumnDefinition(
      association: true,
      columnName: 'assoc',
      iterable: true,
      type: SqliteAssoc,
    ),
    'nullableAssoc': const RuntimeSqliteColumnDefinition(
      association: true,
      columnName: 'nullable_assoc',
      iterable: true,
      type: SqliteAssoc,
    ),
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
    OneToManyAssociation instance,
    DatabaseExecutor executor,
  ) async => instance.primaryKey;
  @override
  final String tableName = 'OneToManyAssociation';
  @override
  Future<void> afterSave(instance, {required provider, repository}) async {
    if (instance.primaryKey != null) {
      final assocOldColumns = await provider.rawQuery(
        'SELECT `f_SqliteAssoc_brick_id` FROM `_brick_OneToManyAssociation_assoc` WHERE `l_OneToManyAssociation_brick_id` = ?',
        [instance.primaryKey],
      );
      final assocOldIds = assocOldColumns.map(
        (a) => a['f_SqliteAssoc_brick_id'],
      );
      final assocNewIds = instance.assoc
          .map((s) => s.primaryKey)
          .whereType<int>();
      final assocIdsToDelete = assocOldIds.where(
        (id) => !assocNewIds.contains(id),
      );

      await Future.wait<void>(
        assocIdsToDelete.map((id) async {
          return await provider
              .rawExecute(
                'DELETE FROM `_brick_OneToManyAssociation_assoc` WHERE `l_OneToManyAssociation_brick_id` = ? AND `f_SqliteAssoc_brick_id` = ?',
                [instance.primaryKey, id],
              )
              .catchError((e) => null);
        }),
      );

      await Future.wait<int?>(
        instance.assoc.map((s) async {
          final id =
              s.primaryKey ??
              await provider.upsert<SqliteAssoc>(s, repository: repository);
          return await provider.rawInsert(
            'INSERT OR IGNORE INTO `_brick_OneToManyAssociation_assoc` (`l_OneToManyAssociation_brick_id`, `f_SqliteAssoc_brick_id`) VALUES (?, ?)',
            [instance.primaryKey, id],
          );
        }),
      );
    }

    if (instance.primaryKey != null) {
      final nullableAssocOldColumns = await provider.rawQuery(
        'SELECT `f_SqliteAssoc_brick_id` FROM `_brick_OneToManyAssociation_nullable_assoc` WHERE `l_OneToManyAssociation_brick_id` = ?',
        [instance.primaryKey],
      );
      final nullableAssocOldIds = nullableAssocOldColumns.map(
        (a) => a['f_SqliteAssoc_brick_id'],
      );
      final nullableAssocNewIds =
          instance.nullableAssoc?.map((s) => s.primaryKey).whereType<int>() ??
          [];
      final nullableAssocIdsToDelete = nullableAssocOldIds.where(
        (id) => !nullableAssocNewIds.contains(id),
      );

      await Future.wait<void>(
        nullableAssocIdsToDelete.map((id) async {
          return await provider
              .rawExecute(
                'DELETE FROM `_brick_OneToManyAssociation_nullable_assoc` WHERE `l_OneToManyAssociation_brick_id` = ? AND `f_SqliteAssoc_brick_id` = ?',
                [instance.primaryKey, id],
              )
              .catchError((e) => null);
        }),
      );

      await Future.wait<int?>(
        instance.nullableAssoc?.map((s) async {
              final id =
                  s.primaryKey ??
                  await provider.upsert<SqliteAssoc>(s, repository: repository);
              return await provider.rawInsert(
                'INSERT OR IGNORE INTO `_brick_OneToManyAssociation_nullable_assoc` (`l_OneToManyAssociation_brick_id`, `f_SqliteAssoc_brick_id`) VALUES (?, ?)',
                [instance.primaryKey, id],
              );
            }) ??
            [],
      );
    }
  }

  @override
  Future<OneToManyAssociation> fromTest(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstRepository? repository,
  }) async => await _$OneToManyAssociationFromTest(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toTest(
    OneToManyAssociation input, {
    required provider,
    covariant OfflineFirstRepository? repository,
  }) async => await _$OneToManyAssociationToTest(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<OneToManyAssociation> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstRepository? repository,
  }) async => await _$OneToManyAssociationFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    OneToManyAssociation input, {
    required provider,
    covariant OfflineFirstRepository? repository,
  }) async => await _$OneToManyAssociationToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}
''';
