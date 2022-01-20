import 'package:brick_core/src/model_dictionary.dart';
import 'package:brick_graphql/src/graphql_model.dart';

/// A [Provider] fetches raw data and creates [Model]s. An app can have many [Provider]s.
class GraphQLProvider<GraphQLModel> {
  /// The translation between [Adapter]s and [Model]s
  final ModelDictionary modelDictionary;

  const GraphQLProvider({
    required this.modelDictionary,
  });

  Future<bool> delete<T extends GraphQLModel>(instance, {query, repository}) async =>
      throw UnimplementedError();

  Future<bool> exists<T extends GraphQLModel>({query, repository}) async =>
      throw UnimplementedError();

  Future<T> get<T extends GraphQLModel>({query, repository}) async => throw UnimplementedError();

  Future<T> upsert<T extends GraphQLModel>(instance, {query, repository}) async =>
      throw UnimplementedError();
}
