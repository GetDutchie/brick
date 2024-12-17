import 'package:brick_graphql/brick_graphql.dart';
import 'package:brick_graphql_generators/src/graphql_fields.dart';
import 'package:brick_json_generators/json_serdes_generator.dart';

///
abstract class GraphqlSerdesGenerator extends JsonSerdesGenerator<GraphqlModel, Graphql> {
  ///
  GraphqlSerdesGenerator(
    super.element,
    GraphqlFields super.fields, {
    required super.repositoryName,
  }) : super(
          providerName: 'Graphql',
        );
}
