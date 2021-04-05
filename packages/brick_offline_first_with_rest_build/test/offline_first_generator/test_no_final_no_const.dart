import 'package:brick_offline_first_abstract/annotations.dart';

final output = r'''
Future<NoFinalNoConst> _$NoFinalNoConstFromRest(Map<String, dynamic> data,
    {required RestProvider provider,
    OfflineFirstRepository? repository}) async {
  return NoFinalNoConst(
      declaredVar: data['declared_var'] as int,
      regularVar: data['regular_var'] as bool);
}

Future<Map<String, dynamic>> _$NoFinalNoConstToRest(NoFinalNoConst instance,
    {required RestProvider provider,
    OfflineFirstRepository? repository}) async {
  return {
    'declared_var': instance.declaredVar,
    'regular_var': instance.regularVar,
    'computed_field': instance.computedField
  };
}

Future<NoFinalNoConst> _$NoFinalNoConstFromSqlite(Map<String, dynamic> data,
    {required SqliteProvider provider,
    OfflineFirstRepository? repository}) async {
  return NoFinalNoConst(
      declaredVar:
          data['declared_var'] == null ? null : data['declared_var'] as int,
      regularVar: data['regular_var'] == null ? null : data['regular_var'] == 1)
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$NoFinalNoConstToSqlite(NoFinalNoConst instance,
    {required SqliteProvider provider,
    OfflineFirstRepository? repository}) async {
  return {
    'declared_var': instance.declaredVar,
    'regular_var':
        instance.regularVar == null ? null : (instance.regularVar! ? 1 : 0),
    'computed_field': instance.computedField
  };
}
''';

@ConnectOfflineFirstWithRest()
class NoFinalNoConst {
  int declaredVar = 5;
  var regularVar = true;

  int get computedField => _privateVarField;
  int _privateVarField = 0;
  set computedField(value) => _privateVarField = value;
}
