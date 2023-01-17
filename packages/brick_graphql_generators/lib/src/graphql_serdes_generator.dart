import 'package:analyzer/dart/element/element.dart';
import 'package:brick_graphql/brick_graphql.dart';
import 'package:brick_graphql_generators/src/graphql_fields.dart';
import 'package:brick_json_generators/json_serdes_generator.dart';

abstract class GraphqlSerdesGenerator extends JsonSerdesGenerator<GraphqlModel, Graphql> {
  GraphqlSerdesGenerator(
    ClassElement element,
    GraphqlFields fields, {
    required String repositoryName,
  }) : super(
          element,
          fields,
          providerName: 'Graphql',
          repositoryName: repositoryName,
        );
}
