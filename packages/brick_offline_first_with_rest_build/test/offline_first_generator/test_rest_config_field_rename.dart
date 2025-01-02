import 'package:brick_core/field_rename.dart';
import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_rest/brick_rest.dart' show RestSerializable;

const output = r'''
Future<SpecifyFieldName> _$SpecifyFieldNameFromRest(Map<String, dynamic> data,
    {required RestProvider provider,
    OfflineFirstRepository? repository}) async {
  return SpecifyFieldName(
      email: data['email_address'] == null
          ? null
          : data['email_address'] as String?);
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

@ConnectOfflineFirstWithRest(
  restConfig: RestSerializable(fieldRename: FieldRename.none),
)
class RestConfigNoRename extends OfflineFirstModel {
  final int someLongField;

  RestConfigNoRename(this.someLongField);
}

@ConnectOfflineFirstWithRest(
  restConfig: RestSerializable.defaults,
)
class RestConfigSnakeRename extends OfflineFirstModel {
  final int someLongField;

  RestConfigSnakeRename(this.someLongField);
}

@ConnectOfflineFirstWithRest(
  restConfig: RestSerializable(fieldRename: FieldRename.kebab),
)
class RestConfigKebabRename extends OfflineFirstModel {
  final int someLongField;

  RestConfigKebabRename(this.someLongField);
}

@ConnectOfflineFirstWithRest(
  restConfig: RestSerializable(fieldRename: FieldRename.pascal),
)
class RestConfigPascalRename extends OfflineFirstModel {
  final int someLongField;

  RestConfigPascalRename(this.someLongField);
}
