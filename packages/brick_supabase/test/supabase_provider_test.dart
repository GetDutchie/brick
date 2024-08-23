// ignore_for_file: unawaited_futures

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:brick_supabase/src/supabase_provider.dart';
import 'package:supabase/supabase.dart';
import 'package:test/test.dart';

import '__mocks__.dart';

String _buildUrl(String tableName, String method, {required String fields, String? filter}) {
  return '/rest/v1/$tableName?$method=${Uri.encodeComponent(fields)}${filter != null ? '&$filter' : ''}';
}

void main() {
  late SupabaseClient supabase;
  late HttpServer mockServer;
  const apiKey = 'supabaseKey';

  // https://github.com/supabase/supabase-flutter/blob/main/packages/supabase/test/mock_test.dart#L21
  Future<void> handleRequests(
    HttpServer server, {
    String? matchingUrl,
    String? matchingRequestMethod,
    dynamic response,
    Map<String, String>? responseHeaders,
  }) async {
    await for (final HttpRequest request in server) {
      final url = request.uri.toString();
      final matchesRequestUrl = matchingUrl == url || matchingUrl == null;
      final matchesRequestMethod =
          matchingRequestMethod == request.method || matchingRequestMethod == null;

      if (matchesRequestMethod && matchesRequestUrl) {
        final resp = request.response
          ..statusCode = HttpStatus.ok
          ..headers.contentType = ContentType.json;
        if (responseHeaders != null) {
          responseHeaders.forEach((key, value) {
            resp.headers.set(key, value);
          });
        }
        resp.write(jsonEncode(response));
        await resp.close();
      } else {
        final resp = request.response..statusCode = HttpStatus.notImplemented;
        await resp.close();
      }
    }
  }

  setUp(() async {
    mockServer = await HttpServer.bind('localhost', 0);
    supabase = SupabaseClient(
      'http://${mockServer.address.host}:${mockServer.port}',
      apiKey,
    );
  });

  tearDown(() async {
    await supabase.dispose();
    await supabase.removeAllChannels();
    await mockServer.close(force: true);
  });

  group('SupabaseProvider', () {
    test('#delete', () {}, skip: true);

    test('#exists', () async {
      handleRequests(
        mockServer,
        matchingUrl: _buildUrl('demos', 'select', fields: 'id,name'),
        response: [
          {'id': '1', 'name': 'Demo 1'},
        ],
        responseHeaders: {'content-range': '*/1'},
      );
      final provider = SupabaseProvider(supabase, modelDictionary: supabaseModelDictionary);
      final doesExist = await provider.exists<DemoModel>();
      expect(doesExist, true);
    });

    test('#get', () {}, skip: true);

    test('#upsert', () {}, skip: true);
  });
}
