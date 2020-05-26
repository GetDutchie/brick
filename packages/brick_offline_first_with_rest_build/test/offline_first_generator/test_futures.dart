import 'package:brick_offline_first_abstract/annotations.dart';
import 'package:brick_offline_first_abstract/abstract.dart';

final output = r'''
Future<Assoc> _$AssocFromRest(Map<String, dynamic> data,
    {RestProvider provider, OfflineFirstRepository repository}) async {
  return Assoc();
}

Future<Map<String, dynamic>> _$AssocToRest(Assoc instance,
    {RestProvider provider, OfflineFirstRepository repository}) async {
  return {};
}

Future<Assoc> _$AssocFromSqlite(Map<String, dynamic> data,
    {SqliteProvider provider, OfflineFirstRepository repository}) async {
  return Assoc()..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$AssocToSqlite(Assoc instance,
    {SqliteProvider provider, OfflineFirstRepository repository}) async {
  return {};
}

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
    'assocs': await Future.wait<Map<String, dynamic>>(
        instance.assocs?.map((s) => AssocAdapter().toRest(s))?.toList() ?? []),
    'future_assocs': await Future.wait<Map<String, dynamic>>(instance
            .futureAssocs
            ?.map((s) async => AssocAdapter().toRest((await s)))
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
          : Future.wait<Assoc>(jsonDecode(data['assocs'] ?? '[]')
              .map((primaryKey) async => await repository
                  ?.getAssociation<Assoc>(
                    Query.where('primaryKey', primaryKey, limit1: true),
                  )
                  ?.then((r) => (r?.isEmpty ?? true) ? null : r.first))
              ?.toList()
              ?.cast<Future<Assoc>>()),
      futureAssocs: data['future_assocs'] == null
          ? null
          : jsonDecode(data['future_assocs'] ?? '[]')
              .map((primaryKey) => repository
                  ?.getAssociation<Assoc>(
                    Query.where('primaryKey', primaryKey, limit1: true),
                  )
                  ?.then((r) => (r?.isEmpty ?? true) ? null : r.first))
              ?.toList()
              ?.cast<Future<Assoc>>())
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
            repository: repository),
    'assocs': jsonEncode((await Future.wait<int>((await instance.assocs)
                ?.map((s) async {
                  return s?.primaryKey ??
                      await provider?.upsert<Assoc>(s, repository: repository);
                })
                ?.toList()
                ?.cast<Future<int>>() ??
            []))
        .where((s) => s != null)
        .toList()
        .cast<int>()),
    'future_assocs': jsonEncode((await Future.wait<int>(instance.futureAssocs
                ?.map((s) async =>
                    (await s)?.primaryKey ??
                    await provider?.upsert<Assoc>((await s),
                        repository: repository))
                ?.toList()
                ?.cast<Future<int>>() ??
            []))
        .where((s) => s != null)
        .toList()
        .cast<int>())
  };
}
''';

@ConnectOfflineFirstWithRest()
class Assoc extends OfflineFirstModel {}

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
