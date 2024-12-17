import 'package:brick_graphql/src/transformers/graphql_variable.dart';
import 'package:gql/ast.dart';

/// An internal class to help transform operations
class GraphqlArgument {
  /// The name of the argument
  final String name;

  /// The variable associated with the argument
  final GraphqlVariable variable;

  /// An internal class to help transform operations
  const GraphqlArgument({
    required this.name,
    required this.variable,
  });

  /// Convert an [ArgumentNode] to a [GraphqlArgument]
  factory GraphqlArgument.fromArgumentNode(ArgumentNode node) => GraphqlArgument(
        name: node.name.value,
        variable: GraphqlVariable(
          className: '',
          name: (node.value as VariableNode).name.value,
        ),
      );

  /// Convert an [OperationDefinitionNode] to a list of [GraphqlArgument]
  static List<GraphqlArgument> fromOperationNode(OperationDefinitionNode node) =>
      (node.selectionSet.selections.first as FieldNode)
          .arguments
          .map(GraphqlArgument.fromArgumentNode)
          .toList()
          .cast<GraphqlArgument>();
}
