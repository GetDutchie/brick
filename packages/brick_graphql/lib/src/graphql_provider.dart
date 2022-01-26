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
  Future<List<_Model>> get<_Model extends GraphqlModel>({query, repository}) async {
    final adapter = modelDictionary.adapterFor[_Model]!;
    final request = Request(
      operation: Operation(
        document: query == null
            ? adapter.defaultGetUnfilteredOperation
            : adapter.defaultGetFilteredOperation,
      ),
    );
    final resp = await link.request(request).first;
    if (resp.data == null) return [];
    if (resp.data?.keys.first is Iterable) {
      final results = resp.data?.values.first
          .map((v) => adapter.fromGraphql(v, provider: this, repository: repository))
          .toList()
          .cast<Future<_Model>>();

      return await Future.wait<_Model>(results);
    }

    return [
      await adapter.fromGraphql(resp.data!, provider: this, repository: repository) as _Model
    ];
  }

  @override
  Future<_Model> upsert<_Model extends GraphqlModel>(instance, {query, repository}) async =>
      throw UnimplementedError();
}
