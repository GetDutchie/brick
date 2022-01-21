import 'package:analyzer/dart/element/element.dart';
import 'package:brick_graphql/graphql.dart';
import 'package:brick_graphql_generators/src/graphql_fields.dart';
import 'package:brick_rest_generators/generators.dart' show JsonSerdesGenerator;

abstract class GraphqlSerdesGenerator extends JsonSerdesGenerator<GraphqlModel, GraphQL> {
  GraphqlSerdesGenerator(
    ClassElement element,
    GraphqlFields fields, {
    required String repositoryName,
  }) : super(
          element,
          fields,
          providerName: 'GraphQL',
          repositoryName: repositoryName,
        );
}
