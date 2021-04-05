import 'package:brick_offline_first_abstract/annotations.dart';
import 'package:brick_rest/rest.dart' show Rest;

final output = r'''
Future<IgnoreField> _$IgnoreFieldFromRest(Map<String, dynamic> data,
    {required RestProvider provider,
    OfflineFirstRepository? repository}) async {
  return IgnoreField(name: data['name'] as String);
}

Future<Map<String, dynamic>> _$IgnoreFieldToRest(IgnoreField instance,
    {required RestProvider provider,
    OfflineFirstRepository? repository}) async {
  return {'name': instance.name};
}

Future<IgnoreField> _$IgnoreFieldFromSqlite(Map<String, dynamic> data,
    {required SqliteProvider provider,
    OfflineFirstRepository? repository}) async {
  return IgnoreField(
      email: data['email'] == null ? null : data['email'] as String)
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$IgnoreFieldToSqlite(IgnoreField instance,
    {required SqliteProvider provider,
    OfflineFirstRepository? repository}) async {
  return {'email': instance.email};
}
''';

@ConnectOfflineFirstWithRest()
class IgnoreField {
  @Sqlite(ignore: true)
  final String name;

  @Rest(ignore: true)
  final String email;

  @Sqlite(ignore: true)
  @Rest(ignore: true)
  final String phone;

  IgnoreField(this.name, this.email, this.phone);
}
