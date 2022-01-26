import 'package:brick_core/core.dart';
import 'package:brick_graphql/graphql.dart';

/// A [Provider] fetches raw data and creates [Model]s. An app can have many [Provider]s.
class GraphqlProvider extends Provider<GraphqlModel> {
  /// The translation between [Adapter]s and [Model]s
  final GraphqlModelDictionary modelDictionary;

  const GraphqlProvider({
    required this.modelDictionary,
  });

  @override
  Future<bool> delete<T extends GraphqlModel>(instance, {query, repository}) async =>
      throw UnimplementedError();

  @override
  Future<bool> exists<T extends GraphqlModel>({query, repository}) async =>
      throw UnimplementedError();

  @override
  Future<T> get<T extends GraphqlModel>({query, repository}) async => throw UnimplementedError();

  @override
  Future<T> upsert<T extends GraphqlModel>(instance, {query, repository}) async =>
      throw UnimplementedError();
}
