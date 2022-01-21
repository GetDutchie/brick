import 'package:brick_graphql/graphql.dart';
import 'package:brick_core/core.dart';
import 'package:brick_graphql/src/runtime_graphql_definition.dart';
import 'package:gql/ast.dart';

class QueryDocumentTransformer<_Model extends GraphqlModel> {
  final GraphQLAdapter adapter;

  final GraphQLModelDictionary modelDictionary;

  /// Defaults to [OperationType.query]
  final OperationType operationType;

  final Query? query;

  /// Generates a document from all unignored properties on the model.
  DocumentNode get defaultFetchQueryDocument {
    return DocumentNode(
      definitions: [
        OperationDefinitionNode(
          type: operationType,
          name: NameNode(value: _Model.toString()),
          variableDefinitions: [],
          directives: [],
          selectionSet: SelectionSetNode(selections: _generateNodes(adapter.fieldsToDocumentNodes)),
        )
      ],
    );
  }

  /// Generates a document based on the [query]
  DocumentNode get document {
    return DocumentNode(
      definitions: [
        OperationDefinitionNode(
          type: operationType,
          name: NameNode(value: _Model.toString()),
          variableDefinitions: [VariableDefinitionNode(variable: VariableNode(name: ), type: type)],
          directives: [],
          selectionSet: SelectionSetNode(
            selections: _generateNodes(
              adapter.fieldsToDocumentNodes,
              ignoreAssociations: operationType == OperationType.mutation,
            ),
          ),
        )
      ],
    );
  }

  QueryDocumentTransformer(
    this.query, {
    required this.modelDictionary,
    OperationType? operationType,
  })  : adapter = modelDictionary.adapterFor[_Model]!,
        operationType = operationType ?? OperationType.query;

  /// Recursively request nodes from GraphQL as well as any deeply-nested associations.
  ///
  /// [ignoreAssociations] returns only the immediate models
  List<SelectionNode> _generateNodes(
    Map<String, RuntimeGraphqlDefinition> fieldsToDocumentNodes, {
    bool ignoreAssociations = false,
  }) {
    return fieldsToDocumentNodes.entries.fold<List<SelectionNode>>([], (nodes, entry) {
      nodes.add(FieldNode(
        name: NameNode(value: entry.key),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: entry.value.association && !ignoreAssociations
            ? SelectionSetNode(
                selections: _generateNodes(
                  modelDictionary.adapterFor[entry.value.runtimeType]!.fieldsToDocumentNodes,
                ),
              )
            : null,
      ));

      return nodes;
    });
  }
}
