import 'package:brick_graphql/brick_graphql.dart';

const output = r'''
// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<GraphqlRuntimeAssociationDefinition>
_$GraphqlRuntimeAssociationDefinitionFromGraphql(
  Map<String, dynamic> data, {
  required GraphqlProvider provider,
  GraphqlFirstRepository? repository,
}) async {
  return GraphqlRuntimeAssociationDefinition(
    nonIterable: await AssocAdapter().fromGraphql(
      data['nonIterable'],
      provider: provider,
      repository: repository,
    ),
    iterable: await Future.wait<Assoc>(
      data['iterable']
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

Future<Map<String, dynamic>> _$GraphqlRuntimeAssociationDefinitionToGraphql(
  GraphqlRuntimeAssociationDefinition instance, {
  required GraphqlProvider provider,
  GraphqlFirstRepository? repository,
}) async {
  return {
    'nonIterable': await AssocAdapter().toGraphql(
      instance.nonIterable,
      provider: provider,
      repository: repository,
    ),
    'iterable': await Future.wait<Map<String, dynamic>>(
      instance.iterable
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

/// Construct a [GraphqlRuntimeAssociationDefinition]
class GraphqlRuntimeAssociationDefinitionAdapter
    extends GraphqlFirstAdapter<GraphqlRuntimeAssociationDefinition> {
  GraphqlRuntimeAssociationDefinitionAdapter();

  @override
  final fieldsToGraphqlRuntimeDefinition = <String, RuntimeGraphqlDefinition>{
    'nonIterable': const RuntimeGraphqlDefinition(
      association: true,
      documentNodeName: 'nonIterable',
      iterable: false,
      subfields: <String, Map<String, dynamic>>{},
      type: Assoc,
    ),
    'iterable': const RuntimeGraphqlDefinition(
      association: true,
      documentNodeName: 'iterable',
      iterable: true,
      subfields: <String, Map<String, dynamic>>{},
      type: Assoc,
    ),
  };

  @override
  Future<GraphqlRuntimeAssociationDefinition> fromGraphql(
    Map<String, dynamic> input, {
    required provider,
    covariant GraphqlFirstRepository? repository,
  }) async => await _$GraphqlRuntimeAssociationDefinitionFromGraphql(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toGraphql(
    GraphqlRuntimeAssociationDefinition input, {
    required provider,
    covariant GraphqlFirstRepository? repository,
  }) async => await _$GraphqlRuntimeAssociationDefinitionToGraphql(
    input,
    provider: provider,
    repository: repository,
  );
}
''';

/// Output serializing code for all models with the @[GraphqlSerializable] annotation.
/// [GraphqlSerializable] **does not** produce code.
/// A `const` class is required from an non-relative import,
/// and [GraphqlSerializable] was arbitrarily chosen for this test.
/// This will do nothing outside of this exact test suite.
@GraphqlSerializable()
class GraphqlRuntimeAssociationDefinition extends GraphqlModel {
  final Assoc nonIterable;

  final List<Assoc> iterable;

  GraphqlRuntimeAssociationDefinition({
    required this.nonIterable,
    required this.iterable,
  });
}

class Assoc extends GraphqlModel {
  final String someField;

  Assoc(this.someField);
}
