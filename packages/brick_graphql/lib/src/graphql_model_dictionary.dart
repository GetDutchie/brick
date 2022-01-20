import 'package:brick_core/core.dart';
import 'package:brick_graphql/src/graphql_adapter.dart';
import 'package:brick_graphql/src/graphql_model.dart';

/// Associates app models with their [GraphqlAdapter]
class GraphqlModelDictionary extends ModelDictionary<GraphqlModel, GraphqlAdapter<GraphqlModel>> {
  const GraphqlModelDictionary(Map<Type, GraphqlAdapter<GraphqlModel>> mappings) : super(mappings);
}
