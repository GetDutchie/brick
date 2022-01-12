import 'package:brick_graphql/src/graphql_model.dart';
import 'package:gql/ast.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:brick_core/core.dart';
import 'package:graphql/client.dart';

/// Retrieves from an HTTP endpoint
class GraphQLProvider implements Provider<GraphQLModel> {
  /// A fully-qualified URL
  final String baseEndpoint;

  /// The glue between app models and generated adapters.
  @override
  final DocumentNode graphlDefinition;

  /// All requests pass through this client.
  GraphQLClient client;

  @protected
  final Logger logger;

  GraphQLProvider(
    this.baseEndpoint, {
    required this.graphlDefinition,
    GraphQLClient? client,
  })  : client = client ??
            GraphQLClient(
              cache: GraphQLCache(),
              link: Link.from(
                [
                  HttpLink(
                    baseEndpoint,
                  )
                ],
              ),
            ),
        logger = Logger('GraphQLProvider');

  Future<void> query<_Model extends GraphQLModel>(query) async {
    QueryOptions options = QueryOptions(document: query);
    if (baseEndpoint == null) return null;
    final resp = client.query(options);
  }

  Future<void> mutation<_Model extends GraphQLModel>(query) async {
    QueryOptions options = QueryOptions(document: query);
    if (baseEndpoint == null) return null;
    final resp = client.query(options);
  }

  static bool statusCodeIsSuccessful(int? statusCode) =>
      statusCode != null && 200 <= statusCode && statusCode < 300;

  @override
  delete<T extends GraphQLModel>(T instance,
      {Query? query, ModelRepository<GraphQLModel>? repository}) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  exists<T extends GraphQLModel>({Query? query, ModelRepository<GraphQLModel>? repository}) {
    // TODO: implement exists
    throw UnimplementedError();
  }

  @override
  // TODO: implement modelDictionary
  ModelDictionary<Model, Adapter<Model>>? get modelDictionary => throw UnimplementedError();

  @override
  upsert<T extends GraphQLModel>(T instance,
      {Query? query, ModelRepository<GraphQLModel>? repository}) {
    // TODO: implement upsert
    throw UnimplementedError();
  }

  @override
  get<T extends GraphQLModel>({Query? query, ModelRepository<GraphQLModel>? repository}) {
    // TODO: implement get
    throw UnimplementedError();
  }
}
