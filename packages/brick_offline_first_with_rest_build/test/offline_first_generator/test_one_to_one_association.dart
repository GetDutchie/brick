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

Future<OneToOneAssociation> _$OneToOneAssociationFromRest(
    Map<String, dynamic> data,
    {RestProvider provider,
    OfflineFirstRepository repository}) async {
  return OneToOneAssociation(
      assoc: await SqliteAssocAdapter()
          .fromRest(data['assoc'], provider: provider, repository: repository),
      assoc2: await SqliteAssocAdapter().fromRest(data['assoc2'],
          provider: provider, repository: repository));
}

Future<Map<String, dynamic>> _$OneToOneAssociationToRest(
    OneToOneAssociation instance,
    {RestProvider provider,
    OfflineFirstRepository repository}) async {
  return {
    'assoc': await SqliteAssocAdapter().toRest(instance.assoc ?? {}),
    'assoc2': await SqliteAssocAdapter().toRest(instance.assoc2 ?? {})
  };
}

Future<OneToOneAssociation> _$OneToOneAssociationFromSqlite(
    Map<String, dynamic> data,
    {SqliteProvider provider,
    OfflineFirstRepository repository}) async {
  return OneToOneAssociation(
      assoc: data['assoc_SqliteAssoc_brick_id'] == null
          ? null
          : (data['assoc_SqliteAssoc_brick_id'] > -1
              ? (await repository?.getAssociation<SqliteAssoc>(
                  Query.where(
                      'primaryKey', data['assoc_SqliteAssoc_brick_id'] as int,
                      limit1: true),
                ))
                  ?.first
              : null),
      assoc2: data['assoc2_SqliteAssoc_brick_id'] == null
          ? null
          : (data['assoc2_SqliteAssoc_brick_id'] > -1
              ? (await repository?.getAssociation<SqliteAssoc>(
                  Query.where(
                      'primaryKey', data['assoc2_SqliteAssoc_brick_id'] as int,
                      limit1: true),
                ))
                  ?.first
              : null))
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$OneToOneAssociationToSqlite(
    OneToOneAssociation instance,
    {SqliteProvider provider,
    OfflineFirstRepository repository}) async {
  return {
    'assoc_SqliteAssoc_brick_id': instance.assoc?.primaryKey,
    'assoc2_SqliteAssoc_brick_id': instance.assoc2?.primaryKey
  };
}
''';

@ConnectOfflineFirstWithRest()
class OneToOneAssociation extends OfflineFirstModel {
  OneToOneAssociation({this.assoc, this.assoc2});

  final SqliteAssoc assoc;
  final SqliteAssoc assoc2;
}
