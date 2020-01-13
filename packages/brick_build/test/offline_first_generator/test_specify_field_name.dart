import 'package:brick_offline_first_abstract/annotations.dart';
import 'package:brick_rest/rest.dart' show Rest;

final output = r'''
Future<SpecifyFieldName> _$SpecifyFieldNameFromRest(Map<String, dynamic> data,
    {RestProvider provider, OfflineFirstRepository repository}) async {
  return SpecifyFieldName(email: data['email_address'] as String);
}

Future<Map<String, dynamic>> _$SpecifyFieldNameToRest(SpecifyFieldName instance,
    {RestProvider provider, OfflineFirstRepository repository}) async {
  return {'email_address': instance.email};
}

Future<SpecifyFieldName> _$SpecifyFieldNameFromSqlite(Map<String, dynamic> data,
    {SqliteProvider provider, OfflineFirstRepository repository}) async {
  return SpecifyFieldName(
      email: data['email_address'] == null
          ? null
          : data['email_address'] as String)
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$SpecifyFieldNameToSqlite(
    SpecifyFieldName instance,
    {SqliteProvider provider,
    OfflineFirstRepository repository}) async {
  return {'email_address': instance.email};
}
''';

@ConnectOfflineFirst()
class SpecifyFieldName {
  SpecifyFieldName({this.email});

  @Sqlite(name: 'email_address')
  @Rest(name: 'email_address')
  final String email;
}
