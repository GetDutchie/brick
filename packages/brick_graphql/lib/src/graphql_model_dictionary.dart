import 'package:brick_core/core.dart';
import 'package:brick_graphql/src/graphql_adapter.dart';
import 'package:brick_graphql/src/graphql_model.dart';

/// Associates app models with their [GraphQLAdapter]
class GraphQLModelDictionary extends ModelDictionary<GraphQLModel, GraphQLAdapter<GraphQLModel>> {
  const GraphQLModelDictionary(Map<Type, GraphQLAdapter<GraphQLModel>> mappings) : super(mappings);
}
