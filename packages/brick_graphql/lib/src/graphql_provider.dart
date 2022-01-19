import 'dart:io';

import 'package:brick_graphql/src/graphql_model.dart';
import 'package:brick_graphql/src/graphql_model_dictionary.dart';
import 'package:gql/ast.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:brick_core/core.dart';
import 'package:graphql/client.dart';

/// Retrieves from an HTTP endpoint
class GraphQLProvider implements Provider<GraphQLModel> {
  /// The glue between app models and generated adapters.
  @override

  /// All requests pass through this client.
  final GraphQLModelDictionary modelDictionary;
  final Link link;

  @protected
  final Logger logger;

  GraphQLProvider(this.link, this.modelDictionary) : logger = Logger('GraphQLProvider');

  Future<_Model> upsert<_Model extends GraphQLModel>(instance, {query, repository}) async {
    final adapter = modelDictionary.adapterFor[_Model]!;
    final variables = await adapter.toGraphQL(instance, provider: this, repository: repository);

    MutationOptions options =
        MutationOptions(document: adapter.mututationEndpoint, variables: variables);
    final resp = await link.request(options.asRequest);
    return instance;
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
  get<T extends GraphQLModel>({Query? query, ModelRepository<GraphQLModel>? repository}) {
    // TODO: implement get
    throw UnimplementedError();
  }
}
