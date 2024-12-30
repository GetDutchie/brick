import 'package:gql/ast.dart';

/// An internal class to help transform operations
class GraphqlVariable {
  /// The `UpdatePersonInput` in `mutation UpdatePerson($input: UpdatePersonInput)`
  final String className;

  /// The `input` in `mutation UpdatePerson($input: UpdatePersonInput)`
  final String name;

  /// A `!` in `mutation UpdatePerson($input: UpdatePersonInput!)` indicates that the
  /// input value cannot be nullable.
  /// Defaults `false`.
  final bool nullable;

  /// An internal class to help transform operations
  const GraphqlVariable({
    required this.className,
    required this.name,
    this.nullable = false,
  });

  /// Convert a [VariableDefinitionNode] to a [GraphqlVariable]
  factory GraphqlVariable.fromVariableDefinitionNode(VariableDefinitionNode node) =>
      GraphqlVariable(
        className: (node.type as NamedTypeNode).name.value,
        name: node.variable.name.value,
      );

  /// Convert an [OperationDefinitionNode] to a list of [GraphqlVariable]
  static List<GraphqlVariable> fromOperationNode(OperationDefinitionNode node) =>
      node.variableDefinitions
          .map(GraphqlVariable.fromVariableDefinitionNode)
          .toList()
          .cast<GraphqlVariable>();
}
