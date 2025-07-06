import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_rest/brick_rest.dart' show Rest;
import 'package:brick_sqlite/brick_sqlite.dart';

const output = r'''
Future<SpecifyFieldName> _$SpecifyFieldNameFromRest(
  Map<String, dynamic> data, {
  required RestProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return SpecifyFieldName(
    email: data['email_address'] == null
        ? null
        : data['email_address'] as String?,
  );
}

Future<Map<String, dynamic>> _$SpecifyFieldNameToRest(
  SpecifyFieldName instance, {
  required RestProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {'email_address': instance.email};
}

Future<SpecifyFieldName> _$SpecifyFieldNameFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return SpecifyFieldName(
    email: data['email_address'] == null
        ? null
        : data['email_address'] as String?,
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$SpecifyFieldNameToSqlite(
  SpecifyFieldName instance, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {'email_address': instance.email};
}
''';

@ConnectOfflineFirstWithRest()
class SpecifyFieldName {
  @Sqlite(name: 'email_address')
  @Rest(name: 'email_address')
  final String? email;

  SpecifyFieldName({this.email});
}
