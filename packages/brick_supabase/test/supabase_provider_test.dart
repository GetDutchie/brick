// ignore_for_file: unawaited_futures

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:brick_supabase/src/supabase_provider.dart';
import 'package:collection/collection.dart';
import 'package:supabase/supabase.dart';
import 'package:test/test.dart';

import '__mocks__.dart';

class _SupabaseRequest {
  final String method;
  final String? requestMethod;
  final String tableName;
  final String fields;
  final String? filter;
  final int? limit;

  _SupabaseRequest(
    this.tableName, {
    this.method = 'select',
    this.requestMethod = 'GET',
    required this.fields,
    this.filter,
    this.limit,
  });

  @override
  String toString() =>
      '/rest/v1/$tableName${filter != null ? '?$filter&' : '?'}$method=${Uri.encodeComponent(fields)}${limit != null ? '&limit=$limit' : ''}';

  Uri get uri => Uri.parse(toString());
}

class _SupabaseResponse {
  final dynamic data;
  final Map<String, String>? headers;

  _SupabaseResponse(this.data, [this.headers]);
}

void main() {
  late SupabaseClient supabase;
  late HttpServer mockServer;
  const apiKey = 'supabaseKey';

  // https://github.com/supabase/supabase-flutter/blob/main/packages/supabase/test/mock_test.dart#L21
  Future<void> handleRequests(
    HttpServer server,
    Map<_SupabaseRequest, _SupabaseResponse> responses,
  ) async {
    await for (final HttpRequest request in server) {
      final matchingRequest = responses.entries.firstWhereOrNull((r) {
        final url = request.uri.toString();
        final matchesRequestMethod =
            r.key.requestMethod == request.method || r.key.requestMethod == null;
        final matchesPath = request.uri.path == r.key.uri.path;
        var matchesQuery = true;
        for (final param in r.key.uri.queryParameters.entries) {
          if (!request.uri.queryParameters.containsKey(param.key) ||
              param.value != request.uri.queryParameters[param.key]) {
            matchesQuery = false;
            break;
          }
        }
        return r.key.toString() == url || (matchesRequestMethod && matchesPath && matchesQuery);
      });

      if (matchingRequest != null) {
        final resp = request.response
          ..statusCode = HttpStatus.ok
          ..headers.contentType = ContentType.json;
        if (matchingRequest.value.headers != null) {
          matchingRequest.value.headers!.forEach((key, value) {
            resp.headers.set(key, value);
          });
        }

        resp.write(jsonEncode(matchingRequest.value.data));
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
      final req = _SupabaseRequest(
        'demos',
        requestMethod: 'DELETE',
        fields: 'id,name,age',
        filter: 'id=eq.1',
        limit: 1,
      );
      final resp = _SupabaseResponse({'id': '1', 'name': 'Demo 1'});

      handleRequests(mockServer, {req: resp});
      final provider = SupabaseProvider(supabase, modelDictionary: supabaseModelDictionary);
      final didDelete =
          await provider.delete<DemoModel>(DemoModel(age: 1, name: 'Demo 1', id: '1'));
      expect(didDelete, true);
    });

    test('#exists', () async {
      final req = _SupabaseRequest(
        'demos',
        fields: 'id,name,age',
      );
      final resp = _SupabaseResponse([
        {'id': '1', 'name': 'Demo 1', 'age': 1},
      ], {
        'content-range': '*/1',
      });

      handleRequests(mockServer, {req: resp});
      final provider = SupabaseProvider(supabase, modelDictionary: supabaseModelDictionary);
      final doesExist = await provider.exists<DemoModel>();
      expect(doesExist, true);
    });

    test('#get', () async {
      final req = _SupabaseRequest(
        'demos',
        fields: 'id,name,age',
      );
      final resp = _SupabaseResponse([
        {'id': '1', 'name': 'Demo 1', 'age': 1},
        {'id': '2', 'name': 'Demo 2', 'age': 2},
      ]);
      handleRequests(mockServer, {req: resp});
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

    group('#upsert', () {
      test('no associations', () async {
        final req = _SupabaseRequest(
          'demos',
          requestMethod: 'POST',
          fields: 'id,name,age',
          filter: 'id=eq.1',
          limit: 1,
        );
        final resp = _SupabaseResponse(
          {'id': '1', 'name': 'Demo 1', 'age': 1},
        );
        handleRequests(mockServer, {req: resp});

        final provider = SupabaseProvider(supabase, modelDictionary: supabaseModelDictionary);
        final instance = DemoModel(age: 1, name: 'Demo 1', id: '1');
        final inserted = await provider.upsert<DemoModel>(instance);
        expect(inserted.id, instance.id);
        expect(inserted.age, instance.age);
        expect(inserted.name, instance.name);
      });

      test('one association', () async {
        final demoModelReq = _SupabaseRequest(
          'demos',
          requestMethod: 'POST',
          fields: 'id,name,age',
          filter: 'id=eq.2',
          limit: 1,
        );
        final demoModelResp = _SupabaseResponse(
          {'id': '1', 'name': 'Demo 1', 'age': 1},
        );
        final assocReq = _SupabaseRequest(
          'demo_associations',
          requestMethod: 'POST',
          fields: 'id,name,assoc:demos!assoc_id(id,name,age),assocs:demos!assocs_id(id,name,age)',
          filter: 'id=eq.1',
          limit: 1,
        );
        final assocResp = _SupabaseResponse(
          {
            'id': '1',
            'name': 'Demo 1',
            'age': 1,
            'assoc': {'id': '2', 'name': 'Nested', 'age': 1},
          },
        );
        handleRequests(mockServer, {demoModelReq: demoModelResp, assocReq: assocResp});

        final provider = SupabaseProvider(supabase, modelDictionary: supabaseModelDictionary);
        final instance = DemoAssociationModel(
          assoc: DemoModel(age: 1, name: 'Nested', id: '2'),
          name: 'Demo 1',
          id: '1',
        );
        final inserted = await provider.upsert<DemoAssociationModel>(instance);
        expect(inserted.id, instance.id);
        expect(inserted.assoc.age, instance.assoc.age);
        expect(inserted.assoc.id, instance.assoc.id);
        expect(inserted.name, instance.name);
      });
    });
  });
}
