import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:brick_sqlite/brick_sqlite.dart';

const output = r'''
Future<NullableField> _$NullableFieldFromTest(
  Map<String, dynamic> data, {
  required TestProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return NullableField(
    restFalse: data['rest_false'] == null
        ? null
        : data['rest_false'] as String?,
    nullableRestTrue: data['nullable_rest_true'] == null
        ? null
        : data['nullable_rest_true'] as String?,
    restTrue: data['rest_true'] as String,
    sqliteFalse: data['sqlite_false'] == null
        ? null
        : data['sqlite_false'] as String?,
    sqliteTrue: data['sqlite_true'] == null
        ? null
        : data['sqlite_true'] as String?,
    constructorFieldNullabilityMismatch:
        data['constructor_field_nullability_mismatch'] as String?,
    constructorFieldTypeMismatch:
        data['constructor_field_type_mismatch'] as bool,
  );
}

Future<Map<String, dynamic>> _$NullableFieldToTest(
  NullableField instance, {
  required TestProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {
    'rest_false': instance.restFalse,
    'nullable_rest_true': instance.nullableRestTrue,
    'rest_true': instance.restTrue,
    'sqlite_false': instance.sqliteFalse,
    'sqlite_true': instance.sqliteTrue,
    'constructor_field_nullability_mismatch':
        instance.constructorFieldNullabilityMismatch,
    'constructor_field_type_mismatch': instance.constructorFieldTypeMismatch,
  };
}

Future<NullableField> _$NullableFieldFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return NullableField(
    restFalse: data['rest_false'] == null
        ? null
        : data['rest_false'] as String?,
    nullableRestTrue: data['nullable_rest_true'] == null
        ? null
        : data['nullable_rest_true'] as String?,
    restTrue: data['rest_true'] as String,
    sqliteFalse: data['sqlite_false'] == null
        ? null
        : data['sqlite_false'] as String?,
    sqliteTrue: data['sqlite_true'] == null
        ? null
        : data['sqlite_true'] as String?,
    constructorFieldNullabilityMismatch:
        data['constructor_field_nullability_mismatch'] as String,
    constructorFieldTypeMismatch:
        data['constructor_field_type_mismatch'] as String,
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$NullableFieldToSqlite(
  NullableField instance, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {
    'rest_false': instance.restFalse,
    'nullable_rest_true': instance.nullableRestTrue,
    'rest_true': instance.restTrue,
    'sqlite_false': instance.sqliteFalse,
    'sqlite_true': instance.sqliteTrue,
    'constructor_field_nullability_mismatch':
        instance.constructorFieldNullabilityMismatch,
    'constructor_field_type_mismatch': instance.constructorFieldTypeMismatch,
  };
}
''';

@ConnectOfflineFirstWithRest(
  restConfig: RestSerializable.defaults,
  sqliteConfig: SqliteSerializable(nullable: false),
)
class NullableField {
  NullableField({
    String? constructorFieldNullabilityMismatch,
    required bool constructorFieldTypeMismatch,
    this.restFalse,
    this.nullableRestTrue,
    required this.restTrue,
    this.sqliteFalse,
    this.sqliteTrue,
  })  : constructorFieldNullabilityMismatch = constructorFieldNullabilityMismatch ?? 'default',
        constructorFieldTypeMismatch = constructorFieldTypeMismatch ? 'true' : 'false';

  final String? restFalse;

  final String? nullableRestTrue;

  final String restTrue;

  final String? sqliteFalse;

  final String? sqliteTrue;

  final String constructorFieldNullabilityMismatch;

  final String constructorFieldTypeMismatch;
}
