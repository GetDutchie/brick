import 'package:brick_offline_first_abstract/annotations.dart';
import 'package:brick_offline_first_abstract/abstract.dart';
import 'package:brick_rest/rest.dart' show Rest;

final output = r'''
Future<Assoc> _$AssocFromRest(Map<String, dynamic> data,
    {RestProvider provider, OfflineFirstRepository repository}) async {
  return Assoc(name: data['name'] as String);
}

Future<Map<String, dynamic>> _$AssocToRest(Assoc instance,
    {RestProvider provider, OfflineFirstRepository repository}) async {
  return {'name': instance.name};
}

Future<Assoc> _$AssocFromSqlite(Map<String, dynamic> data,
    {SqliteProvider provider, OfflineFirstRepository repository}) async {
  return Assoc(name: data['name'] == null ? null : data['name'] as String)
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$AssocToSqlite(Assoc instance,
    {SqliteProvider provider, OfflineFirstRepository repository}) async {
  return {'name': instance.name};
}

Future<OtherAssoc> _$OtherAssocFromRest(Map<String, dynamic> data,
    {RestProvider provider, OfflineFirstRepository repository}) async {
  return OtherAssoc(name: data['name'] as String);
}

Future<Map<String, dynamic>> _$OtherAssocToRest(OtherAssoc instance,
    {RestProvider provider, OfflineFirstRepository repository}) async {
  return {'name': instance.name};
}

Future<OtherAssoc> _$OtherAssocFromSqlite(Map<String, dynamic> data,
    {SqliteProvider provider, OfflineFirstRepository repository}) async {
  return OtherAssoc(name: data['name'] == null ? null : data['name'] as String)
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$OtherAssocToSqlite(OtherAssoc instance,
    {SqliteProvider provider, OfflineFirstRepository repository}) async {
  return {'name': instance.name};
}

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
      assocs: data['assocs'] == null
          ? null
          : provider
              ?.rawQuery(
                  'SELECT `Assoc_brick_id` FROM `_brick_OfflineFirstWhere_assocs`')
              ?.then(
                  (results) => results.map((r) => (r ?? {})['Assoc_brick_id']))
              ?.then((ids) => ids.map((primaryKey) => repository
                  ?.getAssociation<Assoc>(
                    Query.where('primaryKey', primaryKey, limit1: true),
                  )
                  ?.then((r) => (r?.isEmpty ?? true) ? null : r.first)))
              ?.toList()
              ?.cast<Future<Assoc>>(),
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
      loadedAssocs: data['loaded_assocs'] == null
          ? null
          : await Future.wait<Assoc>(provider
              ?.rawQuery(
                  'SELECT `Assoc_brick_id` FROM `_brick_OfflineFirstWhere_loaded_assocs`')
              ?.then(
                  (results) => results.map((r) => (r ?? {})['Assoc_brick_id']))
              ?.then((ids) => ids.map((primaryKey) => repository
                  ?.getAssociation<Assoc>(
                    Query.where('primaryKey', primaryKey, limit1: true),
                  )
                  ?.then((r) => (r?.isEmpty ?? true) ? null : r.first)))
              ?.toList()
              ?.cast<Future<Assoc>>()),
      multiLookupCustomGenerator: data['multi_lookup_custom_generator'] == null
          ? null
          : provider
              ?.rawQuery(
                  'SELECT `Assoc_brick_id` FROM `_brick_OfflineFirstWhere_multi_lookup_custom_generator`')
              ?.then(
                  (results) => results.map((r) => (r ?? {})['Assoc_brick_id']))
              ?.then((ids) => ids.map((primaryKey) => repository
                  ?.getAssociation<Assoc>(
                    Query.where('primaryKey', primaryKey, limit1: true),
                  )
                  ?.then((r) => (r?.isEmpty ?? true) ? null : r.first)))
              ?.toList()
              ?.cast<Future<Assoc>>())
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
    'assocs': jsonEncode(await Future.wait<Assoc>(instance.assocs) ?? []),
    'loaded_assoc_Assoc_brick_id': instance.loadedAssoc?.primaryKey ??
        await provider?.upsert<Assoc>(instance.loadedAssoc,
            repository: repository),
    'multi_lookup_custom_generator': jsonEncode(
        await Future.wait<Assoc>(instance.multiLookupCustomGenerator) ?? [])
  };
}
''';

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
