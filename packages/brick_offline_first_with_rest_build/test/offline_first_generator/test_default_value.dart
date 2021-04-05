import 'package:brick_offline_first_abstract/annotations.dart';
import 'package:brick_rest/rest.dart' show Rest;

final output = r'''
Future<DefaultValue> _$DefaultValueFromRest(Map<String, dynamic> data,
    {required RestProvider provider,
    OfflineFirstRepository? repository}) async {
  return DefaultValue(string: data['string'] as String? ?? "Thomas");
}

Future<Map<String, dynamic>> _$DefaultValueToRest(DefaultValue instance,
    {required RestProvider provider,
    OfflineFirstRepository? repository}) async {
  return {'string': instance.string};
}

Future<DefaultValue> _$DefaultValueFromSqlite(Map<String, dynamic> data,
    {required SqliteProvider provider,
    OfflineFirstRepository? repository}) async {
  return DefaultValue(
      string:
          data['string'] == null ? null : data['string'] as String? ?? "Guy")
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$DefaultValueToSqlite(DefaultValue instance,
    {required SqliteProvider provider,
    OfflineFirstRepository? repository}) async {
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
