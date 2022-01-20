import 'package:brick_core/core.dart';
import 'package:brick_graphql/src/graphql_model.dart';
import 'package:brick_graphql/src/graphql_provider.dart';
import 'package:gql/ast.dart';

/// Constructors that convert app models to and from REST
abstract class GraphqlAdapter<_Model extends Model> implements Adapter<_Model> {
  Future<_Model> fromGraphql(
    Map<String, dynamic> input, {
    required GraphqlProvider provider,
    ModelRepository<GraphqlModel>? repository,
  });

  Future<Map<String, dynamic>> toGraphql(
    _Model input, {
    required GraphqlProvider provider,
    ModelRepository<GraphqlModel>? repository,
  });

  DocumentNode get mututationEndpoint;
}
