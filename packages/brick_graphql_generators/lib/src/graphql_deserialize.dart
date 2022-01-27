import 'package:analyzer/dart/element/element.dart';
import 'package:brick_graphql/graphql.dart';
import 'package:brick_graphql_generators/src/graphql_fields.dart';
import 'package:brick_graphql_generators/src/graphql_serdes_generator.dart';
import 'package:brick_rest_generators/generators.dart' show JsonDeserialize;

/// Generate a function to produce a [ClassElement] from GraphQL data
class GraphqlDeserialize extends GraphqlSerdesGenerator
    with JsonDeserialize<GraphqlModel, Graphql> {
  /// Requires `import 'package:gql/language.dart' as lang` to be listed
  /// within `requiredImports` on the `AggregateBuilder`
  @override
  List<String> get instanceFieldsAndMethods {
    final config = (fields as GraphqlFields).config;
    final deleteHeader = config?.defaultDeleteOperation?.trim();
    final getCollectionHeader = config?.defaultGetOperation?.trim();
    final getMemberHeader = config?.defaultGetFilteredOperation?.trim();
    final upsertHeader = config?.defaultUpsertOperation?.trim();

    return [
      "@override\nfinal defaultDeleteOperation = lang.parseString(r'''$deleteHeader''')",
      "@override\nfinal defaultGetOperation = lang.parseString(r'''$getCollectionHeader''')",
      "@override\nfinal defaultGetFilteredOperation = lang.parseString(r'''$getMemberHeader''')",
      "@override\nfinal defaultUpsertOperation = lang.parseString(r'''$upsertHeader''')",
    ];
  }

  GraphqlDeserialize(
    ClassElement element,
    GraphqlFields fields, {
    required String repositoryName,
  }) : super(element, fields, repositoryName: repositoryName);
}
