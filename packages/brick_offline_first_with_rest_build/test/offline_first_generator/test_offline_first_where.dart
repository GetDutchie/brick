import 'package:brick_offline_first_abstract/annotations.dart';
import 'package:brick_offline_first_abstract/abstract.dart';
import 'package:brick_rest/rest.dart' show Rest;

final output = r'''
// GENERATED CODE DO NOT EDIT
// This file should NOT be version controlled and should not be manually edited.
part of '../brick.g.dart';

Future<OfflineFirstWhere> _$OfflineFirstWhereFromRest(Map<String, dynamic> data,
    {RestProvider provider, OfflineFirstRepository repository}) async {
  return OfflineFirstWhere(
      assoc: repository
          ?.getAssociation<OtherAssoc>(Query(
              where: [Where.exact('id', data['id'])],
              providerArgs: {'limit': 1}))
          ?.then((a) => a?.isNotEmpty == true ? a.first : null),
      assocs: (data['assocs'] ?? [])
          .map((s) => repository
              ?.getAssociation<Assoc>(Query(
                  where: [Where.exact('id', s), Where.exact('otherVar', s)]))
              ?.then((a) => a?.isNotEmpty == true ? a.first : null))
          ?.toList()
          ?.cast<Future<Assoc>>(),
      loadedAssoc: await repository
          ?.getAssociation<Assoc>(Query(where: [Where.exact('id', data['id'])], providerArgs: {'limit': 1}))
          ?.then((a) => a?.isNotEmpty == true ? a.first : null),
      loadedAssocs: await Future.wait<Assoc>((data['loaded_assocs'] ?? []).map((s) => repository?.getAssociation<Assoc>(Query(where: [Where.exact('id', s)]))?.then((a) => a?.isNotEmpty == true ? a.first : null))?.toList()?.cast<Future<Assoc>>() ?? []),
      multiLookupCustomGenerator: (data['multi_lookup_custom_generator'] ?? []).map((s) => repository?.getAssociation<Assoc>(Query(where: [Where.exact('id', s), Where.exact('otherVar', s)]))?.then((a) => a?.isNotEmpty == true ? a.first : null))?.toList()?.cast<Future<Assoc>>());
}

Future<Map<String, dynamic>> _$OfflineFirstWhereToRest(
    OfflineFirstWhere instance,
    {RestProvider provider,
    OfflineFirstRepository repository}) async {
  return {
    'assoc': (await instance.assoc)?.id,
    'loaded_assoc': "Going to REST",
    'loaded_assocs': instance.loadedAssocs?.map((s) => s.id)?.toList(),
    'multi_lookup_custom_generator': "As REST"
  };
}

Future<OfflineFirstWhere> _$OfflineFirstWhereFromSqlite(
    Map<String, dynamic> data,
    {SqliteProvider provider,
    OfflineFirstRepository repository}) async {
  return OfflineFirstWhere(
      assoc: data['assoc_OtherAssoc_brick_id'] == null
          ? null
          : (data['assoc_OtherAssoc_brick_id'] > -1
              ? repository
                  ?.getAssociation<OtherAssoc>(
                    Query.where(
                        'primaryKey', data['assoc_OtherAssoc_brick_id'] as int,
                        limit1: true),
                  )
                  ?.then((r) => (r?.isEmpty ?? true) ? null : r.first)
              : null),
      assocs: await provider?.rawQuery(
          'SELECT DISTINCT `f_Assoc_brick_id` FROM `_brick_OfflineFirstWhere_assocs` WHERE l_OfflineFirstWhere_brick_id = ?',
          [
            data['_brick_id'] as int
          ])?.then((results) {
        final ids = results.map((r) => (r ?? {})['f_Assoc_brick_id']);
        return Future.wait<Assoc>(ids.map((primaryKey) => repository
            ?.getAssociation<Assoc>(
              Query.where('primaryKey', primaryKey, limit1: true),
            )
            ?.then((r) => (r?.isEmpty ?? true) ? null : r.first)));
      }),
      loadedAssoc: data['loaded_assoc_Assoc_brick_id'] == null
          ? null
          : (data['loaded_assoc_Assoc_brick_id'] > -1
              ? (await repository?.getAssociation<Assoc>(
                  Query.where(
                      'primaryKey', data['loaded_assoc_Assoc_brick_id'] as int,
                      limit1: true),
                ))
                  ?.first
              : null),
      loadedAssocs: (await provider?.rawQuery(
              'SELECT DISTINCT `f_Assoc_brick_id` FROM `_brick_OfflineFirstWhere_loaded_assocs` WHERE l_OfflineFirstWhere_brick_id = ?',
              [
            data['_brick_id'] as int
          ])?.then((results) {
        final ids = results.map((r) => (r ?? {})['f_Assoc_brick_id']);
        return Future.wait<Assoc>(ids.map((primaryKey) => repository
            ?.getAssociation<Assoc>(
              Query.where('primaryKey', primaryKey, limit1: true),
            )
            ?.then((r) => (r?.isEmpty ?? true) ? null : r.first)));
      }))
          ?.toList()
          ?.cast<Assoc>(),
      multiLookupCustomGenerator: await provider?.rawQuery(
          'SELECT DISTINCT `f_Assoc_brick_id` FROM `_brick_OfflineFirstWhere_multi_lookup_custom_generator` WHERE l_OfflineFirstWhere_brick_id = ?',
          [data['_brick_id'] as int])?.then((results) {
        final ids = results.map((r) => (r ?? {})['f_Assoc_brick_id']);
        return Future.wait<Assoc>(ids.map((primaryKey) => repository
            ?.getAssociation<Assoc>(
              Query.where('primaryKey', primaryKey, limit1: true),
            )
            ?.then((r) => (r?.isEmpty ?? true) ? null : r.first)));
      }))
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$OfflineFirstWhereToSqlite(
    OfflineFirstWhere instance,
    {SqliteProvider provider,
    OfflineFirstRepository repository}) async {
  return {
    'assoc_OtherAssoc_brick_id': (await instance.assoc)?.primaryKey ??
        await provider?.upsert<OtherAssoc>((await instance.assoc),
            repository: repository),
    'loaded_assoc_Assoc_brick_id': instance.loadedAssoc?.primaryKey ??
        await provider?.upsert<Assoc>(instance.loadedAssoc,
            repository: repository)
  };
}

/// Construct a [OfflineFirstWhere]
class OfflineFirstWhereAdapter extends OfflineFirstAdapter<OfflineFirstWhere> {
  OfflineFirstWhereAdapter();

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
      'type': OtherAssoc,
      'iterable': false,
      'association': false,
    },
    'assocs': {
      'name': 'assocs',
      'type': Assoc,
      'iterable': true,
      'association': true,
    },
    'loadedAssoc': {
      'name': 'loaded_assoc_Assoc_brick_id',
      'type': Assoc,
      'iterable': false,
      'association': true,
    },
    'loadedAssocs': {
      'name': 'loaded_assocs',
      'type': Assoc,
      'iterable': true,
      'association': true,
    },
    'multiLookupCustomGenerator': {
      'name': 'multi_lookup_custom_generator',
      'type': Assoc,
      'iterable': true,
      'association': true,
    }
  };
  Future<int> primaryKeyByUniqueColumns(
          OfflineFirstWhere instance, DatabaseExecutor executor) async =>
      null;
  final String tableName = 'OfflineFirstWhere';
  Future<void> afterSave(instance, {provider, repository}) async {
    if (instance.primaryKey != null) {
      await Future.wait<int>(instance.assocs?.map((s) async {
        final id = (await s)?.primaryKey ??
            await provider?.upsert<Assoc>((await s), repository: repository);
        return await provider?.rawInsert(
            'INSERT OR IGNORE INTO `_brick_OfflineFirstWhere_assocs` (`l_OfflineFirstWhere_brick_id`, `f_Assoc_brick_id`) VALUES (?, ?)',
            [instance.primaryKey, id]);
      }) ?? []);
    }

    if (instance.primaryKey != null) {
      await Future.wait<int>(instance.loadedAssocs?.map((s) async {
        final id = s?.primaryKey ??
            await provider?.upsert<Assoc>(s, repository: repository);
        return await provider?.rawInsert(
            'INSERT OR IGNORE INTO `_brick_OfflineFirstWhere_loaded_assocs` (`l_OfflineFirstWhere_brick_id`, `f_Assoc_brick_id`) VALUES (?, ?)',
            [instance.primaryKey, id]);
      }) ?? []);
    }

    if (instance.primaryKey != null) {
      await Future.wait<int>(
          instance.multiLookupCustomGenerator?.map((s) async {
        final id = (await s)?.primaryKey ??
            await provider?.upsert<Assoc>((await s), repository: repository);
        return await provider?.rawInsert(
            'INSERT OR IGNORE INTO `_brick_OfflineFirstWhere_multi_lookup_custom_generator` (`l_OfflineFirstWhere_brick_id`, `f_Assoc_brick_id`) VALUES (?, ?)',
            [instance.primaryKey, id]);
      }) ?? []);
    }
  }

  Future<OfflineFirstWhere> fromRest(Map<String, dynamic> input,
          {provider, repository}) async =>
      await _$OfflineFirstWhereFromRest(input,
          provider: provider, repository: repository);
  Future<Map<String, dynamic>> toRest(OfflineFirstWhere input,
          {provider, repository}) async =>
      await _$OfflineFirstWhereToRest(input,
          provider: provider, repository: repository);
  Future<OfflineFirstWhere> fromSqlite(Map<String, dynamic> input,
          {provider, repository}) async =>
      await _$OfflineFirstWhereFromSqlite(input,
          provider: provider, repository: repository);
  Future<Map<String, dynamic>> toSqlite(OfflineFirstWhere input,
          {provider, repository}) async =>
      await _$OfflineFirstWhereToSqlite(input,
          provider: provider, repository: repository);
}
''';

@ConnectOfflineFirstWithRest()
class OfflineFirstWhere extends OfflineFirstModel {
  OfflineFirstWhere({
    this.assoc,
    this.assocs,
    this.loadedAssoc,
    this.loadedAssocs,
    this.multiLookupCustomGenerator,
  });

  @OfflineFirst(where: {'id': "data['id']"})
  final Future<OtherAssoc> assoc;

  @OfflineFirst(where: {'id': "data['id']", 'otherVar': "data['var']"})
  final List<Future<Assoc>> assocs;

  @OfflineFirst(where: {'id': "data['id']"})
  @Rest(toGenerator: '"Going to REST"')
  final Assoc loadedAssoc;

  @OfflineFirst(where: {'id': "data['id']"})
  final List<Assoc> loadedAssocs;

  @OfflineFirst(where: {'id': "data['id']", 'otherVar': "data['var']"})
  @Rest(toGenerator: '"As REST"')
  final List<Future<Assoc>> multiLookupCustomGenerator;
}

@ConnectOfflineFirstWithRest()
class Assoc extends OfflineFirstModel {
  final String name;
  Assoc({this.name});
}

@ConnectOfflineFirstWithRest()
class OtherAssoc extends OfflineFirstModel {
  final String name;
  OtherAssoc({this.name});
}
