import 'package:brick_core/src/model_dictionary.dart';
import 'package:brick_core/src/model.dart';
import 'package:brick_graphql/src/graphql_model.dart';

/// A [Provider] fetches raw data and creates [Model]s. An app can have many [Provider]s.
class GraphqlProvider<graphqlModel> {
  /// The translation between [Adapter]s and [Model]s
  final ModelDictionary modelDictionary;

  const GraphqlProvider({
    required this.modelDictionary,
  });

  Future<bool> delete<T extends graphqlModel>(instance, {query, repository}) async =>
      throw UnimplementedError();

  Future<bool> exists<T extends graphqlModel>({query, repository}) async =>
      throw UnimplementedError();

  Future<T> get<T extends graphqlModel>({query, repository}) async => throw UnimplementedError();

  Future<T> upsert<T extends graphqlModel>(instance, {query, repository}) async =>
      throw UnimplementedError();
}
