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
    final deleteHeader = config?.defaultDeleteOperationHeader?.trim();
    final getCollectionHeader = config?.defaultGetCollectionOperationHeader?.trim();
    final getMemberHeader = config?.defaultGetMemberOperationHeader?.trim();
    final upsertHeader = config?.defaultUpsertOperationHeader?.trim();

    return [
      "@override\nfinal defaultDeleteOperation = lang.parseString('''$deleteHeader''')",
      "@override\nfinal defaultGetCollectionOperation = lang.parseString('''$getCollectionHeader''')",
      "@override\nfinal defaultGetMemberOperation = lang.parseString('''$getMemberHeader''')",
      "@override\nfinal defaultUpsertOperation = lang.parseString('''$upsertHeader''')",
    ];
  }

  GraphqlDeserialize(
    ClassElement element,
    GraphqlFields fields, {
    required String repositoryName,
  }) : super(element, fields, repositoryName: repositoryName);
}
