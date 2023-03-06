import 'package:brick_core/core.dart';
import 'package:brick_graphql/src/graphql_model.dart';
import 'package:brick_graphql/src/graphql_provider.dart';
import 'package:brick_graphql/src/runtime_graphql_definition.dart';
import 'package:brick_graphql/src/transformers/graphql_query_operation_transformer.dart';

class _DefaultGraphqlTransformer<TModel extends GraphqlModel>
    extends GraphqlQueryOperationTransformer<TModel> {
  const _DefaultGraphqlTransformer(Query? query, TModel? instance) : super(null, null);
}

/// Constructors that convert app models to and from REST
abstract class GraphqlAdapter<TModel extends GraphqlModel> implements Adapter<TModel> {
  GraphqlQueryOperationTransformer<TModel> Function(Query?, TModel?)?
      get queryOperationTransformer => _DefaultGraphqlTransformer<TModel>.new;

  Map<String, RuntimeGraphqlDefinition> get fieldsToGraphqlRuntimeDefinition;

  Future<TModel> fromGraphql(
    Map<String, dynamic> input, {
    required GraphqlProvider provider,
    ModelRepository<GraphqlModel>? repository,
  });

  Future<Map<String, dynamic>> toGraphql(
    TModel input, {
    required GraphqlProvider provider,
    ModelRepository<GraphqlModel>? repository,
  });
}
