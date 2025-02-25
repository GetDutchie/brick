import 'package:brick_rest/brick_rest.dart';

const output = r'''
Future<RestConstructorMemberFieldMismatch>
_$RestConstructorMemberFieldMismatchFromRest(
  Map<String, dynamic> data, {
  required RestProvider provider,
  RestFirstRepository? repository,
}) async {
  return RestConstructorMemberFieldMismatch(
    nullableConstructor: data['nullable_constructor'] as String?,
    nonNullableConstructor: data['non_nullable_constructor'] as String,
    someField: await Future.wait<Assoc>(
      data['some_field']
              ?.map(
                (d) => AssocAdapter().fromRest(
                  d,
                  provider: provider,
                  repository: repository,
                ),
              )
              .toList()
              .cast<Future<Assoc>>() ??
          [],
    ),
  );
}

Future<Map<String, dynamic>> _$RestConstructorMemberFieldMismatchToRest(
  RestConstructorMemberFieldMismatch instance, {
  required RestProvider provider,
  RestFirstRepository? repository,
}) async {
  return {
    'nullable_constructor': instance.nullableConstructor,
    'non_nullable_constructor': instance.nonNullableConstructor,
    'some_field': await Future.wait<Map<String, dynamic>>(
      instance.someField
          .map(
            (s) => AssocAdapter().toRest(
              s,
              provider: provider,
              repository: repository,
            ),
          )
          .toList(),
    ),
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

  final List<Assoc> someField;

  RestConstructorMemberFieldMismatch({
    String? nullableConstructor,
    required this.nonNullableConstructor,
    List<Assoc>? someField,
  })  : nullableConstructor = nullableConstructor ?? 'default',
        someField = someField ?? <Assoc>[];
}

class Assoc extends RestModel {
  final String someField;

  Assoc(this.someField);
}
