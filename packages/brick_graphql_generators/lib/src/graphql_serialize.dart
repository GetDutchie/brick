import 'package:analyzer/dart/element/element.dart';
import 'package:brick_graphql_generators/src/graphql_fields.dart';
import 'package:brick_rest/rest.dart';
import 'package:brick_rest_generators/generators.dart';

/// Generate a function to produce a [ClassElement] to REST data
class GraphQLSerialize<_Model extends RestModel> extends RestSerialize {
  @override
  final providerName = 'GraphQL';

  GraphQLSerialize(
    ClassElement element,
    GraphQLFields fields, {
    required String repositoryName,
  }) : super(element, fields, repositoryName: repositoryName);
}
