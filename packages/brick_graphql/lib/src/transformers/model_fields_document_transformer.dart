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

  /// Generates a document based on the [GraphqlAdapter#fieldsToGraphqlRuntimeDefinition]
  DocumentNode get document {
    final node = sourceDocument.definitions.first as OperationDefinitionNode;
    final hasSubfields =
        (node.selectionSet.selections.first as FieldNode).selectionSet?.selections.isNotEmpty ??
            false;
    if (hasSubfields) return sourceDocument;

    final arguments = GraphqlArgument.fromOperationNode(node);

    /// The `upsertPerson` in
    /// ```graphql
    /// mutation UpsertPerson($input: UpsertPersonInput!) {
    ///  upsertPerson(input: $input) {
    /// ```
    final operationFunctionName = (node.selectionSet.selections.first as FieldNode).name.value;

    /// The name following `query` or `mutation` (e.g. `mutation UpsertPerson`)
    final operationNameNode = node.name?.value ?? _Model.toString();
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
                  ignoreAssociations: node.type == OperationType.mutation,
                ),
              ),
            ),
          ]),
        ),
      ],
    );
  }

  final GraphqlModelDictionary modelDictionary;

  final DocumentNode sourceDocument;

  /// Convert an adapter's `#fieldsToGraphqlRuntimeDefinition` to a
  /// GraphQL document
  ModelFieldsDocumentTransformer({
    required this.modelDictionary,
    required DocumentNode document,
  })  : adapter = modelDictionary.adapterFor[_Model]!,
        sourceDocument = document;

  /// Recursively request nodes from GraphQL as well as any deeply-nested associations.
  ///
  /// [ignoreAssociations] returns only the immediate models
  List<SelectionNode> _generateNodes(
    Map<String, RuntimeGraphqlDefinition> fieldsToGraphqlRuntimeDefinition, {
    bool ignoreAssociations = false,
  }) {
    return fieldsToGraphqlRuntimeDefinition.entries.fold<List<SelectionNode>>([], (nodes, entry) {
      nodes.add(FieldNode(
        name: NameNode(value: entry.value.documentNodeName),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: entry.value.association && !ignoreAssociations
            ? SelectionSetNode(
                selections: _generateNodes(
                  modelDictionary.adapterFor[entry.value.type]!.fieldsToGraphqlRuntimeDefinition,
                ),
              )
            : entry.value.subfields.isNotEmpty
                ? _generateSubFields(entry.value.subfields)
                : null,
      ));

      return nodes;
    });
  }

  SelectionSetNode _generateSubFields(Map<String, dynamic> subfields) {
    return SelectionSetNode(
      selections: subfields.entries.fold<List<SelectionNode>>(<SelectionNode>[], (acc, entry) {
        acc.add(FieldNode(
          name: NameNode(value: entry.key),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: entry.value.isEmpty ? null : _generateSubFields(entry.value),
        ));

        return acc;
      }),
    );
  }

  /// Merge the operation headers from [document] and the generated `#document` nodes.
  static ModelFieldsDocumentTransformer<_Model> fromDocument<_Model extends GraphqlModel>(
    DocumentNode document,
    GraphqlModelDictionary modelDictionary,
  ) {
    return ModelFieldsDocumentTransformer<_Model>(
      document: document,
      modelDictionary: modelDictionary,
    );
  }

  /// Instead of a [DocumentNode], the raw document is used.
  /// Only the operation information is retrieved from the supplied document;
  /// field nodes are ignored.
  static ModelFieldsDocumentTransformer<_Model> fromString<_Model extends GraphqlModel>(
    String existingOperation,
    GraphqlModelDictionary modelDictionary,
  ) =>
      fromDocument<_Model>(lang.parseString(existingOperation), modelDictionary);

  /// Assign and determine what operation to make against the request
  static ModelFieldsDocumentTransformer<_Model>? defaultOperation<_Model extends GraphqlModel>(
    GraphqlModelDictionary modelDictionary, {
    required QueryAction action,
    _Model? instance,
    Query? query,
  }) {
    if (query?.providerArgs['document'] != null) {
      return fromString<_Model>(query!.providerArgs['document'], modelDictionary);
    }

    final adapter = modelDictionary.adapterFor[_Model]!;
    final operationTransformer = adapter.queryOperationTransformer == null
        ? null
        : adapter.queryOperationTransformer!(query, instance);

    switch (action) {
      case QueryAction.get:
        if (operationTransformer?.get?.document != null) {
          return fromDocument<_Model>(
            lang.parseString(operationTransformer!.get!.document!),
            modelDictionary,
          );
        }
        return null;
      case QueryAction.insert:
      case QueryAction.update:
      case QueryAction.upsert:
        if (operationTransformer?.upsert?.document != null) {
          return fromDocument<_Model>(
            lang.parseString(operationTransformer!.upsert!.document!),
            modelDictionary,
          );
        }
        return null;
      case QueryAction.delete:
        if (operationTransformer?.delete?.document != null) {
          return fromDocument<_Model>(
            lang.parseString(operationTransformer!.delete!.document!),
            modelDictionary,
          );
        }
        return null;
      case QueryAction.subscribe:
        if (operationTransformer?.subscribe?.document != null) {
          return fromDocument<_Model>(
            lang.parseString(operationTransformer!.subscribe!.document!),
            modelDictionary,
          );
        }
        return null;
    }
  }
}
