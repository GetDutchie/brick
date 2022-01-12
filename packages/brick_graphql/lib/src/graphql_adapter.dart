import 'package:brick_core/core.dart';
import 'package:brick_graphql/src/graphql_provider.dart';

/// Constructors that convert app models to and from REST
abstract class GraphQLAdapter<_Model extends Model> implements Adapter<_Model> {
  Future<_Model> fromGraphQL(
    Map<String, dynamic> input, {
    required GraphQLProvider provider,
  });

  Future<_Model> toGraphQL(
    Map<String, dynamic> input, {
    required GraphQLProvider provider,
  });
}
