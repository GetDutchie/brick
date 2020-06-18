import 'package:brick_offline_first_abstract/annotations.dart';
import 'package:brick_offline_first_abstract/abstract.dart';
import 'package:brick_rest/rest.dart' show Rest;

@ConnectOfflineFirstWithRest()
class OneToManyAssociation extends OfflineFirstModel {
  OneToManyAssociation({this.assoc});

  final List<SqliteAssoc> assoc;
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
    {RestProvider provider,
    OfflineFirstRepository repository}) async {
  return OneToManyAssociation(
      assoc: await Future.wait<SqliteAssoc>(data['assoc']
              ?.map((d) => SqliteAssocAdapter()
                  .fromRest(d, provider: provider, repository: repository))
              ?.toList()
              ?.cast<Future<SqliteAssoc>>() ??
          []));
}

Future<Map<String, dynamic>> _$OneToManyAssociationToRest(
    OneToManyAssociation instance,
    {RestProvider provider,
    OfflineFirstRepository repository}) async {
  return {
    'assoc': await Future.wait<Map<String, dynamic>>(
        instance.assoc?.map((s) => SqliteAssocAdapter().toRest(s))?.toList() ??
            [])
  };
}

Future<OneToManyAssociation> _$OneToManyAssociationFromSqlite(
    Map<String, dynamic> data,
    {SqliteProvider provider,
    OfflineFirstRepository repository}) async {
  return OneToManyAssociation(
      assoc: (await provider?.rawQuery(
              'SELECT DISTINCT `f_SqliteAssoc_brick_id` FROM `_brick_OneToManyAssociation_assoc` WHERE l_OneToManyAssociation_brick_id = ?',
              [data['_brick_id'] as int])?.then((results) {
    final ids = results.map((r) => (r ?? {})['f_SqliteAssoc_brick_id']);
    return Future.wait<SqliteAssoc>(ids.map((primaryKey) => repository
        ?.getAssociation<SqliteAssoc>(
          Query.where('primaryKey', primaryKey, limit1: true),
        )
        ?.then((r) => (r?.isEmpty ?? true) ? null : r.first)));
  }))
          ?.toList()
          ?.cast<SqliteAssoc>())
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$OneToManyAssociationToSqlite(
    OneToManyAssociation instance,
    {SqliteProvider provider,
    OfflineFirstRepository repository}) async {
  return {};
}

/// Construct a [OneToManyAssociation]
class OneToManyAssociationAdapter
    extends OfflineFirstAdapter<OneToManyAssociation> {
  OneToManyAssociationAdapter();

  String restEndpoint({query, instance}) => '';
  final String fromKey = null;
  final String toKey = null;
  final Map<String, Map<String, dynamic>> fieldsToSqliteColumns = {
    'primaryKey': {
      'name': '_brick_id',
      'type': int,
      'iterable': false,
      'association': false,
    },
    'assoc': {
      'name': 'assoc',
      'type': SqliteAssoc,
      'iterable': true,
      'association': true,
    }
  };
  Future<int> primaryKeyByUniqueColumns(
          OneToManyAssociation instance, DatabaseExecutor executor) async =>
      null;
  final String tableName = 'OneToManyAssociation';
  Future<void> afterSave(instance, {provider, repository}) async {
    if (instance.primaryKey != null) {
      await Future.wait<int>(instance.assoc?.map((s) async {
        final id = s?.primaryKey ??
            await provider?.upsert<SqliteAssoc>(s, repository: repository);
        return await provider?.rawInsert(
            'INSERT OR REPLACE INTO `_brick_OneToManyAssociation_assoc` (`l_OneToManyAssociation_brick_id`, `f_SqliteAssoc_brick_id`) VALUES (?, ?)',
            [instance.primaryKey, id]);
      }));
    }
  }

  Future<OneToManyAssociation> fromRest(Map<String, dynamic> input,
          {provider, repository}) async =>
      await _$OneToManyAssociationFromRest(input,
          provider: provider, repository: repository);
  Future<Map<String, dynamic>> toRest(OneToManyAssociation input,
          {provider, repository}) async =>
      await _$OneToManyAssociationToRest(input,
          provider: provider, repository: repository);
  Future<OneToManyAssociation> fromSqlite(Map<String, dynamic> input,
          {provider, repository}) async =>
      await _$OneToManyAssociationFromSqlite(input,
          provider: provider, repository: repository);
  Future<Map<String, dynamic>> toSqlite(OneToManyAssociation input,
          {provider, repository}) async =>
      await _$OneToManyAssociationToSqlite(input,
          provider: provider, repository: repository);
}
''';
