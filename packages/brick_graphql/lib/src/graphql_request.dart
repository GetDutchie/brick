import 'package:brick_core/core.dart';
import 'package:brick_graphql/src/graphql_model.dart';
import 'package:brick_graphql/src/graphql_model_dictionary.dart';
import 'package:brick_graphql/src/transformers/model_fields_document_transformer.dart';
import 'package:gql_exec/gql_exec.dart';

class GraphqlRequest<_Model extends GraphqlModel> {
  final QueryAction action;

  final _Model? instance;

  final GraphqlModelDictionary modelDictionary;

  final Query? query;

  final String? variableNamespace;

  final Map<String, dynamic>? variables;

  const GraphqlRequest({
    required this.action,
    this.instance,
    this.query,
    required this.modelDictionary,
    this.variables,
    this.variableNamespace,
  });

  Request? get request {
    final defaultOperation = ModelFieldsDocumentTransformer.defaultOperation<_Model>(
      modelDictionary,
      action: action,
      instance: instance,
      query: query,
    );

    if (defaultOperation == null) return null;

    return Request(
      operation: Operation(
        document: defaultOperation.document,
      ),
      variables: requestVariables ?? {},
      context: query?.providerArgs['context'] != null
          ? Context.fromMap(Map<String, ContextEntry>.from(query?.providerArgs['context'])
              .map((key, value) => MapEntry<Type, ContextEntry>(value.runtimeType, value)))
          : Context(),
    );
  }

  Map<String, dynamic>? get requestVariables {
    final opVariables = operationVariables(action, instance: instance, query: query);
    var vars = opVariables ?? variables ?? queryToVariables(query);
    if (variableNamespace != null) {
      vars = {variableNamespace!: vars};
    }

    return query?.providerArgs['variables'] ?? vars;
  }

  /// Retrive variables defined by the annotation in [GraphqlQueryOperationTransformer]
  Map<String, dynamic>? operationVariables(QueryAction action, {Query? query, _Model? instance}) {
    final adapter = modelDictionary.adapterFor[_Model];
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
    final adapter = modelDictionary.adapterFor[_Model]!;

    return query!.where!.fold<Map<String, dynamic>>(<String, dynamic>{}, (allVariables, where) {
      final definition = adapter.fieldsToGraphqlRuntimeDefinition[where.evaluatedField];
      if (definition != null && !definition.association) {
        allVariables[definition.documentNodeName] = where.value;
      }
      return allVariables;
    });
  }
}
