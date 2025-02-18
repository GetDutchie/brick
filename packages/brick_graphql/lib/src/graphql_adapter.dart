import 'package:brick_core/core.dart';
import 'package:brick_graphql/src/graphql_model.dart';
import 'package:brick_graphql/src/graphql_provider.dart';
import 'package:brick_graphql/src/runtime_graphql_definition.dart';
import 'package:brick_graphql/src/transformers/graphql_query_operation_transformer.dart';

class _DefaultGraphqlTransformer extends GraphqlQueryOperationTransformer {
  const _DefaultGraphqlTransformer(Query? _, GraphqlModel? __) : super(null, null);
}

/// Constructors that convert app models to and from REST
abstract mixin class GraphqlAdapter<TModel extends Model> implements Adapter<TModel> {
  /// The transformer to change a [Query] to a [GraphqlOperation]
  GraphqlQueryOperationTransformer Function(Query?, GraphqlModel?)? get queryOperationTransformer =>
      _DefaultGraphqlTransformer.new;

  /// A map of Dart field names to their [RuntimeGraphqlDefinition]
  Map<String, RuntimeGraphqlDefinition> get fieldsToGraphqlRuntimeDefinition;

  /// Deserialize from GraphQL
  Future<TModel> fromGraphql(
    Map<String, dynamic> input, {
    required GraphqlProvider provider,
    ModelRepository<GraphqlModel>? repository,
  });

  /// Serialize to GraphQL
  Future<Map<String, dynamic>> toGraphql(
    TModel input, {
    required GraphqlProvider provider,
    ModelRepository<GraphqlModel>? repository,
  });
}
