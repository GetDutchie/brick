import 'package:brick_graphql/brick_graphql.dart';

import '__helpers__/demo_model.dart';
import '__helpers__/demo_model_adapter.dart';
import '__helpers__/demo_model_assoc_adapter.dart';

final Map<Type, GraphqlAdapter<GraphqlModel>> _mappings = {
  DemoModel: DemoModelAdapter(),
  DemoModelAssoc: DemoModelAssocAdapter(),
  DemoModelAssocWithSubfields: DemoModelAssocWithSubfieldsAdapter(),
};
final dictionary = GraphqlModelDictionary(_mappings);
