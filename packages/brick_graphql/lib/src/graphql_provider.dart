import 'dart:convert';
import 'package:brick_offline_first_abstract/offline_first_model.dart';
import 'package:gql/ast.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import 'package:brick_rest/rest_exception.dart';
import 'package:brick_core/core.dart';

/// Retrieves from an HTTP endpoint
class GraphQLProvider implements Provider<GraphQLProvider>{
  /// A fully-qualified URL
  final String baseEndpoint;

  /// The glue between app models and generated adapters.

  @override
  final DocumentNode graphlDefinition;

  /// Headers supplied for every [get], [delete], and [upsert] call.
  Map<String, String>? defaultHeaders;

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


  Future<void> query<_Model extends GraphQLModel> async {

  }

  Future<void> mutation<_Model extends GraphQLModel> async {

  }

  static bool statusCodeIsSuccessful(int? statusCode) =>
      statusCode != null && 200 <= statusCode && statusCode < 300;

  @override
  delete<T extends GraphQLModel>(T instance, {Query? query, ModelRepository<GraphQLModel>? repository}) {
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
  upsert<T extends GraphQLModel>(T instance, {Query? query, ModelRepository<GraphQLModel>? repository}) {
    // TODO: implement upsert
    throw UnimplementedError();
  }

  @override
  get<T extends GraphQLModel>({Query? query, ModelRepository<GraphQLModel>? repository}) {
    // TODO: implement get
    throw UnimplementedError();
  }
}
