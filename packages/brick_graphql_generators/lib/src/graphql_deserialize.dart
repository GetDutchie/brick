import 'package:analyzer/dart/element/element.dart';
import 'package:brick_graphql/graphql.dart';
import 'package:brick_graphql_generators/src/graphql_fields.dart';
import 'package:brick_graphql_generators/src/graphql_serdes_generator.dart';
import 'package:brick_rest_generators/generators.dart' show JsonDeserialize;

/// Generate a function to produce a [ClassElement] from GraphQL data
class GraphqlDeserialize extends GraphqlSerdesGenerator
    with JsonDeserialize<GraphqlModel, Graphql> {
  @override
  // ignore: overridden_fields
  final providerName = 'GraphQL';

  GraphqlDeserialize(
    ClassElement element,
    GraphqlFields fields, {
    required String repositoryName,
  }) : super(element, fields, repositoryName: repositoryName);
}
