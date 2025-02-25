import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:brick_sqlite/brick_sqlite.dart';

const output = r'''
Future<IgnoreField> _$IgnoreFieldFromTest(
  Map<String, dynamic> data, {
  required TestProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return IgnoreField(name: data['name'] as String);
}

Future<Map<String, dynamic>> _$IgnoreFieldToTest(
  IgnoreField instance, {
  required TestProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {'name': instance.name};
}

Future<IgnoreField> _$IgnoreFieldFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return IgnoreField(email: data['email'] as String)
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$IgnoreFieldToSqlite(
  IgnoreField instance, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
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
