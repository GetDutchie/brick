import 'package:brick_core/query.dart';
import 'package:brick_graphql/src/graphql_provider.dart';
import 'package:brick_graphql/src/transformers/graphql_query_operation_transformer.dart';
import 'package:gql_exec/gql_exec.dart';

/// A [ProviderQuery] for a [GraphqlProvider] for use with [Query]
class GraphqlProviderQuery extends ProviderQuery<GraphqlProvider> {
  /// Additional context for the GraphQL request
  final Context? context;

  /// The GraphQL operation
  final GraphqlOperation? operation;

  /// A [ProviderQuery] for a [GraphqlProvider] for use with [Query]
  const GraphqlProviderQuery({
    this.context,
    this.operation,
  });

  @override
  Map<String, dynamic> toJson() => {
        if (context != null) 'context': context.toString(),
        if (operation != null) 'operation': operation!.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GraphqlProviderQuery &&
          runtimeType == other.runtimeType &&
          context == other.context &&
          operation == other.operation;

  @override
  int get hashCode => context.hashCode ^ operation.hashCode;
}
