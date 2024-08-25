// ignore_for_file: unawaited_futures

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:brick_supabase/src/supabase_provider.dart';
import 'package:supabase/supabase.dart';
import 'package:test/test.dart';

import '__mocks__.dart';

String _buildUrl(
  String tableName,
  String method, {
  required String fields,
  String? filter,
  int? limit,
}) {
  return '/rest/v1/$tableName${filter != null ? '?$filter&' : '?'}$method=${Uri.encodeComponent(fields)}${limit != null ? '&limit=$limit' : ''}';
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
    test('#delete', () async {
      handleRequests(
        mockServer,
        matchingUrl:
            _buildUrl('demos', 'select', fields: 'id,name,age', filter: 'id=eq.1', limit: 1),
        matchingRequestMethod: 'DELETE',
        response: {'id': '1', 'name': 'Demo 1'},
      );
      final provider = SupabaseProvider(supabase, modelDictionary: supabaseModelDictionary);
      final didDelete =
          await provider.delete<DemoModel>(DemoModel(age: 1, name: 'Demo 1', id: '1'));
      expect(didDelete, true);
    });

    test('#exists', () async {
      handleRequests(
        mockServer,
        matchingUrl: _buildUrl('demos', 'select', fields: 'id,name,age'),
        response: [
          {'id': '1', 'name': 'Demo 1', 'age': 1},
        ],
        responseHeaders: {'content-range': '*/1'},
      );
      final provider = SupabaseProvider(supabase, modelDictionary: supabaseModelDictionary);
      final doesExist = await provider.exists<DemoModel>();
      expect(doesExist, true);
    });

    test('#get', () async {
      handleRequests(
        mockServer,
        matchingUrl: _buildUrl('demos', 'select', fields: 'id,name,age'),
        matchingRequestMethod: 'GET',
        response: [
          {'id': '1', 'name': 'Demo 1', 'age': 1},
          {'id': '2', 'name': 'Demo 2', 'age': 2},
        ],
      );
      final provider = SupabaseProvider(supabase, modelDictionary: supabaseModelDictionary);
      final retrieved = await provider.get<DemoModel>();
      expect(retrieved, hasLength(2));
      expect(retrieved[0].id, '1');
      expect(retrieved[1].id, '2');
      expect(retrieved[0].name, 'Demo 1');
      expect(retrieved[1].name, 'Demo 2');
      expect(retrieved[0].age, 1);
      expect(retrieved[1].age, 2);
    });

    test('#upsert', () async {
      handleRequests(
        mockServer,
        matchingUrl:
            _buildUrl('demos', 'select', fields: 'id,name,age', filter: 'id=eq.1', limit: 1),
        matchingRequestMethod: 'POST',
        response: {'id': '1', 'name': 'Demo 1', 'age': 1},
      );
      final provider = SupabaseProvider(supabase, modelDictionary: supabaseModelDictionary);
      final instance = DemoModel(age: 1, name: 'Demo 1', id: '1');
      final inserted = await provider.upsert<DemoModel>(instance);
      expect(inserted.id, instance.id);
      expect(inserted.age, instance.age);
      expect(inserted.name, instance.name);
    });
  });
}
