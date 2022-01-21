import 'package:brick_graphql/graphql.dart';

final output = r'''
Future<GraphQLConstructorMemberFieldMismatch>
    _$GraphQLConstructorMemberFieldMismatchFromGraphQL(
        Map<String, dynamic> data,
        {required GraphqlProvider provider,
        GraphQLFirstRepository? repository}) async {
  return GraphQLConstructorMemberFieldMismatch(
      nullableConstructor: data['nullableConstructor'] as String?,
      nonNullableConstructor: data['nonNullableConstructor'] as String,
      someField: await Future.wait<Assoc>(data['someField']
              ?.map((d) => AssocAdapter()
                  .fromGraphQL(d, provider: provider, repository: repository))
              .toList()
              .cast<Future<Assoc>>() ??
          []));
}

Future<Map<String, dynamic>> _$GraphQLConstructorMemberFieldMismatchToGraphQL(
    GraphQLConstructorMemberFieldMismatch instance,
    {required GraphqlProvider provider,
    GraphQLFirstRepository? repository}) async {
  return {
    'nullableConstructor': instance.nullableConstructor,
    'nonNullableConstructor': instance.nonNullableConstructor,
    'someField': await Future.wait<Map<String, dynamic>>(instance.someField
        .map((s) => AssocAdapter()
            .toGraphQL(s, provider: provider, repository: repository))
        .toList())
  };
}
''';

/// Output serializing code for all models with the @[GraphqlSerializable] annotation.
/// [GraphqlSerializable] **does not** produce code.
/// A `const` class is required from an non-relative import,
/// and [GraphqlSerializable] was arbitrarily chosen for this test.
/// This will do nothing outside of this exact test suite.
@GraphqlSerializable()
class GraphQLConstructorMemberFieldMismatch extends GraphqlModel {
  final String nullableConstructor;
  final String nonNullableConstructor;

  final List<Assoc> someField;

  GraphQLConstructorMemberFieldMismatch({
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
