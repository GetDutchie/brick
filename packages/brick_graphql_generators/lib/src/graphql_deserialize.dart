import 'package:analyzer/dart/element/element.dart';
import 'package:brick_graphql_generators/src/graphql_fields.dart';
import 'package:brick_rest_generators/generators.dart';

/// Generate a function to produce a [ClassElement] from GraphQL data
class GraphQLDeserialize extends RestDeserialize {
  @override
  // ignore: overridden_fields
  final providerName = 'GraphQL';

  GraphQLDeserialize(
    ClassElement element,
    GraphQLFields fields, {
    required String repositoryName,
  }) : super(element, fields, repositoryName: repositoryName);
}
