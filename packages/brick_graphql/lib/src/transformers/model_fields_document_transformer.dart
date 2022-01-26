import 'package:brick_graphql/graphql.dart';
import 'package:brick_graphql/src/runtime_graphql_definition.dart';
import 'package:brick_graphql/src/transformers/graphql_argument.dart';
import 'package:brick_graphql/src/transformers/graphql_variable.dart';
import 'package:gql/ast.dart';

class ModelFieldsDocumentTransformer<_Model extends GraphqlModel> {
  final GraphqlAdapter adapter;

  final List<GraphqlArgument> arguments;

  /// Generates a document based on the [GraphqlAdapter#fieldsToRuntimeDefinition]
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
                  adapter.fieldsToRuntimeDefinition,
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

  /// Convert an adapter's `#fieldsToRuntimeDefinition` to a
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
    Map<String, RuntimeGraphqlDefinition> fieldsToRuntimeDefinition, {
    bool ignoreAssociations = false,
  }) {
    return fieldsToRuntimeDefinition.entries.fold<List<SelectionNode>>([], (nodes, entry) {
      nodes.add(FieldNode(
        name: NameNode(value: entry.key),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: entry.value.association && !ignoreAssociations
            ? SelectionSetNode(
                selections: _generateNodes(
                  modelDictionary.adapterFor[entry.value.runtimeType]!.fieldsToRuntimeDefinition,
                ),
              )
            : null,
      ));

      return nodes;
    });
  }
}
