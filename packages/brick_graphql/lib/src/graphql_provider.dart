import 'package:brick_core/src/model_dictionary.dart';
import 'package:brick_core/src/model.dart';
import 'package:brick_graphql/src/graphql_model.dart';

/// A [Provider] fetches raw data and creates [Model]s. An app can have many [Provider]s.
class GraphqlProvider<GraphqlModel> {
  /// The translation between [Adapter]s and [Model]s
  final ModelDictionary modelDictionary;

  const GraphqlProvider({
    required this.modelDictionary,
  });

  Future<bool> delete<T extends GraphqlModel>(instance, {query, repository}) async =>
      throw UnimplementedError();

  Future<bool> exists<T extends GraphqlModel>({query, repository}) async =>
      throw UnimplementedError();

  Future<T> get<T extends GraphqlModel>({query, repository}) async => throw UnimplementedError();

  Future<T> upsert<T extends GraphqlModel>(instance, {query, repository}) async =>
      throw UnimplementedError();
}
