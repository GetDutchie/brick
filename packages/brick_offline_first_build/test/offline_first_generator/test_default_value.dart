import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_rest/brick_rest.dart' show Rest;
import 'package:brick_sqlite/brick_sqlite.dart';

const output = r'''
Future<DefaultValue> _$DefaultValueFromTest(
  Map<String, dynamic> data, {
  required TestProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return DefaultValue(
    string: data['string'] == null
        ? null
        : data['string'] as String? ?? "Thomas",
  );
}

Future<Map<String, dynamic>> _$DefaultValueToTest(
  DefaultValue instance, {
  required TestProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {'string': instance.string};
}

Future<DefaultValue> _$DefaultValueFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return DefaultValue(
    string: data['string'] == null ? null : data['string'] as String? ?? "Guy",
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$DefaultValueToSqlite(
  DefaultValue instance, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {'string': instance.string};
}
''';

@ConnectOfflineFirstWithRest()
class DefaultValue {
  DefaultValue({
    this.string,
  });

  @Rest(defaultValue: '"Thomas"')
  @Sqlite(defaultValue: '"Guy"')
  final String? string;
}
