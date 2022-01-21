import 'package:brick_core/core.dart';
import 'package:brick_graphql/src/graphql_adapter.dart';
import 'package:brick_graphql/src/graphql_model.dart';

/// Associates app models with their [GraphQLAdapter]
class GraphQLModelDictionary extends ModelDictionary<GraphqlModel, GraphQLAdapter<GraphqlModel>> {
  const GraphQLModelDictionary(Map<Type, GraphQLAdapter<GraphqlModel>> mappings) : super(mappings);
}
