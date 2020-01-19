import 'package:brick_offline_first_abstract/annotations.dart';
import 'package:brick_offline_first_abstract/abstract.dart';
import 'package:brick_rest/rest.dart' show Rest;

@ConnectOfflineFirstWithRest()
class SqliteAssoc extends OfflineFirstModel {
  @Rest(ignore: true)
  @Sqlite(ignore: true)
  int key = -1;
}

final output = r'''
Future<SqliteAssoc> _$SqliteAssocFromRest(Map<String, dynamic> data,
    {RestProvider provider, OfflineFirstRepository repository}) async {
  return SqliteAssoc();
}

Future<Map<String, dynamic>> _$SqliteAssocToRest(SqliteAssoc instance,
    {RestProvider provider, OfflineFirstRepository repository}) async {
  return {};
}

Future<SqliteAssoc> _$SqliteAssocFromSqlite(Map<String, dynamic> data,
    {SqliteProvider provider, OfflineFirstRepository repository}) async {
  return SqliteAssoc()..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$SqliteAssocToSqlite(SqliteAssoc instance,
    {SqliteProvider provider, OfflineFirstRepository repository}) async {
  return {};
}

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
      assoc: data['assoc'] == null
          ? null
          : await Future.wait<SqliteAssoc>(jsonDecode(data['assoc'] ?? [])
              .map((primaryKey) => repository
                  ?.getAssociation<SqliteAssoc>(
                    Query.where('primaryKey', primaryKey, limit1: true),
                  )
                  ?.then((r) => (r?.isEmpty ?? true) ? null : r.first))
              ?.toList()
              ?.cast<Future<SqliteAssoc>>()))
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$OneToManyAssociationToSqlite(
    OneToManyAssociation instance,
    {SqliteProvider provider,
    OfflineFirstRepository repository}) async {
  return {
    'assoc': jsonEncode((await Future.wait<int>(instance.assoc
                ?.map((s) async {
                  return s?.primaryKey ??
                      await provider?.upsert<SqliteAssoc>(s,
                          repository: repository);
                })
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
class OneToManyAssociation extends OfflineFirstModel {
  OneToManyAssociation({this.assoc});

  final List<SqliteAssoc> assoc;
}
