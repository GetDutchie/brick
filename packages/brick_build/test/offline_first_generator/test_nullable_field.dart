import 'package:brick_offline_first_abstract/annotations.dart';

final output = r'''
Future<NullableField> _$NullableFieldFromRest(Map<String, dynamic> data,
    {RestProvider provider, OfflineFirstRepository repository}) async {
  return NullableField(
      restFalse: data['rest_false'] as String,
      restTrue: data['rest_true'] == null ? null : data['rest_true'] as String,
      sqliteFalse: data['sqlite_false'] as String,
      sqliteTrue: data['sqlite_true'] as String);
}

Future<Map<String, dynamic>> _$NullableFieldToRest(NullableField instance,
    {RestProvider provider, OfflineFirstRepository repository}) async {
  return {
    'rest_false': instance.restFalse,
    'rest_true': instance.restTrue,
    'sqlite_false': instance.sqliteFalse,
    'sqlite_true': instance.sqliteTrue
  };
}

Future<NullableField> _$NullableFieldFromSqlite(Map<String, dynamic> data,
    {SqliteProvider provider, OfflineFirstRepository repository}) async {
  return NullableField(
      restFalse: data['rest_false'] as String,
      restTrue: data['rest_true'] as String,
      sqliteFalse: data['sqlite_false'] as String,
      sqliteTrue:
          data['sqlite_true'] == null ? null : data['sqlite_true'] as String)
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$NullableFieldToSqlite(NullableField instance,
    {SqliteProvider provider, OfflineFirstRepository repository}) async {
  return {
    'rest_false': instance.restFalse,
    'rest_true': instance.restTrue,
    'sqlite_false': instance.sqliteFalse,
    'sqlite_true': instance.sqliteTrue
  };
}
''';

@ConnectOfflineFirst(
  restConfig: RestSerializable(nullable: false),
  sqliteConfig: SqliteSerializable(nullable: false),
)
class NullableField {
  NullableField({
    this.restFalse,
    this.restTrue,
    this.sqliteFalse,
    this.sqliteTrue,
  });

  @Rest(nullable: false)
  final String restFalse;

  @Rest(nullable: true)
  final String restTrue;

  @Sqlite(nullable: false)
  final String sqliteFalse;

  @Sqlite(nullable: true)
  final String sqliteTrue;
}
