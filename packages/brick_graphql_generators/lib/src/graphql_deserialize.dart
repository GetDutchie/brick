import 'package:analyzer/dart/element/element.dart';
import 'package:brick_graphql/brick_graphql.dart';
import 'package:brick_graphql_generators/src/graphql_fields.dart';
import 'package:brick_graphql_generators/src/graphql_serdes_generator.dart';
import 'package:brick_json_generators/json_deserialize.dart';

/// Generate a function to produce a [ClassElement] from GraphQL data
class GraphqlDeserialize extends GraphqlSerdesGenerator
    with JsonDeserialize<GraphqlModel, Graphql> {
  /// Requires `import 'package:gql/language.dart' as lang` to be listed
  /// within `requiredImports` on the `AggregateBuilder`
  @override
  List<String> get instanceFieldsAndMethods {
    final config = (fields as GraphqlFields).config;

    return [
      if (config?.queryOperationTransformerName != null)
        '@override\nfinal queryOperationTransformer = ${config!.queryOperationTransformerName};',
    ];
  }

  /// Generate a function to produce a [ClassElement] from GraphQL data
  GraphqlDeserialize(
    super.element,
    super.fields, {
    required super.repositoryName,
  });
}
