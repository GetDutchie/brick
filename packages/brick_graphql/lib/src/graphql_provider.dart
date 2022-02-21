import 'package:brick_core/core.dart';
import 'package:brick_graphql/graphql.dart';
import 'package:brick_graphql/src/transformers/model_fields_document_transformer.dart';
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

  GraphqlProvider({
    required this.modelDictionary,
    required this.link,
  }) : logger = Logger('GraphqlProvider');

  @protected
  @visibleForTesting
  Request createRequest<_Model extends GraphqlModel>({
    Query? query,
    required QueryAction action,
    Map<String, dynamic>? variables,
  }) {
    final defaultOperation = ModelFieldsDocumentTransformer.defaultOperation<_Model>(
      modelDictionary,
      action: action,
      query: query,
    );

    return Request(
      operation: Operation(document: defaultOperation.document),
      variables: query?.providerArgs['variables'] ?? variables ?? queryToVariables<_Model>(query),
      context: query?.providerArgs['context'] != null
          ? Context.fromMap(Map<String, ContextEntry>.from(query?.providerArgs['context'])
              .map((key, value) => MapEntry<Type, ContextEntry>(value.runtimeType, value)))
          : Context(),
    );
  }

  @override
  Future<bool> delete<_Model extends GraphqlModel>(instance, {query, repository}) async {
    final request = createRequest<_Model>(action: QueryAction.delete, query: query);
    await for (final resp in link.request(request)) {
      return resp.errors?.isEmpty ?? true;
    }
    return false;
  }

  @override
  Future<bool> exists<_Model extends GraphqlModel>({query, repository}) async {
    final request = createRequest<_Model>(action: QueryAction.get, query: query);
    await for (final resp in link.request(request)) {
      return resp.data != null && (resp.errors?.isEmpty ?? true);
    }
    return false;
  }

  @override
  Future<List<_Model>> get<_Model extends GraphqlModel>({query, repository}) async {
    final adapter = modelDictionary.adapterFor[_Model]!;
    final request = createRequest<_Model>(action: QueryAction.get, query: query);
    await for (final resp in link.request(request)) {
      if (resp.data == null) return [];
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

  /// Remove associations from variables and transform them from field names
  /// to document node names.
  Map<String, dynamic> queryToVariables<_Model extends GraphqlModel>(Query? query) {
    if (query?.where == null) return {};
    final adapter = modelDictionary.adapterFor[_Model]!;

    return query!.where!.fold<Map<String, dynamic>>(<String, dynamic>{}, (allVariables, where) {
      final definition = adapter.fieldsToGraphqlRuntimeDefinition[where.evaluatedField];
      if (definition != null && !definition.association) {
        allVariables[definition.documentNodeName] = where.value;
      }
      return allVariables;
    });
  }

  Stream<List<_Model>> subscribe<_Model extends GraphqlModel>(
      {Query? query, ModelRepository<GraphqlModel>? repository}) async* {
    final adapter = modelDictionary.adapterFor[_Model]!;
    final request = createRequest<_Model>(action: QueryAction.subscribe, query: query);
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
    final request = createRequest<_Model>(
      action: QueryAction.upsert,
      query: query,
      variables: variables,
    );
    await for (final resp in link.request(request)) {
      return resp;
    }
    return null;
  }
}
