import 'dart:convert';
import 'package:brick_rest/src/rest_request_transformer.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import 'package:brick_rest/rest_exception.dart';
import 'package:brick_rest/src/rest_model.dart';
import 'package:brick_rest/src/rest_model_dictionary.dart';
import 'package:brick_core/core.dart';

/// Retrieves from an HTTP endpoint
class RestProvider implements Provider<RestModel> {
  /// A fully-qualified URL
  final String baseEndpoint;

  /// The glue between app models and generated adapters.
  @override
  final RestModelDictionary modelDictionary;

  /// Headers supplied for every [get], [delete], and [upsert] call.
  Map<String, String>? defaultHeaders;

  /// All requests pass through this client.
  http.Client client;

  @protected
  final Logger logger;

  RestProvider(
    this.baseEndpoint, {
    required this.modelDictionary,
    http.Client? client,
  })  : client = client ?? http.Client(),
        logger = Logger('RestProvider');

  /// Sends a DELETE request method to the endpoint
  @override
  Future<http.Response?> delete<TModel extends RestModel>(instance, {query, repository}) async {
    final adapter = modelDictionary.adapterFor[TModel]!;
    final request = adapter.restRequest != null ? adapter.restRequest!(query, instance) : null;

    final url = request?.delete?.url;
    if (url == null) return null;

    final resp = await _brickRequestToHttpRequest(
      request!.delete!,
      QueryAction.delete,
      query: query,
    );

    if (statusCodeIsSuccessful(resp.statusCode)) {
      return resp;
    } else {
      logger.warning('#delete: url=$url statusCode=${resp.statusCode} body=${resp.body}');
      throw RestException(resp);
    }
  }

  @override
  Future<bool> exists<TModel extends RestModel>({query, repository}) async {
    final adapter = modelDictionary.adapterFor[TModel]!;
    final request = adapter.restRequest != null ? adapter.restRequest!(query, null) : null;

    final url = request?.get?.url;
    if (url == null) return false;

    final resp = await _brickRequestToHttpRequest(
      request!.get!,
      QueryAction.get,
      query: query,
    );
    return statusCodeIsSuccessful(resp.statusCode);
  }

  /// [Query]'s `providerArgs` can extend the [get] functionality:
  /// * `'headers'` (`Map<String, String>`) set HTTP headers
  /// * `'topLevelKey'` (`String`) includes the incoming payload beneath a JSON key (For example, `{"user": {"id"...}}`).
  /// It is recommended to use `RestSerializable#fromKey` instead to simplify queries
  /// (however, when defined, `topLevelKey` is prioritized). Note that when no key is defined, the first value is returned
  /// regardless of the first key (in the example, `{"id"...}`).
  @override
  Future<List<TModel>> get<TModel extends RestModel>({query, repository}) async {
    final adapter = modelDictionary.adapterFor[TModel]!;
    final request = adapter.restRequest != null ? adapter.restRequest!(query, null) : null;

    final url = request?.get?.url;
    if (url == null) return <TModel>[];

    final resp = await _brickRequestToHttpRequest(
      request!.get!,
      QueryAction.get,
      query: query,
    );

    if (statusCodeIsSuccessful(resp.statusCode)) {
      final topLevelKey = (query?.providerArgs ?? {})['topLevelKey'] ?? request.get?.topLevelKey;
      final parsed = convertJsonFromGet(resp.body, topLevelKey);
      final body = parsed is Iterable ? parsed : [parsed];
      final results = body
          .where((msg) => msg != null)
          .map((msg) {
            return adapter.fromRest(msg, provider: this, repository: repository);
          })
          .toList()
          .cast<Future<TModel>>();

      return await Future.wait<TModel>(results);
    } else {
      logger.warning('#get: url=$url statusCode=${resp.statusCode} body=${resp.body}');
      throw RestException(resp);
    }
  }

  /// [Query]'s `providerArgs` can extend the [upsert] functionality:
  /// * `'headers'` (`Map<String, String>`) set HTTP headers
  /// * `'request'` (`String`) specifies HTTP method. Defaults to `POST`
  /// * `'topLevelKey'` (`String`) includes the serialized payload beneath a JSON key (For example, `{"user": {"id"...}}`)
  /// * `'supplementalTopLevelData'` (`Map<String, dynamic>`) this map is merged alongside the `topLevelKey` in the payload.
  /// For example, given `'supplementalTopLevelData': {'other_key': true}` `{"topLevelKey": ..., "other_key": true}`. It is **strongly recommended** to avoid using this property. Your data should be managed at the model level, not the query level.
  ///
  /// It is recommended to use `RestRequest#topLevelKey` instead to simplify queries
  /// (however, when defined in providerArgs, `topLevelKey` is prioritized).
  @override
  Future<http.Response?> upsert<TModel extends RestModel>(instance, {query, repository}) async {
    final adapter = modelDictionary.adapterFor[TModel]!;
    final body = await adapter.toRest(instance, provider: this, repository: repository);
    final request = adapter.restRequest != null ? adapter.restRequest!(query, instance) : null;

    final url = request?.upsert?.url;
    if (url == null) return null;

    final combinedBody = {};

    final topLevelKey = (query?.providerArgs ?? {})['topLevelKey'] ?? request?.upsert?.topLevelKey;
    if (topLevelKey != null) {
      combinedBody.addAll({topLevelKey: body});
    } else {
      combinedBody.addAll(body);
    }

    // if supplementalTopLevelData is specified it, insert alongside normal payload
    if ((query?.providerArgs ?? {})['supplementalTopLevelData'] != null) {
      combinedBody.addAll(query!.providerArgs['supplementalTopLevelData']);
    }

    final resp = await _brickRequestToHttpRequest(
      request!.upsert!,
      QueryAction.upsert,
      body: jsonEncode(combinedBody),
      query: query,
    );

    logger.finest('#upsert: url=$url statusCode=${resp.statusCode} body=${resp.body}');

    if (statusCodeIsSuccessful(resp.statusCode)) {
      return resp;
    } else {
      logger.warning('#upsert: url=$url statusCode=${resp.statusCode} body=${resp.body}');
      throw RestException(resp);
    }
  }

  /// Expand a query into HTTP headers
  @protected
  Map<String, String> headersForQuery(Query? query, Map<String, String>? requestHeaders) {
    if ((query == null || query.providerArgs['headers'] == null) &&
        requestHeaders == null &&
        defaultHeaders != null) {
      return defaultHeaders!;
    }

    return {}
      ..addAll({'Content-Type': 'application/json'})
      ..addAll(defaultHeaders ?? <String, String>{})
      ..addAll(requestHeaders ?? <String, String>{})
      ..addAll(query?.providerArgs['headers'] ?? <String, String>{});
  }

  /// If a [key] is defined from the adapter and it is not null in the response, use it to narrow the response.
  /// Otherwise, if there is only one top level key, use it to narrow the response.
  /// Otherwise, return the payload.
  @visibleForOverriding
  dynamic convertJsonFromGet(String json, String? key) {
    final decoded = jsonDecode(json);
    if (key != null && decoded[key] != null) {
      return decoded[key];
    } else if (decoded is Map) {
      if (decoded.keys.length == 1) {
        return decoded.values.first;
      }
    }

    return decoded;
  }

  /// Sends serialized model data to an endpoint
  Future<http.Response> _brickRequestToHttpRequest(
    RestRequest request,
    QueryAction operation, {
    Query? query,
    String? body,
  }) async {
    final url = Uri.parse([baseEndpoint, request.url!].join(''));
    final method = (query?.providerArgs ?? {})['request'] ?? request.method ?? operation.httpMethod;
    final headers = headersForQuery(query, request.headers);

    logger.fine('$method $url');
    final methodLog = 'method=$method url=$url headers=$headers';
    if (operation == QueryAction.upsert) {
      logger.finer('$methodLog body=$body');
    } else {
      logger.finest(methodLog);
    }

    switch (method) {
      case 'DELETE':
        return await client.delete(url, headers: headers);
      case 'GET':
        return await client.get(url, headers: headers);
      case 'PATCH':
        return await client.patch(url, body: body, headers: headers);
      case 'POST':
        return await client.post(url, body: body, headers: headers);
      case 'PUT':
        return await client.put(url, body: body, headers: headers);
      default:
        throw StateError(
          "Request method $method is unhandled; use providerArgs['request'] or RestRequest#method",
        );
    }
  }

  static bool statusCodeIsSuccessful(int? statusCode) =>
      statusCode != null && 200 <= statusCode && statusCode < 300;
}

extension on QueryAction {
  String get httpMethod {
    switch (this) {
      case QueryAction.get:
        return 'GET';
      case QueryAction.insert:
      case QueryAction.update:
      case QueryAction.upsert:
        return 'POST';
      case QueryAction.delete:
        return 'DELETE';
      case QueryAction.subscribe:
        return 'GET';
    }
  }
}
