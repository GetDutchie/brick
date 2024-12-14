import 'package:brick_core/query.dart';
import 'package:brick_graphql/src/graphql_provider.dart';
import 'package:brick_graphql/src/transformers/graphql_query_operation_transformer.dart';
import 'package:gql_exec/gql_exec.dart';

class GraphqlProviderQuery extends ProviderQuery<GraphqlProvider> {
  final Context? context;

  final GraphqlOperation? operation;

  GraphqlProviderQuery({
    this.context,
    this.operation,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      if (context != null) 'context': context,
      if (operation != null) 'operation': operation,
    };
  }
}
