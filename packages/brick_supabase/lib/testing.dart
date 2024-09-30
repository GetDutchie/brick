import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:brick_core/query.dart';
import 'package:brick_supabase/brick_supabase.dart';
import 'package:brick_supabase/src/query_supabase_transformer.dart';
import 'package:collection/collection.dart';
import 'package:supabase/supabase.dart';

class SupabaseRequest<TModel extends SupabaseModel> {
  /// If `fields` are not provided, they will try to be inferred using the
  /// [SupabaseMockServer]'s `modelDictionary`.
  final String? fields;

  final String? filter;

  final int? limit;

  final String? requestMethod;

  /// If a `tableName` is not provided, it will try to be inferred using the
  /// [SupabaseMockServer]'s `modelDictionary` based on the
  /// `SupabaseAdapter`'s `supabaseTableName`.
  final String? tableName;

  SupabaseRequest({
    this.tableName,
    this.fields,
    this.filter,
    this.limit,
    this.requestMethod = 'GET',
  });

  Uri toUri(SupabaseModelDictionary? modelDictionary) {
    final generatedFields = modelDictionary != null
        ? SupabaseRequest.fieldsFromDictionary<TModel>(modelDictionary)
        : fields;
    final generatedTableName =
        modelDictionary != null ? modelDictionary.adapterFor[TModel]?.supabaseTableName : tableName;

    if (requestMethod == 'DELETE') {
      final url = '/rest/v1/$generatedTableName${filter != null ? '?$filter&' : '?'}';
      return Uri.parse(url);
    }

    final url =
        '/rest/v1/$generatedTableName${filter != null ? '?$filter&' : '?'}select=${Uri.encodeComponent(generatedFields ?? '')}${limit != null ? '&limit=$limit' : ''}';
    return Uri.parse(url);
  }

  /// This provides a convenience method to generate [fields] as the
  /// [SupabaseProvider] would generate them.
  static String fieldsFromDictionary<TModel extends SupabaseModel>(
    SupabaseModelDictionary modelDictionary, {
    Query? query,
  }) {
    final transformer =
        QuerySupabaseTransformer<TModel>(modelDictionary: modelDictionary, query: query);
    return transformer.selectFields;
  }
}

class SupabaseResponse {
  final dynamic data;

  final Map<String, String>? headers;

  SupabaseResponse(this.data, {this.headers});
}

class SupabaseMockServer {
  final String apiKey;

  late SupabaseClient client;

  final SupabaseModelDictionary modelDictionary;

  late HttpServer server;

  String get serverUrl => 'http://${server.address.host}:${server.port}';

  SupabaseMockServer({this.apiKey = 'supabaseKey', required this.modelDictionary});

  /// Invoke within a group as `tearDown(mock.tearDown)`
  Future<void> tearDown() async {
    await client.dispose();
    await client.removeAllChannels();
    await server.close(force: true);
  }

  /// Invoke within a test block before any calls are made to a Supabase server
  // https://github.com/supabase/supabase-flutter/blob/main/packages/supabase/test/mock_test.dart#L21
  Future<void> handle(Map<SupabaseRequest, SupabaseResponse> responses) async {
    await for (final request in server) {
      final matchingRequest = responses.entries.firstWhereOrNull((r) {
        final url = request.uri.toString();
        final matchesRequestMethod =
            r.key.requestMethod == request.method || r.key.requestMethod == null;
        final matchesPath = request.uri.path == r.key.toUri(modelDictionary).path;
        var matchesQuery = true;
        for (final param in r.key.toUri(modelDictionary).queryParameters.entries) {
          if (!request.uri.queryParameters.containsKey(param.key) ||
              param.value != request.uri.queryParameters[param.key]) {
            matchesQuery = false;
            break;
          }
        }
        return r.key.toUri(modelDictionary).toString() == url ||
            (matchesRequestMethod && matchesPath && matchesQuery);
      });

      if (matchingRequest != null) {
        final resp = request.response
          ..statusCode = HttpStatus.ok
          ..headers.contentType = ContentType.json;
        if (matchingRequest.value.headers != null) {
          matchingRequest.value.headers!.forEach(resp.headers.set);
        }

        resp.write(jsonEncode(matchingRequest.value.data));
        await resp.close();
      } else {
        final resp = request.response..statusCode = HttpStatus.notImplemented;
        await resp.close();
      }
    }
  }

  Future<Map<String, dynamic>> serialize<TModel extends SupabaseModel>(
    TModel instance,
  ) async {
    final adapter = modelDictionary.adapterFor[TModel]!;
    return await adapter.toSupabase(
      instance,
      provider: SupabaseProvider(client, modelDictionary: modelDictionary),
      repository: null,
    );
  }

  /// Invoke within a group as `setUp(mock.setUp)`.
  ///
  /// It is critical to recreate the server for each test to ensure
  /// that there are no collisions from responses that were configured
  /// in prior tests.
  Future<void> setUp() async {
    server = await HttpServer.bind('localhost', 0);
    client = SupabaseClient(serverUrl, apiKey);
  }
}
