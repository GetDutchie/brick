import 'package:brick_offline_first_abstract/annotations.dart';
import 'package:brick_offline_first_abstract/abstract.dart';
import 'package:brick_rest/rest.dart' show Rest;

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

final output = r'''
// GENERATED CODE DO NOT EDIT
// This file should NOT be version controlled and should not be manually edited.
part of '../brick.g.dart';

Future<OneToManyAssociation> _$OneToManyAssociationFromRest(
    Map<String, dynamic> data,
    {required RestProvider provider,
    OfflineFirstRepository? repository}) async {
  return OneToManyAssociation(
      assoc: await Future.wait<SqliteAssoc>(data['assoc']
              ?.map((d) => SqliteAssocAdapter()
                  .fromRest(d, provider: provider, repository: repository))
              .toList() ??
          []),
      nullableAssoc: await Future.wait<SqliteAssoc>(data['nullable_assoc']
              ?.map((d) => SqliteAssocAdapter()
                  .fromRest(d, provider: provider, repository: repository))
              .toList() ??
          []));
}

Future<Map<String, dynamic>> _$OneToManyAssociationToRest(
    OneToManyAssociation instance,
    {required RestProvider provider,
    OfflineFirstRepository? repository}) async {
  return {
    'assoc': await Future.wait<Map<String, dynamic>>(instance.assoc
        .map((s) => SqliteAssocAdapter()
            .toRest(s, provider: provider, repository: repository))
        .toList()),
    'nullable_assoc': await Future.wait<Map<String, dynamic>>(instance
            .nullableAssoc
            ?.map((s) => SqliteAssocAdapter()
                .toRest(s, provider: provider, repository: repository))
            .toList() ??
        [])
  };
}

Future<OneToManyAssociation> _$OneToManyAssociationFromSqlite(
    Map<String, dynamic> data,
    {required SqliteProvider provider,
    OfflineFirstRepository? repository}) async {
  return OneToManyAssociation(
      assoc: (await provider.rawQuery(
              'SELECT DISTINCT `f_SqliteAssoc_brick_id` FROM `_brick_OneToManyAssociation_assoc` WHERE l_OneToManyAssociation_brick_id = ?',
              [
            data['_brick_id'] as int
          ]).then((results) {
        final ids = results.map((r) => r['f_SqliteAssoc_brick_id']);
        return Future.wait<SqliteAssoc>(ids.map((primaryKey) => repository!
            .getAssociation<SqliteAssoc>(
              Query.where('primaryKey', primaryKey, limit1: true),
            )
            .then((r) => r!.first)));
      }))
          .toList(),
      nullableAssoc: (await provider.rawQuery(
              'SELECT DISTINCT `f_SqliteAssoc_brick_id` FROM `_brick_OneToManyAssociation_nullable_assoc` WHERE l_OneToManyAssociation_brick_id = ?',
              [data['_brick_id'] as int]).then((results) {
        final ids = results.map((r) => r['f_SqliteAssoc_brick_id']);
        return Future.wait<SqliteAssoc>(ids.map((primaryKey) => repository!
            .getAssociation<SqliteAssoc>(
              Query.where('primaryKey', primaryKey, limit1: true),
            )
            .then((r) => r!.first)));
      }))
          .toList())
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$OneToManyAssociationToSqlite(
    OneToManyAssociation instance,
    {required SqliteProvider provider,
    OfflineFirstRepository? repository}) async {
  return {};
}

/// Construct a [OneToManyAssociation]
class OneToManyAssociationAdapter
    extends OfflineFirstAdapter<OneToManyAssociation> {
  OneToManyAssociationAdapter();

  @override
  String? restEndpoint({query, instance}) => '';
  @override
  final String? fromKey = null;
  @override
  final String? toKey = null;
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
    )
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
          OneToManyAssociation instance, DatabaseExecutor executor) async =>
      instance.primaryKey;
  @override
  final String tableName = 'OneToManyAssociation';
  @override
  Future<void> afterSave(instance, {required provider, repository}) async {
    if (instance.primaryKey != null) {
      await Future.wait<int?>(instance.assoc.map((s) async {
        final id = s.primaryKey ??
            await provider.upsert<SqliteAssoc>(s, repository: repository);
        return await provider.rawInsert(
            'INSERT OR IGNORE INTO `_brick_OneToManyAssociation_assoc` (`l_OneToManyAssociation_brick_id`, `f_SqliteAssoc_brick_id`) VALUES (?, ?)',
            [instance.primaryKey, id]);
      }));
    }

    if (instance.primaryKey != null) {
      await Future.wait<int?>(instance.nullableAssoc?.map((s) async {
            final id = s.primaryKey ??
                await provider.upsert<SqliteAssoc>(s, repository: repository);
            return await provider.rawInsert(
                'INSERT OR IGNORE INTO `_brick_OneToManyAssociation_nullable_assoc` (`l_OneToManyAssociation_brick_id`, `f_SqliteAssoc_brick_id`) VALUES (?, ?)',
                [instance.primaryKey, id]);
          }) ??
          []);
    }
  }

  @override
  Future<OneToManyAssociation> fromRest(Map<String, dynamic> input,
          {required provider,
          covariant OfflineFirstRepository? repository}) async =>
      await _$OneToManyAssociationFromRest(input,
          provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toRest(OneToManyAssociation input,
          {required provider,
          covariant OfflineFirstRepository? repository}) async =>
      await _$OneToManyAssociationToRest(input,
          provider: provider, repository: repository);
  @override
  Future<OneToManyAssociation> fromSqlite(Map<String, dynamic> input,
          {required provider,
          covariant OfflineFirstRepository? repository}) async =>
      await _$OneToManyAssociationFromSqlite(input,
          provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toSqlite(OneToManyAssociation input,
          {required provider,
          covariant OfflineFirstRepository? repository}) async =>
      await _$OneToManyAssociationToSqlite(input,
          provider: provider, repository: repository);
}
''';
