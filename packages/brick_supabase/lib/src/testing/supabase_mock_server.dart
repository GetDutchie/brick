import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:brick_core/core.dart';
import 'package:brick_supabase/src/supabase_model.dart';
import 'package:brick_supabase/src/supabase_model_dictionary.dart';
import 'package:brick_supabase/src/supabase_provider.dart';
import 'package:brick_supabase/src/testing/supabase_request.dart';
import 'package:brick_supabase/src/testing/supabase_response.dart';
import 'package:collection/collection.dart';
import 'package:supabase/supabase.dart';

/// An all-in-one mock for Supabase repsonses in unit tests.
class SupabaseMockServer {
  /// A mock Supabase API key. Can be a blank string.
  final String apiKey;

  /// A real SupabaseClient that does not connect to Supabase
  late SupabaseClient client;

  /// If a stream listener has been registered
  // ignore: omit_obvious_property_types
  bool hasListener = false;

  /// The active stream listener
  StreamSubscription<dynamic>? listener;

  /// Active stream listeners
  final Set<String> listeners = {};

  ///
  final SupabaseModelDictionary modelDictionary;

  /// The created and reassigned [HttpServer]
  late HttpServer server;

  /// The simulated server URL
  String get serverUrl => 'http://${server.address.host}:${server.port}';

  /// The stubbed websocket that can be listed to for streams
  WebSocket? webSocket;

  /// An all-in-one mock for Supabase repsonses in unit tests.
  SupabaseMockServer({this.apiKey = 'supabaseKey', required this.modelDictionary});

  /// Invoke within a group as `tearDown(mock.tearDown)`
  Future<void> tearDown() async {
    await client.dispose();
    await client.removeAllChannels();

    await listener?.cancel();

    hasListener = false;

    listeners.clear();

    await webSocket?.close();

    await server.close(force: true);
  }

  /// Invoke within a test block before any calls are made to a Supabase server
  // https://github.com/supabase/supabase-flutter/blob/main/packages/supabase/test/mock_test.dart#L21
  Future<void> handle(Map<SupabaseRequest, SupabaseResponse> responses) async {
    await for (final request in server) {
      final url = request.uri.toString();
      if (url.startsWith('/rest')) {
        final resp = handleRest(request, responses);
        await resp.close();
        // Borrowed from
        // https://github.com/supabase/supabase-flutter/blob/main/packages/supabase/test/mock_test.dart#L101-L202
      } else if (url.startsWith('/realtime')) {
        await handleRealtime(request, responses);
      }
    }
  }

  /// Handle realtime/stream requests
  Future<void> handleRealtime(
    HttpRequest request,
    Map<SupabaseRequest, SupabaseResponse> responses,
  ) async {
    webSocket = await WebSocketTransformer.upgrade(request);
    if (hasListener) {
      return;
    }
    hasListener = true;

    listener = webSocket!.listen((req) async {
      /// `filter` might be there or not depending on whether is a filter set
      /// to the realtime subscription, so include the filter if the request
      /// includes a filter.
      final requestJson = jsonDecode(req);
      final topic = requestJson['topic'];
      final ref = requestJson['ref'];

      if (requestJson['event'] == 'phx_leave') {
        listeners.remove(topic);
        return;
      }

      if (listeners.contains(topic)) return;
      listeners.add(topic);

      final realtimeFilter = requestJson['payload']['config']['postgres_changes'].first['filter'];

      final matching = responses.entries
          .firstWhereOrNull((r) => r.key.realtime && realtimeFilter == r.key.filter);

      if (matching == null) return;

      if (requestJson['payload']['config']['postgres_changes'].first['event'] != '*') {
        final replyString = jsonEncode({
          'event': 'phx_reply',
          'payload': {
            'response': {
              'postgres_changes': matching.value.flattenedResponses.map((r) {
                final data = Map<String, dynamic>.from(r.data as Map);

                return {
                  'id': data['payload']['ids'][0],
                  'event': data['payload']['data']['type'],
                  'schema': data['payload']['data']['schema'],
                  'table': data['payload']['data']['table'],
                  if (realtimeFilter != null) 'filter': realtimeFilter,
                };
              }).toList(),
            },
            'status': 'ok',
          },
          'ref': ref,
          'topic': topic,
        });
        webSocket!.add(replyString);
      }

      for (final realtimeResponses in matching.value.flattenedResponses) {
        await Future.delayed(matching.value.realtimeSubsequentReplyDelay);
        final data = Map<String, dynamic>.from(realtimeResponses.data as Map);
        final serialized = jsonEncode({...data, 'topic': topic});
        webSocket!.add(serialized);
      }
    });
  }

  /// Handle regular REST requests
  HttpResponse handleRest(HttpRequest request, Map<SupabaseRequest, SupabaseResponse> responses) {
    final url = request.uri.toString();

    final matchingRequest = responses.entries.firstWhereOrNull((r) {
      if (r.key.realtime) return false;
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

    if (matchingRequest == null) {
      return request.response..statusCode = HttpStatus.notImplemented;
    }

    final resp = request.response
      ..statusCode = HttpStatus.ok
      ..headers.contentType = ContentType.json;
    if (matchingRequest.value.headers != null) {
      matchingRequest.value.headers!.forEach(resp.headers.set);
    }

    if (matchingRequest.value.data is List) {
      resp.write(jsonEncode(matchingRequest.value.data));
      // Handle realtime responses with an empty payload
      // so that initial subscribes will not start with a hydrate
    } else if (matchingRequest.value.data is Map) {
      final asMap = Map<String, dynamic>.from(matchingRequest.value.data);
      if (asMap.containsKey('payload') && asMap['payload'] != null) {
        resp.write(jsonEncode([]));
      } else {
        resp.write(jsonEncode(matchingRequest.value.data));
      }
    }
    return resp;
  }

  /// Convert a model to a Supabase response.
  ///
  /// For realtime responses, include the `realtimeEvent` argument.
  Future<Map<String, dynamic>> serialize<TModel extends SupabaseModel>(
    TModel instance, {
    String? realtimeFilter,
    String? schema = 'public',
    PostgresChangeEvent? realtimeEvent,
    ModelRepository<SupabaseModel>? repository,
  }) async {
    assert(realtimeEvent != PostgresChangeEvent.all, '.all events are not serialized');

    final adapter = modelDictionary.adapterFor[TModel]!;
    final serialized = await adapter.toSupabase(
      instance,
      provider: SupabaseProvider(client, modelDictionary: modelDictionary),
      repository: repository,
    );

    if (realtimeEvent == null) return serialized;

    // Delete records from realtime are strictly unique/indexed fields;
    // uniqueness is not tracked by [RuntimeSupabaseColumnDefinition]
    // so filtering out associations is the closest simulation of an incomplete payload
    //
    // Associations are not provided by insert/update either
    for (final value in adapter.fieldsToSupabaseColumns.values) {
      if (value.association) serialized.remove(value.columnName);
    }

    return {
      'ref': null,
      'event': 'postgres_changes',
      'payload': {
        'ids': [realtimeEvent.index],
        'data': {
          'columns': adapter.fieldsToSupabaseColumns.entries
              .map(
                (entry) =>
                    {'name': entry.value.columnName, 'type': 'text', 'type_modifier': 4294967295},
              )
              .toList(),
          'commit_timestamp': '2021-08-01T08:00:30Z',
          'errors': null,
          if (realtimeEvent != PostgresChangeEvent.insert) 'old_record': serialized,
          if (realtimeEvent != PostgresChangeEvent.delete) 'record': serialized,
          'schema': schema,
          'table': adapter.supabaseTableName,
          'type': realtimeEvent.name.toUpperCase(),
          if (realtimeFilter != null) 'filter': realtimeFilter,
        },
      },
    };
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
