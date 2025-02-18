import 'package:brick_core/core.dart';
import 'package:brick_graphql/src/graphql_adapter.dart';
import 'package:brick_graphql/src/graphql_model.dart';
import 'package:brick_graphql/src/graphql_model_dictionary.dart';
import 'package:brick_graphql/src/graphql_provider.dart';
import 'package:brick_graphql/src/graphql_provider_query.dart';
import 'package:brick_graphql/src/runtime_graphql_definition.dart';
import 'package:brick_graphql/src/transformers/graphql_argument.dart';
import 'package:brick_graphql/src/transformers/graphql_variable.dart';
import 'package:gql/ast.dart';
import 'package:gql/language.dart' as lang;

/// Convert a [Query] to a [DocumentNode] and variables.
/// This class also interprets associations from adapters and model definitions.
class ModelFieldsDocumentTransformer<TModel extends GraphqlModel> {
  /// Data that holds generated variables available at runtime, such as field names.
  final GraphqlAdapter adapter;

  /// Generates a document based on the [GraphqlAdapter#fieldsToGraphqlRuntimeDefinition]
  DocumentNode get document {
    final node = sourceDocument.definitions.first as OperationDefinitionNode;
    if (hasSubfields) return sourceDocument;

    final arguments = GraphqlArgument.fromOperationNode(node);

    /// The `upsertPerson` in
    /// ```graphql
    /// mutation UpsertPerson($input: UpsertPersonInput!) {
    ///  upsertPerson(input: $input) {
    /// ```
    final operationFunctionName = (node.selectionSet.selections.first as FieldNode).name.value;

    /// The name following `query` or `mutation` (e.g. `mutation UpsertPerson`)
    final operationNameNode = node.name?.value ?? TModel.toString();
    final variables = GraphqlVariable.fromOperationNode(node);

    return DocumentNode(
      definitions: [
        OperationDefinitionNode(
          type: node.type,
          name: NameNode(value: operationNameNode),
          variableDefinitions: [
            for (final variable in variables)
              VariableDefinitionNode(
                variable: VariableNode(name: NameNode(value: variable.name)),
                type: NamedTypeNode(
                  name: NameNode(value: variable.className),
                  isNonNull: !variable.nullable,
                ),
                defaultValue: const DefaultValueNode(value: null),
              ),
          ],
          selectionSet: SelectionSetNode(
            selections: [
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
                    ignoreAssociations: node.type == OperationType.mutation,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Returns `true` if the operation has subfields
  bool get hasSubfields {
    final node = sourceDocument.definitions.first as OperationDefinitionNode;
    return (node.selectionSet.selections.first as FieldNode).selectionSet?.selections.isNotEmpty ??
        false;
  }

  /// A map of all other adapters within the GraphQL domain.
  final GraphqlModelDictionary modelDictionary;

  /// The top-level operation name.
  String? get operationName {
    final node = sourceDocument.definitions.first as OperationDefinitionNode;
    if (hasSubfields) return null;
    return (node.selectionSet.selections.first as FieldNode).name.value;
  }

  /// The GraphQL document that was passed to the transformer.
  final DocumentNode sourceDocument;

  /// Convert an adapter's `#fieldsToGraphqlRuntimeDefinition` to a
  /// GraphQL document
  ModelFieldsDocumentTransformer({
    required this.modelDictionary,
    required DocumentNode document,
  })  : adapter = modelDictionary.adapterFor[TModel]!,
        sourceDocument = document;

  /// Recursively request nodes from GraphQL as well as any deeply-nested associations.
  ///
  /// [ignoreAssociations] returns only the immediate models
  List<SelectionNode> _generateNodes(
    Map<String, RuntimeGraphqlDefinition> fieldsToGraphqlRuntimeDefinition, {
    bool ignoreAssociations = false,
  }) =>
      fieldsToGraphqlRuntimeDefinition.entries.fold<List<SelectionNode>>([], (nodes, entry) {
        nodes.add(
          FieldNode(
            name: NameNode(value: entry.value.documentNodeName),
            selectionSet: entry.value.association && !ignoreAssociations
                ? SelectionSetNode(
                    selections: _generateNodes(
                      modelDictionary
                          .adapterFor[entry.value.type]!.fieldsToGraphqlRuntimeDefinition,
                    ),
                  )
                : entry.value.subfields.isNotEmpty
                    ? _generateSubFields(entry.value.subfields)
                    : null,
          ),
        );

        return nodes;
      });

  SelectionSetNode _generateSubFields(Map<String, dynamic> subfields) => SelectionSetNode(
        selections: subfields.entries.fold<List<SelectionNode>>(<SelectionNode>[], (acc, entry) {
          acc.add(
            FieldNode(
              name: NameNode(value: entry.key),
              selectionSet: entry.value.isEmpty ? null : _generateSubFields(entry.value),
            ),
          );

          return acc;
        }),
      );

  /// Merge the operation headers from [document] and the generated `#document` nodes.
  static ModelFieldsDocumentTransformer<TModel> fromDocument<TModel extends GraphqlModel>(
    DocumentNode document,
    GraphqlModelDictionary modelDictionary,
  ) =>
      ModelFieldsDocumentTransformer<TModel>(
        document: document,
        modelDictionary: modelDictionary,
      );

  /// Instead of a [DocumentNode], the raw document is used.
  /// Only the operation information is retrieved from the supplied document;
  /// field nodes are ignored.
  static ModelFieldsDocumentTransformer<TModel> fromString<TModel extends GraphqlModel>(
    String existingOperation,
    GraphqlModelDictionary modelDictionary,
  ) =>
      fromDocument<TModel>(lang.parseString(existingOperation), modelDictionary);

  /// Assign and determine what operation to make against the request
  static ModelFieldsDocumentTransformer<TModel>? defaultOperation<TModel extends GraphqlModel>(
    GraphqlModelDictionary modelDictionary, {
    required QueryAction action,
    TModel? instance,
    Query? query,
  }) {
    final operation = (query?.providerQueries[GraphqlProvider] as GraphqlProviderQuery?)?.operation;
    if (operation?.document != null) {
      return fromString<TModel>(operation!.document!, modelDictionary);
    }

    final adapter = modelDictionary.adapterFor[TModel]!;
    final operationTransformer = adapter.queryOperationTransformer == null
        ? null
        : adapter.queryOperationTransformer!(query, instance);

    switch (action) {
      case QueryAction.get:
        if (operationTransformer?.get?.document != null) {
          return fromDocument<TModel>(
            lang.parseString(operationTransformer!.get!.document!),
            modelDictionary,
          );
        }
        return null;
      case QueryAction.insert:
      case QueryAction.update:
      case QueryAction.upsert:
        if (operationTransformer?.upsert?.document != null) {
          return fromDocument<TModel>(
            lang.parseString(operationTransformer!.upsert!.document!),
            modelDictionary,
          );
        }
        return null;
      case QueryAction.delete:
        if (operationTransformer?.delete?.document != null) {
          return fromDocument<TModel>(
            lang.parseString(operationTransformer!.delete!.document!),
            modelDictionary,
          );
        }
        return null;
      case QueryAction.subscribe:
        if (operationTransformer?.subscribe?.document != null) {
          return fromDocument<TModel>(
            lang.parseString(operationTransformer!.subscribe!.document!),
            modelDictionary,
          );
        }
        return null;
    }
  }
}
