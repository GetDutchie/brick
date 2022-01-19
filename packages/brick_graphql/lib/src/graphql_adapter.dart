import 'package:brick_core/core.dart';
import 'package:brick_graphql/src/graphql_model.dart';
import 'package:brick_graphql/src/graphql_provider.dart';
import 'package:gql/ast.dart';

/// Constructors that convert app models to and from REST
abstract class GraphQLAdapter<_Model extends Model> implements Adapter<_Model> {
  Future<_Model> fromGraphQL(
    Map<String, dynamic> input, {
    required GraphQLProvider provider,
    ModelRepository<GraphQLModel>? repository,
  });

  Future<Map<String, dynamic>> toGraphQL(
    _Model input, {
    required GraphQLProvider provider,
    ModelRepository<GraphQLModel>? repository,
  });

  DocumentNode get mututationEndpoint;
}
