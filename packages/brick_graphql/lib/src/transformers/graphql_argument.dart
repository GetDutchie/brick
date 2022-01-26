import 'package:brick_graphql/src/transformers/graphql_variable.dart';
import 'package:gql/ast.dart';
import 'package:gql/operation.dart';

class GraphqlArgument {
  final String name;

  final GraphqlVariable variable;

  const GraphqlArgument({
    required this.name,
    required this.variable,
  });

  factory GraphqlArgument.fromArgumentNode(ArgumentNode node) {
    return GraphqlArgument(
      name: node.name.value,
      variable: GraphqlVariable(
        className: '',
        name: (node.value as VariableNode).name.value,
      ),
    );
  }

  static List<GraphqlArgument> fromOperationNode(OperationDefinitionNode node) {
    return (node.selectionSet.selections.first as FieldNode)
        .arguments
        .map((a) => GraphqlArgument.fromArgumentNode(a))
        .toList()
        .cast<GraphqlArgument>();
  }
}
