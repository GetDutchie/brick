import 'package:brick_supabase/brick_supabase.dart';

const output = r'''
Future<SupabaseConstructorMemberFieldMismatch>
_$SupabaseConstructorMemberFieldMismatchFromSupabase(
  Map<String, dynamic> data, {
  required SupabaseProvider provider,
  SupabaseFirstRepository? repository,
}) async {
  return SupabaseConstructorMemberFieldMismatch(
    nullableConstructor: data['nullable_constructor'] as String?,
    nonNullableConstructor: data['non_nullable_constructor'] as String,
    someField: await Future.wait<Assoc>(
      data['some_field']
              ?.map(
                (d) => AssocAdapter().fromSupabase(
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

Future<Map<String, dynamic>> _$SupabaseConstructorMemberFieldMismatchToSupabase(
  SupabaseConstructorMemberFieldMismatch instance, {
  required SupabaseProvider provider,
  SupabaseFirstRepository? repository,
}) async {
  return {
    'nullable_constructor': instance.nullableConstructor,
    'non_nullable_constructor': instance.nonNullableConstructor,
    'some_field': await Future.wait<Map<String, dynamic>>(
      instance.someField
          .map(
            (s) => AssocAdapter().toSupabase(
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

/// Output serializing code for all models with the @[SupabaseSerializable] annotation.
/// [SupabaseSerializable] **does not** produce code.
/// A `const` class is required from an non-relative import,
/// and [SupabaseSerializable] was arbitrarily chosen for this test.
/// This will do nothing outside of this exact test suite.
@SupabaseSerializable()
class SupabaseConstructorMemberFieldMismatch extends SupabaseModel {
  final String nullableConstructor;
  final String nonNullableConstructor;

  final List<Assoc> someField;

  SupabaseConstructorMemberFieldMismatch({
    String? nullableConstructor,
    required this.nonNullableConstructor,
    List<Assoc>? someField,
  })  : nullableConstructor = nullableConstructor ?? 'default',
        someField = someField ?? <Assoc>[];
}

class Assoc extends SupabaseModel {
  final String someField;

  Assoc(this.someField);
}
