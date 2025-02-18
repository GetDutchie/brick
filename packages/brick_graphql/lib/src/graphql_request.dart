import 'package:brick_core/core.dart';
import 'package:brick_graphql/brick_graphql.dart';
import 'package:brick_graphql/src/transformers/model_fields_document_transformer.dart';
import 'package:gql_exec/gql_exec.dart';

/// A request to a [GraphqlProvider]
class GraphqlRequest<TModel extends GraphqlModel> {
  /// The action to perform on the API
  final QueryAction action;

  /// The instance to use. Not relevant for [QueryAction.get]
  final TModel? instance;

  /// The repository definition of other adapters know the GraphQL
  final GraphqlModelDictionary modelDictionary;

  /// The invoking [Query]
  final Query? query;

  /// The top-level name to nest subsquent variables
  final String? variableNamespace;

  /// Available variables.
  final Map<String, dynamic>? variables;

  /// A request to a [GraphqlProvider]
  const GraphqlRequest({
    required this.action,
    this.instance,
    this.query,
    required this.modelDictionary,
    this.variables,
    this.variableNamespace,
  });

  /// The transformed [Request] for use with an eventual `Link`
  Request? get request {
    final defaultOperation = ModelFieldsDocumentTransformer.defaultOperation<TModel>(
      modelDictionary,
      action: action,
      instance: instance,
      query: query,
    );

    if (defaultOperation == null) return null;

    final context = (query?.providerQueries[GraphqlProvider] as GraphqlProviderQuery?)?.context;

    return Request(
      operation: Operation(
        document: defaultOperation.document,
      ),
      variables: requestVariables ?? {},
      context: context ?? const Context(),
    );
  }

  /// Declared variables from the operation and the query
  Map<String, dynamic>? get requestVariables {
    final opVariables = operationVariables(action, instance: instance, query: query);
    var vars = opVariables ?? variables ?? queryToVariables(query);
    if (variableNamespace != null) {
      vars = {variableNamespace!: vars};
    }

    final operation = (query?.providerQueries[GraphqlProvider] as GraphqlProviderQuery?)?.operation;
    return operation?.variables ?? vars;
  }

  /// Retrive variables defined by the annotation in [GraphqlQueryOperationTransformer]
  Map<String, dynamic>? operationVariables(QueryAction action, {Query? query, TModel? instance}) {
    final adapter = modelDictionary.adapterFor[TModel];
    final operationTransformer = adapter?.queryOperationTransformer == null
        ? null
        : adapter!.queryOperationTransformer!(query, instance);

    switch (action) {
      case QueryAction.get:
        return operationTransformer?.get?.variables;
      case QueryAction.insert:
      case QueryAction.update:
      case QueryAction.upsert:
        return operationTransformer?.upsert?.variables;
      case QueryAction.delete:
        return operationTransformer?.delete?.variables;
      case QueryAction.subscribe:
        return operationTransformer?.subscribe?.variables;
    }
  }

  /// Remove associations from variables and transform them from field names
  /// to document node names.
  Map<String, dynamic> queryToVariables(Query? query) {
    if (query?.where == null) return {};
    final adapter = modelDictionary.adapterFor[TModel]!;

    return query!.where!.fold<Map<String, dynamic>>(<String, dynamic>{}, (allVariables, where) {
      final definition = adapter.fieldsToGraphqlRuntimeDefinition[where.evaluatedField];
      if (definition != null && !definition.association) {
        allVariables[definition.documentNodeName] = where.value;
      }
      return allVariables;
    });
  }
}
