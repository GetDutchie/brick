import 'package:brick_graphql/brick_graphql.dart';

const output = r'''
Future<GraphqlConstructorMemberFieldMismatch>
_$GraphqlConstructorMemberFieldMismatchFromGraphql(
  Map<String, dynamic> data, {
  required GraphqlProvider provider,
  GraphqlFirstRepository? repository,
}) async {
  return GraphqlConstructorMemberFieldMismatch(
    nullableConstructor: data['nullableConstructor'] as String?,
    nonNullableConstructor: data['nonNullableConstructor'] as String,
    someField: await Future.wait<Assoc>(
      data['someField']
              ?.map(
                (d) => AssocAdapter().fromGraphql(
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

Future<Map<String, dynamic>> _$GraphqlConstructorMemberFieldMismatchToGraphql(
  GraphqlConstructorMemberFieldMismatch instance, {
  required GraphqlProvider provider,
  GraphqlFirstRepository? repository,
}) async {
  return {
    'nullableConstructor': instance.nullableConstructor,
    'nonNullableConstructor': instance.nonNullableConstructor,
    'someField': await Future.wait<Map<String, dynamic>>(
      instance.someField
          .map(
            (s) => AssocAdapter().toGraphql(
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

/// Output serializing code for all models with the @[GraphqlSerializable] annotation.
/// [GraphqlSerializable] **does not** produce code.
/// A `const` class is required from an non-relative import,
/// and [GraphqlSerializable] was arbitrarily chosen for this test.
/// This will do nothing outside of this exact test suite.
@GraphqlSerializable()
class GraphqlConstructorMemberFieldMismatch extends GraphqlModel {
  final String nullableConstructor;
  final String nonNullableConstructor;

  final List<Assoc> someField;

  GraphqlConstructorMemberFieldMismatch({
    String? nullableConstructor,
    required this.nonNullableConstructor,
    List<Assoc>? someField,
  })  : nullableConstructor = nullableConstructor ?? 'default',
        someField = someField ?? <Assoc>[];
}

class Assoc extends GraphqlModel {
  final String someField;

  Assoc(this.someField);
}
