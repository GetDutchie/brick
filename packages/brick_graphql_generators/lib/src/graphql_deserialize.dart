import 'package:analyzer/dart/element/element.dart';
import 'package:brick_graphql/graphql.dart';
import 'package:brick_graphql_generators/src/graphql_fields.dart';
import 'package:brick_graphql_generators/src/graphql_serdes_generator.dart';
import 'package:brick_rest_generators/generators.dart' show JsonDeserialize;

/// Generate a function to produce a [ClassElement] from GraphQL data
class GraphQLDeserialize extends GraphQLSerdesGenerator
    with JsonDeserialize<GraphQLModel, GraphQL> {
  @override
  // ignore: overridden_fields
  final providerName = 'GraphQL';

  GraphQLDeserialize(
    ClassElement element,
    GraphQLFields fields, {
    required String repositoryName,
  }) : super(element, fields, repositoryName: repositoryName);
}
