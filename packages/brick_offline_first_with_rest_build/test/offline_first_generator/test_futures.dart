import 'package:brick_offline_first_abstract/annotations.dart';
import 'package:brick_offline_first_abstract/abstract.dart';

final output = r'''
// GENERATED CODE DO NOT EDIT
// This file should NOT be version controlled and should not be manually edited.
part of '../brick.g.dart';

Future<Futures> _$FuturesFromRest(Map<String, dynamic> data,
    {RestProvider provider, OfflineFirstRepository repository}) async {
  return Futures(
      string: data['string'] as Future<String>,
      strings: data['strings']?.toList()?.cast<Future<String>>() ?? <String>[],
      futureStrings: data['future_strings']?.toList()?.cast<String>() ??
          <Future<String>>[],
      assoc: AssocAdapter()
          .fromRest(data['assoc'], provider: provider, repository: repository),
      assocs: Future.wait<Assoc>(data['assocs']
              ?.map((d) => AssocAdapter()
                  .fromRest(d, provider: provider, repository: repository))
              ?.toList()
              ?.cast<Future<Assoc>>() ??
          []),
      futureAssocs: data['future_assocs']
          ?.map((d) => AssocAdapter()
              .fromRest(d, provider: provider, repository: repository))
          ?.toList()
          ?.cast<Future<Assoc>>());
}

Future<Map<String, dynamic>> _$FuturesToRest(Futures instance,
    {RestProvider provider, OfflineFirstRepository repository}) async {
  return {
    'string': instance.string,
    'strings': instance.strings,
    'future_strings': instance.futureStrings,
    'assoc': await AssocAdapter().toRest((await instance.assoc)),
    'assocs': await Future.wait<Map<String, dynamic>>(instance.assocs
            ?.map((s) => AssocAdapter()
                .toRest(s, provider: provider, repository: repository))
            ?.toList() ??
        []),
    'future_assocs': await Future.wait<Map<String, dynamic>>(instance
            .futureAssocs
            ?.map((s) async => AssocAdapter()
                .toRest((await s), provider: provider, repository: repository))
            ?.toList() ??
        [])
  };
}

Future<Futures> _$FuturesFromSqlite(Map<String, dynamic> data,
    {SqliteProvider provider, OfflineFirstRepository repository}) async {
  return Futures(
      string: data['string'] == null ? null : data['string'] as Future<String>,
      strings: data['strings'] == null
          ? null
          : jsonDecode(data['strings'])?.toList()?.cast<String>(),
      futureStrings: data['future_strings'] == null
          ? null
          : jsonDecode(data['future_strings'])
              ?.toList()
              ?.cast<Future<String>>(),
      assoc: data['assoc_Assoc_brick_id'] == null
          ? null
          : (data['assoc_Assoc_brick_id'] > -1
              ? repository
                  ?.getAssociation<Assoc>(
                    Query.where(
                        'primaryKey', data['assoc_Assoc_brick_id'] as int,
                        limit1: true),
                  )
                  ?.then((r) => (r?.isEmpty ?? true) ? null : r.first)
              : null),
      assocs: data['assocs'] == null
          ? null
          : provider?.rawQuery(
              'SELECT DISTINCT `f_Assoc_brick_id` FROM `_brick_Futures_assocs` WHERE l_Futures_brick_id = ?',
              [
                  data['_brick_id'] as int
                ])?.then((results) {
              final ids = results.map((r) => (r ?? {})['f_Assoc_brick_id']);
              return Future.wait<Assoc>(
                  ids.map((primaryKey) async => await repository
                      ?.getAssociation<Assoc>(
                        Query.where('primaryKey', primaryKey, limit1: true),
                      )
                      ?.then((r) => (r?.isEmpty ?? true) ? null : r.first)));
            }),
      futureAssocs: await provider?.rawQuery(
          'SELECT DISTINCT `f_Assoc_brick_id` FROM `_brick_Futures_future_assocs` WHERE l_Futures_brick_id = ?',
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

Future<Map<String, dynamic>> _$FuturesToSqlite(Futures instance,
    {SqliteProvider provider, OfflineFirstRepository repository}) async {
  return {
    'string': instance.string,
    'strings': jsonEncode(instance.strings ?? []),
    'future_strings':
        jsonEncode(await Future.wait<String>(instance.futureStrings) ?? []),
    'assoc_Assoc_brick_id': (await instance.assoc)?.primaryKey ??
        await provider?.upsert<Assoc>((await instance.assoc),
            repository: repository)
  };
}

/// Construct a [Futures]
class FuturesAdapter extends OfflineFirstAdapter<Futures> {
  FuturesAdapter();

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
    'string': {
      'name': 'string',
      'type': String,
      'iterable': false,
      'association': false,
    },
    'strings': {
      'name': 'strings',
      'type': String,
      'iterable': false,
      'association': false,
    },
    'futureStrings': {
      'name': 'future_strings',
      'type': String,
      'iterable': true,
      'association': false,
    },
    'assoc': {
      'name': 'assoc',
      'type': Assoc,
      'iterable': false,
      'association': false,
    },
    'assocs': {
      'name': 'assocs',
      'type': Assoc,
      'iterable': false,
      'association': false,
    },
    'futureAssocs': {
      'name': 'future_assocs',
      'type': Assoc,
      'iterable': true,
      'association': true,
    }
  };
  Future<int> primaryKeyByUniqueColumns(
          Futures instance, DatabaseExecutor executor) async =>
      null;
  final String tableName = 'Futures';
  Future<void> afterSave(instance, {provider, repository}) async {
    if (instance.primaryKey != null) {
      await Future.wait<int>(instance.futureAssocs?.map((s) async {
        final id = (await s)?.primaryKey ??
            await provider?.upsert<Assoc>((await s), repository: repository);
        return await provider?.rawInsert(
            'INSERT OR IGNORE INTO `_brick_Futures_future_assocs` (`l_Futures_brick_id`, `f_Assoc_brick_id`) VALUES (?, ?)',
            [instance.primaryKey, id]);
      }) ?? []);
    }
  }

  Future<Futures> fromRest(Map<String, dynamic> input,
          {provider, repository}) async =>
      await _$FuturesFromRest(input,
          provider: provider, repository: repository);
  Future<Map<String, dynamic>> toRest(Futures input,
          {provider, repository}) async =>
      await _$FuturesToRest(input, provider: provider, repository: repository);
  Future<Futures> fromSqlite(Map<String, dynamic> input,
          {provider, repository}) async =>
      await _$FuturesFromSqlite(input,
          provider: provider, repository: repository);
  Future<Map<String, dynamic>> toSqlite(Futures input,
          {provider, repository}) async =>
      await _$FuturesToSqlite(input,
          provider: provider, repository: repository);
}
''';

@ConnectOfflineFirstWithRest()
class Futures extends OfflineFirstModel {
  Futures({
    this.string,
    this.strings,
    this.futureStrings,
    this.assoc,
    this.assocs,
    this.futureAssocs,
  });

  final Future<String> string;

  final Future<List<String>> strings;

  final List<Future<String>> futureStrings;

  final Future<Assoc> assoc;

  final Future<List<Assoc>> assocs;

  final List<Future<Assoc>> futureAssocs;
}

@ConnectOfflineFirstWithRest()
class Assoc extends OfflineFirstModel {}
