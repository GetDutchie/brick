import 'package:brick_graphql/graphql.dart';
import 'package:brick_core/core.dart';
import 'package:brick_graphql/src/runtime_graphql_definition.dart';
import 'package:gql/ast.dart';

class QueryDocumentTransformer<_Model extends GraphqlModel> {
  final GraphQLAdapter adapter;

  final List<GraphqlArgument> arguments;

  /// Generates a document based on the [query]
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
                  adapter.fieldsToDocumentNodes,
                  ignoreAssociations: operationType == OperationType.mutation,
                ),
              ),
            ),
          ]),
        ),
      ],
    );
  }

  final GraphQLModelDictionary modelDictionary;

  /// The `updateJournalEntry` in
  /// ```graphql
  /// mutation UpdateJournalEntry($input: UpdateJournalEntryInput!) {
  ///  updateJournalEntry(input: $input) {
  /// ```
  final String operationFunctionName;

  /// The name following `query` or `mutation` (e.g. `mutation UpsertPerson`)
  final String operationNameNode;

  /// Defaults to [OperationType.query]
  final OperationType operationType;

  final Query? query;

  /// Defaults to `[]`
  final List<GraphqlVariable> variables;

  QueryDocumentTransformer(
    this.query, {
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

class GraphqlArgument {
  final String name;

  final GraphqlVariable variable;

  const GraphqlArgument({
    required this.name,
    required this.variable,
  });
}

class GraphqlVariable {
  /// The `UpdatePersonInput` in `mutation UpdatePerson($input: UpdatePersonInput)`
  final String className;

  /// The `input` in `mutation UpdatePerson($input: UpdatePersonInput)`
  final String name;

  /// A `!` in `mutation UpdatePerson($input: UpdatePersonInput!)` indicates that the
  /// input value cannot be nullable.
  /// Defaults `false`.
  final bool nullable;

  const GraphqlVariable({
    required this.className,
    required this.name,
    this.nullable = false,
  });
}
