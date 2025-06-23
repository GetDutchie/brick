import 'package:brick_offline_first/brick_offline_first.dart' show OfflineFirstSerdes;
import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';

const output = r'''
Future<CustomOfflineFirstSerdes> _$CustomOfflineFirstSerdesFromTest(
  Map<String, dynamic> data, {
  required TestProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return CustomOfflineFirstSerdes(
    string: data['string'] == null
        ? null
        : Serializable.fromTest(data['string']),
    constructorFieldNullabilityMismatch:
        data['constructor_field_nullability_mismatch'] as bool?,
    strings: data['strings'] == null
        ? null
        : data['strings']
              ?.map((c) => Serializable.fromTest(c as Map<String, dynamic>))
              .toList()
              .cast<Serializable>(),
  );
}

Future<Map<String, dynamic>> _$CustomOfflineFirstSerdesToTest(
  CustomOfflineFirstSerdes instance, {
  required TestProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {
    'string': instance.string?.toTest(),
    'constructor_field_nullability_mismatch':
        instance.constructorFieldNullabilityMismatch,
    'strings': instance.strings?.map((Serializable c) => c.toTest()).toList(),
  };
}

Future<CustomOfflineFirstSerdes> _$CustomOfflineFirstSerdesFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return CustomOfflineFirstSerdes(
    string: data['string'] == null
        ? null
        : Serializable.fromSqlite(data['string'] as int),
    constructorFieldNullabilityMismatch:
        data['constructor_field_nullability_mismatch'] == 1,
    strings: data['strings'] == null
        ? null
        : jsonDecode(data['strings'])
              .map((c) => Serializable.fromSqlite(c as int))
              .toList()
              .cast<Serializable>(),
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$CustomOfflineFirstSerdesToSqlite(
  CustomOfflineFirstSerdes instance, {
  required SqliteProvider provider,
  OfflineFirstRepository? repository,
}) async {
  return {
    'constructor_field_nullability_mismatch':
        instance.constructorFieldNullabilityMismatch ? 1 : 0,
  };
}
''';

class Serializable extends OfflineFirstSerdes<Map<String, dynamic>, int> {
  final int age;
  Serializable(this.age);

  Map<String, dynamic> toTest() => {'age': '$age'};

  factory Serializable.fromTest(Map<String, dynamic> data) {
    return Serializable(data['age']);
  }

  factory Serializable.fromSqlite(age) {
    return Serializable(age);
  }
}

@ConnectOfflineFirstWithRest()
class CustomOfflineFirstSerdes {
  CustomOfflineFirstSerdes({this.string, this.strings, bool? constructorFieldNullabilityMismatch})
      : constructorFieldNullabilityMismatch = constructorFieldNullabilityMismatch ?? false;

  final Serializable? string;

  final bool constructorFieldNullabilityMismatch;

  final List<Serializable>? strings;
}
