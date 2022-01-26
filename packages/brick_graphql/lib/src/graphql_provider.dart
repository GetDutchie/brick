import 'package:brick_core/core.dart';
import 'package:brick_graphql/graphql.dart';
import 'package:gql_exec/gql_exec.dart';
import 'package:gql_link/gql_link.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

/// A [Provider] fetches raw data and creates [Model]s. An app can have many [Provider]s.
class GraphqlProvider extends Provider<GraphqlModel> {
  /// The translation between [Adapter]s and [Model]s
  final GraphqlModelDictionary modelDictionary;

  final Link link;

  @protected
  final Logger logger;

  GraphqlProvider({
    required this.modelDictionary,
    required this.link,
  }) : logger = Logger('GraphqlProvider');

  @override
  Future<bool> delete<_Model extends GraphqlModel>(instance, {query, repository}) async =>
      throw UnimplementedError();

  @override
  Future<bool> exists<_Model extends GraphqlModel>({query, repository}) async =>
      throw UnimplementedError();

  @override
  Future<_Model> get<_Model extends GraphqlModel>({query, repository}) async {
    final adapter = modelDictionary.adapterFor[_Model]!;
    final request = Request(operation: Operation(document: ));
    final resp = await link.request(request).first;
    return await adapter.fromGraphql(resp.data, provider: this, repository: repository);
  }

  @override
  Future<_Model> upsert<_Model extends GraphqlModel>(instance, {query, repository}) async =>
      throw UnimplementedError();
}
