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
  final GraphqlModelDictionary modelDictionary;

  final Link link;

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
      variables: variables ?? query?.providerArgs['variables'] ?? queryToVariables<_Model>(query),
    );
  }

  @override
  Future<bool> delete<_Model extends GraphqlModel>(instance, {query, repository}) async {
    final request = createRequest<_Model>(action: QueryAction.delete, query: query);
    final resp = await link.request(request).first;
    return resp.errors?.isEmpty ?? true;
  }

  @override
  Future<bool> exists<_Model extends GraphqlModel>({query, repository}) async {
    final request = createRequest<_Model>(action: QueryAction.get, query: query);
    final resp = await link.request(request).first;
    return resp.data != null && (resp.errors?.isEmpty ?? true);
  }

  @override
  Future<List<_Model>> get<_Model extends GraphqlModel>({query, repository}) async {
    final adapter = modelDictionary.adapterFor[_Model]!;
    final request = createRequest<_Model>(action: QueryAction.get, query: query);
    final resp = await link.request(request).first;
    if (resp.data == null) return [];
    if (resp.data?.values.first is Iterable) {
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

  /// Remove associations from variables and transform them from field names
  /// to document node names.
  @protected
  @visibleForTesting
  Map<String, dynamic> queryToVariables<_Model extends GraphqlModel>(Query? query) {
    if (query?.where == null) return {};
    final adapter = modelDictionary.adapterFor[_Model]!;

    return query!.where!.fold<Map<String, dynamic>>(<String, dynamic>{}, (allVariables, where) {
      final definition = adapter.fieldsToRuntimeDefinition[where.evaluatedField];
      if (definition != null && !definition.association) {
        allVariables[definition.documentNodeName] = where.value;
      }
      return allVariables;
    });
  }

  @override
  Future<Response> upsert<_Model extends GraphqlModel>(instance, {query, repository}) async {
    final adapter = modelDictionary.adapterFor[_Model]!;
    final variables = await adapter.toGraphql(instance, provider: this, repository: repository);
    final request = createRequest<_Model>(
      action: QueryAction.upsert,
      query: query,
      variables: variables,
    );
    return await link.request(request).first;
  }
}
