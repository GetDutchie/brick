import 'package:brick_sqlite/brick_sqlite.dart';

const output = r"""
// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<AfterSaveWithAssociation> _$AfterSaveWithAssociationFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  SqliteFirstRepository? repository,
}) async {
  return AfterSaveWithAssociation(
    someField:
        (await provider
                .rawQuery(
                  'SELECT DISTINCT `f_Assoc_brick_id` FROM `_brick_AfterSaveWithAssociation_some_field` WHERE l_AfterSaveWithAssociation_brick_id = ?',
                  [data['_brick_id'] as int],
                )
                .then((results) {
                  final ids = results.map((r) => r['f_Assoc_brick_id']);
                  return Future.wait<Assoc>(
                    ids.map(
                      (primaryKey) => repository!
                          .getAssociation<Assoc>(
                            Query.where('primaryKey', primaryKey, limit1: true),
                          )
                          .then((r) => r!.first),
                    ),
                  );
                }))
            .toList()
            .cast<Assoc>(),
    assocNullable:
        (await provider
                .rawQuery(
                  'SELECT DISTINCT `f_Assoc_brick_id` FROM `_brick_AfterSaveWithAssociation_assoc_nullable` WHERE l_AfterSaveWithAssociation_brick_id = ?',
                  [data['_brick_id'] as int],
                )
                .then((results) {
                  final ids = results.map((r) => r['f_Assoc_brick_id']);
                  return Future.wait<Assoc>(
                    ids.map(
                      (primaryKey) => repository!
                          .getAssociation<Assoc>(
                            Query.where('primaryKey', primaryKey, limit1: true),
                          )
                          .then((r) => r!.first),
                    ),
                  );
                }))
            .toList()
            .cast<Assoc>(),
    assocNullableArg:
        (await provider
                .rawQuery(
                  'SELECT DISTINCT `f_Assoc_brick_id` FROM `_brick_AfterSaveWithAssociation_assoc_nullable_arg` WHERE l_AfterSaveWithAssociation_brick_id = ?',
                  [data['_brick_id'] as int],
                )
                .then((results) {
                  final ids = results.map((r) => r['f_Assoc_brick_id']);
                  return Future.wait<Assoc?>(
                    ids.map(
                      (primaryKey) => repository
                          ?.getAssociation<Assoc>(
                            Query.where('primaryKey', primaryKey, limit1: true),
                          )
                          .then(
                            (r) => r?.isNotEmpty ?? false ? r!.first : null,
                          ),
                    ),
                  );
                }))
            ?.toList()
            .cast<Assoc?>(),
    assocNullableAndNullableArg:
        (await provider
                .rawQuery(
                  'SELECT DISTINCT `f_Assoc_brick_id` FROM `_brick_AfterSaveWithAssociation_assoc_nullable_and_nullable_arg` WHERE l_AfterSaveWithAssociation_brick_id = ?',
                  [data['_brick_id'] as int],
                )
                .then((results) {
                  final ids = results.map((r) => r['f_Assoc_brick_id']);
                  return Future.wait<Assoc?>(
                    ids.map(
                      (primaryKey) => repository
                          ?.getAssociation<Assoc>(
                            Query.where('primaryKey', primaryKey, limit1: true),
                          )
                          .then(
                            (r) => r?.isNotEmpty ?? false ? r!.first : null,
                          ),
                    ),
                  );
                }))
            ?.toList()
            .cast<Assoc?>(),
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$AfterSaveWithAssociationToSqlite(
  AfterSaveWithAssociation instance, {
  required SqliteProvider provider,
  SqliteFirstRepository? repository,
}) async {
  return {};
}

/// Construct a [AfterSaveWithAssociation]
class AfterSaveWithAssociationAdapter
    extends SqliteAdapter<AfterSaveWithAssociation> {
  AfterSaveWithAssociationAdapter();

  @override
  final Map<String, RuntimeSqliteColumnDefinition> fieldsToSqliteColumns = {
    'primaryKey': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: '_brick_id',
      iterable: false,
      type: int,
    ),
    'someField': const RuntimeSqliteColumnDefinition(
      association: true,
      columnName: 'some_field',
      iterable: true,
      type: Assoc,
    ),
    'assocNullable': const RuntimeSqliteColumnDefinition(
      association: true,
      columnName: 'assoc_nullable',
      iterable: true,
      type: Assoc,
    ),
    'assocNullableArg': const RuntimeSqliteColumnDefinition(
      association: true,
      columnName: 'assoc_nullable_arg',
      iterable: true,
      type: Assoc,
    ),
    'assocNullableAndNullableArg': const RuntimeSqliteColumnDefinition(
      association: true,
      columnName: 'assoc_nullable_and_nullable_arg',
      iterable: true,
      type: Assoc,
    ),
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
    AfterSaveWithAssociation instance,
    DatabaseExecutor executor,
  ) async => instance.primaryKey;
  @override
  final String tableName = 'AfterSaveWithAssociation';
  @override
  Future<void> afterSave(instance, {required provider, repository}) async {
    if (instance.primaryKey != null) {
      final someFieldOldColumns = await provider.rawQuery(
        'SELECT `f_Assoc_brick_id` FROM `_brick_AfterSaveWithAssociation_some_field` WHERE `l_AfterSaveWithAssociation_brick_id` = ?',
        [instance.primaryKey],
      );
      final someFieldOldIds = someFieldOldColumns.map(
        (a) => a['f_Assoc_brick_id'],
      );
      final someFieldNewIds = instance.someField
          .map((s) => s.primaryKey)
          .whereType<int>();
      final someFieldIdsToDelete = someFieldOldIds.where(
        (id) => !someFieldNewIds.contains(id),
      );

      await Future.wait<void>(
        someFieldIdsToDelete.map((id) async {
          return await provider
              .rawExecute(
                'DELETE FROM `_brick_AfterSaveWithAssociation_some_field` WHERE `l_AfterSaveWithAssociation_brick_id` = ? AND `f_Assoc_brick_id` = ?',
                [instance.primaryKey, id],
              )
              .catchError((e) => null);
        }),
      );

      await Future.wait<int?>(
        instance.someField.map((s) async {
          final id =
              s.primaryKey ??
              await provider.upsert<Assoc>(s, repository: repository);
          return await provider.rawInsert(
            'INSERT OR IGNORE INTO `_brick_AfterSaveWithAssociation_some_field` (`l_AfterSaveWithAssociation_brick_id`, `f_Assoc_brick_id`) VALUES (?, ?)',
            [instance.primaryKey, id],
          );
        }),
      );
    }

    if (instance.primaryKey != null) {
      final assocNullableOldColumns = await provider.rawQuery(
        'SELECT `f_Assoc_brick_id` FROM `_brick_AfterSaveWithAssociation_assoc_nullable` WHERE `l_AfterSaveWithAssociation_brick_id` = ?',
        [instance.primaryKey],
      );
      final assocNullableOldIds = assocNullableOldColumns.map(
        (a) => a['f_Assoc_brick_id'],
      );
      final assocNullableNewIds =
          instance.assocNullable?.map((s) => s.primaryKey).whereType<int>() ??
          [];
      final assocNullableIdsToDelete = assocNullableOldIds.where(
        (id) => !assocNullableNewIds.contains(id),
      );

      await Future.wait<void>(
        assocNullableIdsToDelete.map((id) async {
          return await provider
              .rawExecute(
                'DELETE FROM `_brick_AfterSaveWithAssociation_assoc_nullable` WHERE `l_AfterSaveWithAssociation_brick_id` = ? AND `f_Assoc_brick_id` = ?',
                [instance.primaryKey, id],
              )
              .catchError((e) => null);
        }),
      );

      await Future.wait<int?>(
        instance.assocNullable?.map((s) async {
              final id =
                  s.primaryKey ??
                  await provider.upsert<Assoc>(s, repository: repository);
              return await provider.rawInsert(
                'INSERT OR IGNORE INTO `_brick_AfterSaveWithAssociation_assoc_nullable` (`l_AfterSaveWithAssociation_brick_id`, `f_Assoc_brick_id`) VALUES (?, ?)',
                [instance.primaryKey, id],
              );
            }) ??
            [],
      );
    }

    if (instance.primaryKey != null) {
      final assocNullableArgOldColumns = await provider.rawQuery(
        'SELECT `f_Assoc_brick_id` FROM `_brick_AfterSaveWithAssociation_assoc_nullable_arg` WHERE `l_AfterSaveWithAssociation_brick_id` = ?',
        [instance.primaryKey],
      );
      final assocNullableArgOldIds = assocNullableArgOldColumns.map(
        (a) => a['f_Assoc_brick_id'],
      );
      final assocNullableArgNewIds = instance.assocNullableArg
          .map((s) => s?.primaryKey)
          .whereType<int>();
      final assocNullableArgIdsToDelete = assocNullableArgOldIds.where(
        (id) => !assocNullableArgNewIds.contains(id),
      );

      await Future.wait<void>(
        assocNullableArgIdsToDelete.map((id) async {
          return await provider
              .rawExecute(
                'DELETE FROM `_brick_AfterSaveWithAssociation_assoc_nullable_arg` WHERE `l_AfterSaveWithAssociation_brick_id` = ? AND `f_Assoc_brick_id` = ?',
                [instance.primaryKey, id],
              )
              .catchError((e) => null);
        }),
      );

      await Future.wait<int?>(
        instance.assocNullableArg.map((s) async {
          final id =
              s.primaryKey ??
              await provider.upsert<Assoc>(s, repository: repository);
          return await provider.rawInsert(
            'INSERT OR IGNORE INTO `_brick_AfterSaveWithAssociation_assoc_nullable_arg` (`l_AfterSaveWithAssociation_brick_id`, `f_Assoc_brick_id`) VALUES (?, ?)',
            [instance.primaryKey, id],
          );
        }),
      );
    }

    if (instance.primaryKey != null) {
      final assocNullableAndNullableArgOldColumns = await provider.rawQuery(
        'SELECT `f_Assoc_brick_id` FROM `_brick_AfterSaveWithAssociation_assoc_nullable_and_nullable_arg` WHERE `l_AfterSaveWithAssociation_brick_id` = ?',
        [instance.primaryKey],
      );
      final assocNullableAndNullableArgOldIds =
          assocNullableAndNullableArgOldColumns.map(
            (a) => a['f_Assoc_brick_id'],
          );
      final assocNullableAndNullableArgNewIds =
          instance.assocNullableAndNullableArg
              ?.map((s) => s?.primaryKey)
              .whereType<int>() ??
          [];
      final assocNullableAndNullableArgIdsToDelete =
          assocNullableAndNullableArgOldIds.where(
            (id) => !assocNullableAndNullableArgNewIds.contains(id),
          );

      await Future.wait<void>(
        assocNullableAndNullableArgIdsToDelete.map((id) async {
          return await provider
              .rawExecute(
                'DELETE FROM `_brick_AfterSaveWithAssociation_assoc_nullable_and_nullable_arg` WHERE `l_AfterSaveWithAssociation_brick_id` = ? AND `f_Assoc_brick_id` = ?',
                [instance.primaryKey, id],
              )
              .catchError((e) => null);
        }),
      );

      await Future.wait<int?>(
        instance.assocNullableAndNullableArg?.map((s) async {
              final id =
                  s.primaryKey ??
                  await provider.upsert<Assoc>(s, repository: repository);
              return await provider.rawInsert(
                'INSERT OR IGNORE INTO `_brick_AfterSaveWithAssociation_assoc_nullable_and_nullable_arg` (`l_AfterSaveWithAssociation_brick_id`, `f_Assoc_brick_id`) VALUES (?, ?)',
                [instance.primaryKey, id],
              );
            }) ??
            [],
      );
    }
  }

  @override
  Future<AfterSaveWithAssociation> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant SqliteRepository? repository,
  }) async => await _$AfterSaveWithAssociationFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    AfterSaveWithAssociation input, {
    required provider,
    covariant SqliteRepository? repository,
  }) async => await _$AfterSaveWithAssociationToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}
""";

class Assoc extends SqliteModel {
  final String someField;

  Assoc(this.someField);
}

@SqliteSerializable()
class AfterSaveWithAssociation extends SqliteModel {
  final List<Assoc> someField;

  List<Assoc>? assocNullable;
  List<Assoc?> assocNullableArg;
  List<Assoc?>? assocNullableAndNullableArg;

  AfterSaveWithAssociation({
    required this.someField,
    this.assocNullable,
    required this.assocNullableArg,
    this.assocNullableAndNullableArg,
  });
}
