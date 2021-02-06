import 'package:brick_sqlite_abstract/annotations.dart';
import 'package:brick_sqlite_abstract/sqlite_model.dart';

final output = r"""
// GENERATED CODE DO NOT EDIT
// This file should NOT be version controlled and should not be manually edited.
part of '../brick.g.dart';

Future<AfterSaveWithAssociation> _$AfterSaveWithAssociationFromSqlite(
    Map<String, dynamic> data,
    {SqliteProvider provider,
    SqliteFirstRepository repository}) async {
  return AfterSaveWithAssociation(
      someField: (await provider?.rawQuery(
              'SELECT DISTINCT `f_Assoc_brick_id` FROM `_brick_AfterSaveWithAssociation_some_field` WHERE l_AfterSaveWithAssociation_brick_id = ?',
              [data['_brick_id'] as int])?.then((results) {
    final ids = results.map((r) => (r ?? {})['f_Assoc_brick_id']);
    return Future.wait<Assoc>(ids.map((primaryKey) => repository
        ?.getAssociation<Assoc>(
          Query.where('primaryKey', primaryKey, limit1: true),
        )
        ?.then((r) => (r?.isEmpty ?? true) ? null : r.first)));
  }))
          ?.toList()
          ?.cast<Assoc>())
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$AfterSaveWithAssociationToSqlite(
    AfterSaveWithAssociation instance,
    {SqliteProvider provider,
    SqliteFirstRepository repository}) async {
  return {};
}

/// Construct a [AfterSaveWithAssociation]
class AfterSaveWithAssociationAdapter
    extends SqliteAdapter<AfterSaveWithAssociation> {
  AfterSaveWithAssociationAdapter();

  final Map<String, RuntimeSqliteColumnDefinition> fieldsToSqliteColumns = {
    'primaryKey': RuntimeSqliteColumnDefinition(
      association: false,
      columnName: '_brick_id',
      iterable: false,
      type: int,
    ),
    'someField': RuntimeSqliteColumnDefinition(
      association: true,
      columnName: 'some_field',
      iterable: true,
      type: Assoc,
    )
  };
  Future<int> primaryKeyByUniqueColumns(
          AfterSaveWithAssociation instance, DatabaseExecutor executor) async =>
      instance?.primaryKey;
  final String tableName = 'AfterSaveWithAssociation';
  Future<void> afterSave(instance, {provider, repository}) async {
    if (instance.primaryKey != null) {
      final someFieldOldColumns = await provider?.rawQuery(
          'SELECT `f_Assoc_brick_id` FROM `_brick_AfterSaveWithAssociation_some_field` WHERE `l_AfterSaveWithAssociation_brick_id` = ?',
          [instance.primaryKey]);
      final someFieldOldIds =
          someFieldOldColumns?.map((a) => a['f_Assoc_brick_id']) ?? [];
      final someFieldNewIds = instance.someField
              ?.map((s) => s?.primaryKey)
              ?.where((s) => s != null) ??
          [];
      final someFieldIdsToDelete =
          someFieldOldIds.where((id) => !someFieldNewIds.contains(id));

      await Future.wait<void>(someFieldIdsToDelete?.map((id) async {
        return await provider?.rawExecute(
            'DELETE FROM `_brick_AfterSaveWithAssociation_some_field` WHERE `l_AfterSaveWithAssociation_brick_id` = ? AND `f_Assoc_brick_id` = ?',
            [instance.primaryKey, id])?.catchError((e) => null);
      }));

      await Future.wait<int>(instance.someField?.map((s) async {
            final id = s?.primaryKey ??
                await provider?.upsert<Assoc>(s, repository: repository);
            return await provider?.rawInsert(
                'INSERT OR IGNORE INTO `_brick_AfterSaveWithAssociation_some_field` (`l_AfterSaveWithAssociation_brick_id`, `f_Assoc_brick_id`) VALUES (?, ?)',
                [instance.primaryKey, id]);
          }) ??
          []);
    }
  }

  Future<AfterSaveWithAssociation> fromSqlite(Map<String, dynamic> input,
          {provider, repository}) async =>
      await _$AfterSaveWithAssociationFromSqlite(input,
          provider: provider, repository: repository);
  Future<Map<String, dynamic>> toSqlite(AfterSaveWithAssociation input,
          {provider, repository}) async =>
      await _$AfterSaveWithAssociationToSqlite(input,
          provider: provider, repository: repository);
}
""";

class Assoc extends SqliteModel {
  final String someField;

  Assoc(this.someField);
}

@SqliteSerializable()
class AfterSaveWithAssociation extends SqliteModel {
  List<Assoc> someField;

  AfterSaveWithAssociation(this.someField);
}
