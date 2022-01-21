import 'package:brick_graphql/graphql.dart';

final output = r'''
Future<GraphQLConstructorMemberFieldMismatch>
    _$GraphQLConstructorMemberFieldMismatchFromGraphQL(
        Map<String, dynamic> data,
        {required GraphQLProvider provider,
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
    {required GraphQLProvider provider,
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

/// Output serializing code for all models with the @[GraphQLSerializable] annotation.
/// [GraphQLSerializable] **does not** produce code.
/// A `const` class is required from an non-relative import,
/// and [GraphQLSerializable] was arbitrarily chosen for this test.
/// This will do nothing outside of this exact test suite.
@GraphQLSerializable()
class GraphQLConstructorMemberFieldMismatch extends GraphQLModel {
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

class Assoc extends GraphQLModel {
  final String someField;

  Assoc(this.someField);
}
