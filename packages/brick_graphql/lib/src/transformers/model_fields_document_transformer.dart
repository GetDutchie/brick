import 'package:brick_core/core.dart';
import 'package:brick_graphql/src/graphql_adapter.dart';
import 'package:brick_graphql/src/graphql_model.dart';
import 'package:brick_graphql/src/graphql_model_dictionary.dart';
import 'package:brick_graphql/src/runtime_graphql_definition.dart';
import 'package:brick_graphql/src/transformers/graphql_argument.dart';
import 'package:brick_graphql/src/transformers/graphql_variable.dart';
import 'package:gql/ast.dart';
import 'package:gql/language.dart' as lang;

class ModelFieldsDocumentTransformer<_Model extends GraphqlModel> {
  final GraphqlAdapter adapter;

  final List<GraphqlArgument> arguments;

  /// Generates a document based on the [GraphqlAdapter#fieldsToGraphqlRuntimeDefinition]
  DocumentNode get document {
    return DocumentNode(
      definitions: [
        OperationDefinitionNode(
          type: operationType,
          name: NameNode(value: operationNameNode),
          variableDefinitions: [
            for (final variable in variables)
              VariableDefinitionNode(
                variable: VariableNode(name: NameNode(value: variable.name)),
                type: NamedTypeNode(
                  name: NameNode(value: variable.className),
                  isNonNull: !variable.nullable,
                ),
                defaultValue: DefaultValueNode(value: null),
                directives: [],
              ),
          ],
          directives: [],
          selectionSet: SelectionSetNode(selections: [
            FieldNode(
              name: NameNode(value: operationFunctionName),
              arguments: [
                for (final argument in arguments)
                  ArgumentNode(
                    name: NameNode(value: argument.name),
                    value: VariableNode(
                      name: NameNode(value: argument.variable.name),
                    ),
                  ),
              ],
              selectionSet: SelectionSetNode(
                selections: _generateNodes(
                  adapter.fieldsToGraphqlRuntimeDefinition,
                  ignoreAssociations: operationType == OperationType.mutation,
                ),
              ),
            ),
          ]),
        ),
      ],
    );
  }

  final GraphqlModelDictionary modelDictionary;

  /// The `upsertPerson` in
  /// ```graphql
  /// mutation UpsertPerson($input: UpsertPersonInput!) {
  ///  upsertPerson(input: $input) {
  /// ```
  final String operationFunctionName;

  /// The name following `query` or `mutation` (e.g. `mutation UpsertPerson`)
  final String operationNameNode;

  /// Defaults to [OperationType.query]
  final OperationType operationType;

  /// Defaults to `[]`
  final List<GraphqlVariable> variables;

  /// Convert an adapter's `#fieldsToGraphqlRuntimeDefinition` to a
  /// GraphQL document
  ModelFieldsDocumentTransformer({
    List<GraphqlArgument>? arguments,
    required this.modelDictionary,
    required this.operationFunctionName,
    String? operationNameNode,
    OperationType? operationType,
    List<GraphqlVariable>? variables,
  })  : adapter = modelDictionary.adapterFor[_Model]!,
        arguments = arguments ?? [],
        operationNameNode = operationNameNode ?? _Model.toString(),
        operationType = operationType ?? OperationType.query,
        variables = variables ?? [];

  /// Recursively request nodes from GraphQL as well as any deeply-nested associations.
  ///
  /// [ignoreAssociations] returns only the immediate models
  List<SelectionNode> _generateNodes(
    Map<String, RuntimeGraphqlDefinition> fieldsToGraphqlRuntimeDefinition, {
    bool ignoreAssociations = false,
  }) {
    return fieldsToGraphqlRuntimeDefinition.entries.fold<List<SelectionNode>>([], (nodes, entry) {
      nodes.add(FieldNode(
        name: NameNode(value: entry.key),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: entry.value.association && !ignoreAssociations
            ? SelectionSetNode(
                selections: _generateNodes(
                  modelDictionary.adapterFor[entry.value.type]!.fieldsToGraphqlRuntimeDefinition,
                ),
              )
            : null,
      ));

      return nodes;
    });
  }

  /// Merge the operation headers from [document] and the generated `#document` nodes.
  static ModelFieldsDocumentTransformer concat<_Model extends GraphqlModel>(
    DocumentNode document,
    GraphqlModelDictionary modelDictionary,
  ) {
    final node = document.definitions.first as OperationDefinitionNode;
    return ModelFieldsDocumentTransformer<_Model>(
      arguments: GraphqlArgument.fromOperationNode(node),
      modelDictionary: modelDictionary,
      operationFunctionName: (node.selectionSet.selections.first as FieldNode).name.value,
      operationNameNode: node.name?.value,
      operationType: node.type,
      variables: GraphqlVariable.fromOperationNode(node),
    );
  }

  /// Instead of a [DocumentNode], the raw document is used.
  /// Only the operation information is retrieved from the supplied document;
  /// field nodes are ignored.
  static ModelFieldsDocumentTransformer concatFromString<_Model extends GraphqlModel>(
    String existingOperation,
    GraphqlModelDictionary modelDictionary,
  ) =>
      concat<_Model>(lang.parseString(existingOperation), modelDictionary);

  /// Assign and determine what operation to make against the request
  static ModelFieldsDocumentTransformer defaultOperation<_Model extends GraphqlModel>(
    GraphqlModelDictionary modelDictionary, {
    required QueryAction action,
    Query? query,
  }) {
    if (query?.providerArgs['document'] != null) {
      return concatFromString<_Model>(query!.providerArgs['document'], modelDictionary);
    }

    final adapter = modelDictionary.adapterFor[_Model]!;
    if (action == QueryAction.delete && adapter.defaultDeleteOperation != null) {
      return concat<_Model>(adapter.defaultDeleteOperation!, modelDictionary);
    }

    if (action == QueryAction.upsert && adapter.defaultUpsertOperation != null) {
      return concat<_Model>(adapter.defaultUpsertOperation!, modelDictionary);
    }

    if (action == QueryAction.subscribe) {
      if (query?.where == null && adapter.defaultSubscriptionOperation != null) {
        return concat<_Model>(adapter.defaultSubscriptionOperation!, modelDictionary);
      }

      if (adapter.defaultSubscriptionFilteredOperation != null) {
        return concat<_Model>(adapter.defaultSubscriptionFilteredOperation!, modelDictionary);
      }
    }

    if (query?.where == null && adapter.defaultQueryOperation != null) {
      return concat<_Model>(adapter.defaultQueryOperation!, modelDictionary);
    }

    if (adapter.defaultQueryFilteredOperation != null) {
      return concat<_Model>(adapter.defaultQueryFilteredOperation!, modelDictionary);
    }

    throw ArgumentError('No GraphQL document specified or inferrred');
  }
}
