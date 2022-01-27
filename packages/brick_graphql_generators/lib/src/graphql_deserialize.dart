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
    final deleteHeader = config?.defaultDeleteOperation;
    final getCollectionHeader = config?.defaultGetOperation;
    final getMemberHeader = config?.defaultGetFilteredOperation;
    final getSubscribeHeader = config?.defaultSubscriptionOperation;
    final getSubscribeFilteredHeader = config?.defaultSubscriptionFilteredOperation;
    final upsertHeader = config?.defaultUpsertOperation;

    return [
      if (deleteHeader != null)
        "@override\nfinal defaultDeleteOperation = lang.parseString(r'''$deleteHeader''');",
      if (getCollectionHeader != null)
        "@override\nfinal defaultGetOperation = lang.parseString(r'''$getCollectionHeader''');",
      if (getMemberHeader != null)
        "@override\nfinal defaultGetFilteredOperation = lang.parseString(r'''$getMemberHeader''');",
      if (getSubscribeHeader != null)
        "@override\nfinal defaultSubscriptionOperation = lang.parseString(r'''$getSubscribeHeader''');",
      if (getSubscribeFilteredHeader != null)
        "@override\nfinal defaultSubscriptionFilteredOperation = lang.parseString(r'''$getSubscribeFilteredHeader''');",
      if (upsertHeader != null)
        "@override\nfinal defaultUpsertOperation = lang.parseString(r'''$upsertHeader''');",
    ];
  }

  GraphqlDeserialize(
    ClassElement element,
    GraphqlFields fields, {
    required String repositoryName,
  }) : super(element, fields, repositoryName: repositoryName);
}
