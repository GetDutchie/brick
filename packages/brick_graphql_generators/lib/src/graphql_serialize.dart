import 'package:analyzer/dart/element/element.dart';
import 'package:brick_graphql/graphql.dart';
import 'package:brick_graphql_generators/src/graphql_fields.dart';
import 'package:brick_graphql_generators/src/graphql_serdes_generator.dart';
import 'package:brick_rest_generators/generators.dart' show JsonSerialize;

/// Generate a function to produce a [ClassElement] from GraphQL data
class GraphQLSerialize extends GraphQLSerdesGenerator with JsonSerialize<GraphQLModel, GraphQL> {
  GraphQLSerialize(
    ClassElement element,
    GraphQLFields fields, {
    required String repositoryName,
  }) : super(element, fields, repositoryName: repositoryName);
}
