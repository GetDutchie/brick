import 'package:brick_rest/rest.dart';

final output = r'''
Future<RestConstructorMemberFieldMismatch>
    _$RestConstructorMemberFieldMismatchFromRest(Map<String, dynamic> data,
        {required RestProvider provider,
        RestFirstRepository? repository}) async {
  return RestConstructorMemberFieldMismatch(
      nullableConstructor: data['nullable_constructor'] as String?,
      nonNullableConstructor: data['non_nullable_constructor'] as String);
}

Future<Map<String, dynamic>> _$RestConstructorMemberFieldMismatchToRest(
    RestConstructorMemberFieldMismatch instance,
    {required RestProvider provider,
    RestFirstRepository? repository}) async {
  return {
    'nullable_constructor': instance.nullableConstructor,
    'non_nullable_constructor': instance.nonNullableConstructor
  };
}
''';

/// Output serializing code for all models with the @[RestSerializable] annotation.
/// [RestSerializable] **does not** produce code.
/// A `const` class is required from an non-relative import,
/// and [RestSerializable] was arbitrarily chosen for this test.
/// This will do nothing outside of this exact test suite.
@RestSerializable()
class RestConstructorMemberFieldMismatch extends RestModel {
  final String nullableConstructor;
  final String nonNullableConstructor;

  RestConstructorMemberFieldMismatch(
      {String? nullableConstructor, required this.nonNullableConstructor})
      : nullableConstructor = nullableConstructor ?? 'default';
}
