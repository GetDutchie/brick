import 'package:brick_graphql/src/transformers/graphql_variable.dart';

class GraphqlArgument {
  final String name;

  final GraphqlVariable variable;

  const GraphqlArgument({
    required this.name,
    required this.variable,
  });
}
