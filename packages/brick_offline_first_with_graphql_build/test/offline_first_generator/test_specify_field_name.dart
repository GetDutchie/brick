import 'package:brick_graphql/graphql.dart';
import 'package:brick_offline_first_abstract/annotations.dart';

final output = r'''
Future<SpecifyFieldName> _$SpecifyFieldNameFromRest(Map<String, dynamic> data,
    {required RestProvider provider,
    OfflineFirstRepository? repository}) async {
  return SpecifyFieldName(email: data['email_address'] as String?);
}

Future<Map<String, dynamic>> _$SpecifyFieldNameToRest(SpecifyFieldName instance,
    {required RestProvider provider,
    OfflineFirstRepository? repository}) async {
  return {'email_address': instance.email};
}

Future<SpecifyFieldName> _$SpecifyFieldNameFromSqlite(Map<String, dynamic> data,
    {required SqliteProvider provider,
    OfflineFirstRepository? repository}) async {
  return SpecifyFieldName(
      email: data['email_address'] == null
          ? null
          : data['email_address'] as String?)
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$SpecifyFieldNameToSqlite(
    SpecifyFieldName instance,
    {required SqliteProvider provider,
    OfflineFirstRepository? repository}) async {
  return {'email_address': instance.email};
}
''';

@ConnectOfflineFirstWithGraphql()
class SpecifyFieldName {
  @Sqlite(name: 'email_address')
  @Graphql(name: 'email_address')
  final String? email;

  SpecifyFieldName({this.email});
}
