import 'package:brick_sqlite_abstract/annotations.dart';
import 'package:brick_sqlite_abstract/sqlite_model.dart';

final output = r"""
// ignore_for_file: unnecessary_non_null_assertion
// ignore_for_file: invalid_null_aware_operator

// GENERATED CODE DO NOT EDIT
// This file should NOT be version controlled and should not be manually edited.
part of '../brick.g.dart';

Future<AfterSaveWithAssociation> _$AfterSaveWithAssociationFromSqlite(
    Map<String, dynamic> data,
    {required SqliteProvider provider,
    SqliteFirstRepository? repository}) async {
  return AfterSaveWithAssociation(
      someField: (await provider.rawQuery(
              'SELECT DISTINCT `f_Assoc_brick_id` FROM `_brick_AfterSaveWithAssociation_some_field` WHERE l_AfterSaveWithAssociation_brick_id = ?',
              [data['_brick_id'] as int]).then((results) {
    final ids = results.map((r) => r['f_Assoc_brick_id']);
    return Future.wait<Assoc>(ids.map((primaryKey) => repository!
        .getAssociation<Assoc>(
          Query.where('primaryKey', primaryKey, limit1: true),
        )
        .then((r) => r!.first)));
  }))
          .toList())
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$AfterSaveWithAssociationToSqlite(
    AfterSaveWithAssociation instance,
    {required SqliteProvider provider,
    SqliteFirstRepository? repository}) async {
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
    )
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
          AfterSaveWithAssociation instance, DatabaseExecutor executor) async =>
      instance.primaryKey;
  @override
  final String tableName = 'AfterSaveWithAssociation';
  @override
  Future<void> afterSave(instance, {required provider, repository}) async {
    if (instance.primaryKey != null) {
      await Future.wait<int?>(instance.someField.map((s) async {
        final id = s.primaryKey ??
            await provider.upsert<Assoc>(s, repository: repository);
        return await provider.rawInsert(
            'INSERT OR IGNORE INTO `_brick_AfterSaveWithAssociation_some_field` (`l_AfterSaveWithAssociation_brick_id`, `f_Assoc_brick_id`) VALUES (?, ?)',
            [instance.primaryKey, id]);
      }));
    }
  }

  @override
  Future<AfterSaveWithAssociation> fromSqlite(Map<String, dynamic> input,
          {required provider, covariant SqliteRepository? repository}) async =>
      await _$AfterSaveWithAssociationFromSqlite(input,
          provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toSqlite(AfterSaveWithAssociation input,
          {required provider, covariant SqliteRepository? repository}) async =>
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
  final List<Assoc> someField;

  AfterSaveWithAssociation(this.someField);
}
