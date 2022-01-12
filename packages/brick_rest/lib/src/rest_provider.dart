import 'dart:convert';
import 'package:brick_rest/src/rest_model_dictionary.dart';
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
  Future<http.Response?> delete<_Model extends RestModel>(instance, {query, repository}) async {
    final url = urlForModel<_Model>(query, instance);
    if (url == null) return null;
    logger.fine('DELETE $url');

    final resp = await client.delete(Uri.parse(url), headers: headersForQuery(query));

    logger.finest('#delete: url=$url statusCode=${resp.statusCode} body=${resp.body}');

    if (statusCodeIsSuccessful(resp.statusCode)) {
      return resp;
    } else {
      logger.warning('#delete: url=$url statusCode=${resp.statusCode} body=${resp.body}');
      throw RestException(resp);
    }
  }

  @override
  Future<bool> exists<_Model extends RestModel>({query, repository}) async {
    final url = urlForModel<_Model>(query);
    if (url == null) return false;

    logger.fine('GET $url');

    final resp = await client.get(Uri.parse(url), headers: headersForQuery(query));
    return statusCodeIsSuccessful(resp.statusCode);
  }

  /// [Query]'s `providerArgs` can extend the [get] functionality:
  /// * `'headers'` (`Map<String, String>`) set HTTP headers
  /// * `'topLevelKey'` (`String`) includes the incoming payload beneath a JSON key (For example, `{"user": {"id"...}}`).
  /// It is recommended to use `RestSerializable#fromKey` instead to simplify queries
  /// (however, when defined, `topLevelKey` is prioritized). Note that when no key is defined, the first value is returned
  /// regardless of the first key (in the example, `{"id"...}`).
  @override
  Future<List<_Model>> get<_Model extends RestModel>({query, repository}) async {
    final url = urlForModel<_Model>(query);
    if (url == null) return <_Model>[];

    logger.fine('GET $url');

    final adapter = modelDictionary.adapterFor[_Model]!;
    final resp = await client.get(Uri.parse(url), headers: headersForQuery(query));

    logger.finest('#get: url=$url statusCode=${resp.statusCode} body=${resp.body}');

    if (statusCodeIsSuccessful(resp.statusCode)) {
      final topLevelKey = (query?.providerArgs ?? {})['topLevelKey'] ?? adapter.fromKey;
      final parsed = convertJsonFromGet(resp.body, topLevelKey);
      final body = parsed is Iterable ? parsed : [parsed];
      final results = body
          .where((msg) => msg != null)
          .map((msg) {
            return adapter.fromRest(msg, provider: this, repository: repository);
          })
          .toList()
          .cast<Future<_Model>>();

      return await Future.wait<_Model>(results);
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
  /// It is recommended to use `RestSerializable#toKey` instead to simplify queries
  /// (however, when defined, `topLevelKey` is prioritized).
  @override
  Future<http.Response?> upsert<_Model extends RestModel>(instance, {query, repository}) async {
    final adapter = modelDictionary.adapterFor[_Model]!;
    final body = await adapter.toRest(instance, provider: this, repository: repository);

    final url = urlForModel<_Model>(query, instance);
    if (url == null) return null;

    final resp = await _sendUpsertResponse(Uri.parse(url), body, query, adapter.toKey);

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
  Map<String, String> headersForQuery([Query? query]) {
    if ((query == null || query.providerArgs['headers'] == null) && defaultHeaders != null) {
      return defaultHeaders!;
    }

    return {}
      ..addAll({'Content-Type': 'application/json'})
      ..addAll(defaultHeaders ?? <String, String>{})
      ..addAll(query?.providerArgs['headers'] ?? <String, String>{});
  }

  /// Given a model instance and a query, produce a fully-qualified URL
  @protected
  String? urlForModel<_Model extends RestModel>(Query? query, [_Model? instance]) {
    assert(
      modelDictionary.adapterFor.containsKey(_Model),
      'REST provider does not contain $_Model',
    );
    final adapter = modelDictionary.adapterFor[_Model];
    final endpoint = adapter?.restEndpoint(query: query, instance: instance);

    if (endpoint?.isEmpty != false) return null;
    return baseEndpoint + endpoint!;
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
  Future<http.Response> _sendUpsertResponse(
    Uri url,
    Map<String, dynamic> body, [
    Query? query,
    String? toKey,
  ]) async {
    final encodedBody = jsonEncode(body);
    final topLevelKey = (query?.providerArgs ?? {})['topLevelKey'] ?? toKey;
    var wrappedBody = topLevelKey != null ? '{"$topLevelKey":$encodedBody}' : encodedBody;

    // if supplementalTopLevelData is specified it, insert alongside normal payload
    if ((query?.providerArgs ?? {})['supplementalTopLevelData'] != null) {
      final decodedPayload = jsonDecode(wrappedBody);
      final mergedPayload = decodedPayload..addAll(query!.providerArgs['supplementalTopLevelData']);
      wrappedBody = jsonEncode(mergedPayload);
    }

    final headers = headersForQuery(query);

    for (final method in {'PUT', 'PATCH'}) {
      if ((query?.providerArgs ?? {})['request'] == method) {
        logger.fine('$method $url');
        logger.finer('method=$method url=$url headers=$headers body=$wrappedBody');
        if (method == 'PUT') return await client.put(url, body: wrappedBody, headers: headers);
        if (method == 'PATCH') return await client.patch(url, body: wrappedBody, headers: headers);
      }
    }

    if ((query?.providerArgs ?? {})['request'] == 'PATCH') {
      logger.fine('PATCH $url');
      logger.finer('method=PUT url=$url headers=$headers body=$wrappedBody');
      return await client.put(url, body: wrappedBody, headers: headers);
    }

    logger.fine('POST $url');
    logger.finer('method=POST url=$url headers=$headers body=$wrappedBody');
    return await client.post(url, body: wrappedBody, headers: headers);
  }

  static bool statusCodeIsSuccessful(int? statusCode) =>
      statusCode != null && 200 <= statusCode && statusCode < 300;
}
