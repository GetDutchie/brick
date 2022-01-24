import 'package:brick_graphql/graphql.dart';

import '__helpers__/demo_model.dart';
import '__helpers__/demo_model_adapter.dart';

final Map<Type, GraphQLAdapter<GraphqlModel>> _mappings = {
  DemoModel: DemoModelAdapter(),
};
final dictionary = GraphQLModelDictionary(_mappings);
