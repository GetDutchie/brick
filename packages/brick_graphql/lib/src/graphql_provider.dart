import 'package:brick_core/core.dart';
import 'package:brick_graphql/brick_graphql.dart';
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

  /// The invoking [Link] used to access the GraphQL API.
  /// Can be overriden by repositories.
  Link link;

  /// Internal use logger.
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

  /// A [Provider] fetches raw data from GraphQL and creates [Model]s. An app can have many [Provider]s.
  GraphqlProvider({
    required this.modelDictionary,
    required this.link,
    this.variableNamespace,
  }) : logger = Logger('GraphqlProvider');

  @override
  Future<bool> delete<TModel extends GraphqlModel>(
    TModel instance, {
    Query? query,
    ModelRepository<GraphqlModel>? repository,
  }) async {
    final request = GraphqlRequest<TModel>(
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
  Future<bool> exists<TModel extends GraphqlModel>({
    Query? query,
    ModelRepository<GraphqlModel>? repository,
  }) async {
    final request = GraphqlRequest<TModel>(
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
  Future<List<TModel>> get<TModel extends GraphqlModel>({
    Query? query,
    ModelRepository<GraphqlModel>? repository,
  }) async {
    final adapter = modelDictionary.adapterFor[TModel]!;
    final request = GraphqlRequest<TModel>(
      action: QueryAction.get,
      modelDictionary: modelDictionary,
      query: query,
      variableNamespace: variableNamespace,
    ).request;
    if (request == null) return <TModel>[];
    await for (final resp in link.request(request)) {
      if (resp.data?.values == null) return <TModel>[];
      if (resp.data!.values.isEmpty || resp.data!.values.first == null) {
        return <TModel>[];
      }

      if (resp.data?.values.first is Iterable) {
        final results = resp.data?.values.first
            .map((v) => adapter.fromGraphql(v, provider: this, repository: repository))
            .toList()
            .cast<Future<TModel>>();

        return await Future.wait<TModel>(results);
      }

      if (resp.data?.values.first is Map) {
        return [
          await adapter.fromGraphql(
            resp.data?.values.first!,
            provider: this,
            repository: repository,
          ) as TModel,
        ];
      }

      return [
        await adapter.fromGraphql(resp.data!, provider: this, repository: repository) as TModel,
      ];
    }
    return <TModel>[];
  }

  /// Invokes the `subscribe` GraphQL operation and returns a [Stream] of [Model]s.
  /// The GraphQL API **must** support subscriptions.
  Stream<List<TModel>> subscribe<TModel extends GraphqlModel>({
    Query? query,
    ModelRepository<GraphqlModel>? repository,
  }) async* {
    final adapter = modelDictionary.adapterFor[TModel]!;
    final request = GraphqlRequest<TModel>(
      action: QueryAction.subscribe,
      modelDictionary: modelDictionary,
      query: query,
      variableNamespace: variableNamespace,
    ).request;
    if (request == null) {
      yield <TModel>[];
      return;
    }
    await for (final response in link.request(request)) {
      if (response.data?.values.first is Iterable) {
        final results = response.data?.values.first
            .map((v) => adapter.fromGraphql(v, provider: this, repository: repository))
            .toList()
            .cast<Future<TModel>>();

        yield await Future.wait<TModel>(results);
      } else if (response.data != null) {
        final result =
            await adapter.fromGraphql(response.data!, provider: this, repository: repository);
        yield [result as TModel];
      }
    }
  }

  @override
  Future<Response?> upsert<TModel extends GraphqlModel>(
    TModel instance, {
    Query? query,
    ModelRepository<GraphqlModel>? repository,
  }) async {
    final adapter = modelDictionary.adapterFor[TModel]!;
    final variables = await adapter.toGraphql(instance, provider: this, repository: repository);
    final request = GraphqlRequest<TModel>(
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
