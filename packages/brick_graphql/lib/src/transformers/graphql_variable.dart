import 'package:gql/ast.dart';

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

  factory GraphqlVariable.fromVariableDefinitionNode(VariableDefinitionNode node) {
    return GraphqlVariable(
      className: (node.type as NamedTypeNode).name.value,
      name: node.variable.name.value,
    );
  }

  static List<GraphqlVariable> fromOperationNode(OperationDefinitionNode node) {
    return node.variableDefinitions
        .map((v) => GraphqlVariable.fromVariableDefinitionNode(v))
        .toList()
        .cast<GraphqlVariable>();
  }
}
