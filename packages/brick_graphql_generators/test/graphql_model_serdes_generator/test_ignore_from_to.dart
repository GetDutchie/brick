import 'package:brick_graphql/graphql.dart';

final output = r'''
Future<GraphQLIgnoreFromTo> _$GraphQLIgnoreFromToFromGraphQL(
    Map<String, dynamic> data,
    {required GraphQLProvider provider,
    GraphQLFirstRepository? repository}) async {
  return GraphQLIgnoreFromTo(
      ignoredTo: data['ignoredTo'] as bool,
      otherIgnoredTo: data['otherIgnoredTo'] as bool,
      normal: data['normal'] as bool);
}

Future<Map<String, dynamic>> _$GraphQLIgnoreFromToToGraphQL(
    GraphQLIgnoreFromTo instance,
    {required GraphQLProvider provider,
    GraphQLFirstRepository? repository}) async {
  return {'ignoredFrom': instance.ignoredFrom, 'normal': instance.normal};
}
''';

/// Output serializing code for all models with the @[GraphqlSerializable] annotation.
/// [GraphqlSerializable] **does not** produce code.
/// A `const` class is required from an non-relative import,
/// and [GraphqlSerializable] was arbitrarily chosen for this test.
/// This will do nothing outside of this exact test suite.
@GraphqlSerializable()
class GraphQLIgnoreFromTo extends GraphqlModel {
  @GraphQL(ignoreFrom: true)
  final bool ignoredFrom;

  @GraphQL(ignoreTo: true)
  final bool ignoredTo;

  @GraphQL(ignoreTo: true, ignoreFrom: false)
  final bool otherIgnoredTo;

  @GraphQL(ignore: true, ignoreTo: false, ignoreFrom: false)
  final bool ignorePrecedence;

  final bool normal;

  GraphQLIgnoreFromTo(
    this.ignoredFrom,
    this.ignoredTo,
    this.otherIgnoredTo,
    this.ignorePrecedence,
    this.normal,
  );
}
