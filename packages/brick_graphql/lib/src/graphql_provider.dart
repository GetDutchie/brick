import 'package:brick_core/core.dart';
import 'package:brick_graphql/graphql.dart';
import 'package:brick_graphql/src/graphql_request.dart';
import 'package:gql_exec/gql_exec.dart';
import 'package:gql_link/gql_link.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

/// A [Provider] fetches raw data and creates [Model]s. An app can have many [Provider]s.
class GraphqlProvider extends Provider<GraphqlModel> {
  /// The translation between [Adapter]s and [Model]s
  @override
  final GraphqlModelDictionary modelDictionary;

  Link link;

  @protected
  final Logger logger;

  /// Include all variables within a top-level key.
  ///
  /// For example, `vars` in the following instance:
  /// ```graphql
  /// query MyOperation($vars: MyInputClass!) {
  ///   myOperation(vars: $vars) {}
  /// }
  /// ```
  ///
  /// This **does not** affect variables passed via `providerArgs`.
  final String? variableNamespace;

  GraphqlProvider({
    required this.modelDictionary,
    required this.link,
    this.variableNamespace,
  }) : logger = Logger('GraphqlProvider');

  @override
  Future<bool> delete<_Model extends GraphqlModel>(instance, {query, repository}) async {
    final request = GraphqlRequest<_Model>(
      action: QueryAction.delete,
      instance: instance,
      modelDictionary: modelDictionary,
      query: query,
      variableNamespace: variableNamespace,
    ).request;
    if (request == null) return false;
    await for (final resp in link.request(request)) {
      return resp.errors?.isEmpty ?? true;
    }
    return false;
  }

  @override
  Future<bool> exists<_Model extends GraphqlModel>({query, repository}) async {
    final request = GraphqlRequest<_Model>(
      action: QueryAction.get,
      modelDictionary: modelDictionary,
      query: query,
      variableNamespace: variableNamespace,
    ).request;
    if (request == null) return false;
    await for (final resp in link.request(request)) {
      return resp.data != null && (resp.errors?.isEmpty ?? true);
    }
    return false;
  }

  @override
  Future<List<_Model>> get<_Model extends GraphqlModel>({query, repository}) async {
    final adapter = modelDictionary.adapterFor[_Model]!;
    final request = GraphqlRequest<_Model>(
      action: QueryAction.get,
      modelDictionary: modelDictionary,
      query: query,
      variableNamespace: variableNamespace,
    ).request;
    if (request == null) return <_Model>[];
    await for (final resp in link.request(request)) {
      if (resp.data?.values == null) return <_Model>[];
      if (resp.data!.values.isEmpty || resp.data!.values.first == null) {
        return <_Model>[];
      }

      if (resp.data?.values.first is Iterable) {
        final results = resp.data?.values.first
            .map((v) => adapter.fromGraphql(v, provider: this, repository: repository))
            .toList()
            .cast<Future<_Model>>();

        return await Future.wait<_Model>(results);
      }

      if (resp.data?.values.first is Map) {
        return [
          await adapter.fromGraphql(resp.data?.values.first!,
              provider: this, repository: repository) as _Model
        ];
      }

      return [
        await adapter.fromGraphql(resp.data!, provider: this, repository: repository) as _Model
      ];
    }
    return <_Model>[];
  }

  Stream<List<_Model>> subscribe<_Model extends GraphqlModel>(
      {Query? query, ModelRepository<GraphqlModel>? repository}) async* {
    final adapter = modelDictionary.adapterFor[_Model]!;
    final request = GraphqlRequest<_Model>(
      action: QueryAction.subscribe,
      modelDictionary: modelDictionary,
      query: query,
      variableNamespace: variableNamespace,
    ).request;
    if (request == null) {
      yield <_Model>[];
      return;
    }
    await for (final response in link.request(request)) {
      if (response.data?.values.first is Iterable) {
        final results = response.data?.values.first
            .map((v) => adapter.fromGraphql(v, provider: this, repository: repository))
            .toList()
            .cast<Future<_Model>>();

        yield await Future.wait<_Model>(results);
      } else if (response.data != null) {
        final result =
            await adapter.fromGraphql(response.data!, provider: this, repository: repository);
        yield [result as _Model];
      }
    }
  }

  @override
  Future<Response?> upsert<_Model extends GraphqlModel>(instance, {query, repository}) async {
    final adapter = modelDictionary.adapterFor[_Model]!;
    final variables = await adapter.toGraphql(instance, provider: this, repository: repository);
    final request = GraphqlRequest<_Model>(
      action: QueryAction.upsert,
      instance: instance,
      modelDictionary: modelDictionary,
      query: query,
      variableNamespace: variableNamespace,
      variables: variables,
    ).request;
    if (request == null) return null;
    await for (final resp in link.request(request)) {
      return resp;
    }
    return null;
  }
}
