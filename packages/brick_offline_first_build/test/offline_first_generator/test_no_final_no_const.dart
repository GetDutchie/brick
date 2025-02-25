// ignore_for_file: omit_obvious_property_types

import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';

const output = r'''
Future<NoFinalNoConst> _$NoFinalNoConstFromTest(
  Map<String, dynamic> data, {
  required TestProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return NoFinalNoConst(
    declaredVar: data['declared_var'] as int,
    regularVar: data['regular_var'] as bool,
  );
}

Future<Map<String, dynamic>> _$NoFinalNoConstToTest(
  NoFinalNoConst instance, {
  required TestProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {
    'declared_var': instance.declaredVar,
    'regular_var': instance.regularVar,
    'computed_field': instance.computedField,
  };
}

Future<NoFinalNoConst> _$NoFinalNoConstFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return NoFinalNoConst(
    declaredVar: data['declared_var'] as int,
    regularVar: data['regular_var'] == 1,
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$NoFinalNoConstToSqlite(
  NoFinalNoConst instance, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {
    'declared_var': instance.declaredVar,
    'regular_var': instance.regularVar ? 1 : 0,
    'computed_field': instance.computedField,
  };
}
''';

@ConnectOfflineFirstWithRest()
class NoFinalNoConst {
  int declaredVar = 5;
  bool regularVar = true;

  int get computedField => _privateVarField;
  int _privateVarField = 0;
  set computedField(dynamic value) => _privateVarField = value;
}
