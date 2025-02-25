import 'dart:io';

import 'package:brick_offline_first_with_rest/src/offline_queue/rest_offline_queue_client.dart';
import 'package:brick_offline_first_with_rest/src/offline_queue/rest_request_sqlite_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:test/test.dart';

import '__helpers__.dart';

void main() {
  sqfliteFfiInit();

  group('RestOfflineQueueClient', () {
    final requestManager = RestRequestSqliteCacheManager(
      inMemoryDatabasePath,
      databaseFactory: databaseFactoryFfi,
    );

    setUpAll(() async {
      await requestManager.migrate();
    });

    tearDown(() async {
      final requests = await requestManager.unprocessedRequests();
      final requestsToDelete = requests.map((request) {
        return requestManager.deleteUnprocessedRequest(request[HTTP_JOBS_PRIMARY_KEY_COLUMN]);
      });

      await Future.wait(requestsToDelete);
    });

    group('#send', () {
      test('forwards to inner client', () async {
        final inner = stubResult(response: 'hello from inner');
        final client = RestOfflineQueueClient(inner, requestManager);

        final resp = await client.get(Uri.parse('http://0.0.0.0:3000'));
        expect(resp.body, 'hello from inner');
      });

      test('request is stored in SQLite', () async {
        final inner = stubResult(statusCode: 501);
        final client = RestOfflineQueueClient(inner, requestManager);
        final resp = await client.post(Uri.parse('http://0.0.0.0:3000'), body: 'new record');

        expect(resp.statusCode, 501);
        expect(await requestManager.unprocessedRequests(), hasLength(1));
      });

      test('request deletes after a successful response', () async {
        final inner = stubResult();
        final client = RestOfflineQueueClient(inner, requestManager);
        final resp = await client.post(Uri.parse('http://0.0.0.0:3000'), body: 'existing record');

        expect(await requestManager.unprocessedRequests(), isEmpty);
        expect(resp.statusCode, 200);
      });

      test('request increments after a unsuccessful response', () async {
        final inner = stubResult(statusCode: 501);
        final client = RestOfflineQueueClient(inner, requestManager);
        await client.post(Uri.parse('http://0.0.0.0:3000'), body: 'existing record');
        var requests = await requestManager.unprocessedRequests();

        expect(requests.first[HTTP_JOBS_ATTEMPTS_COLUMN], 1);

        final resp = await client.post(Uri.parse('http://0.0.0.0:3000'), body: 'existing record');
        requests = await requestManager.unprocessedRequests();
        expect(requests.first[HTTP_JOBS_ATTEMPTS_COLUMN], 2);

        expect(resp.statusCode, 501);
      });

      test('GET requests are not tracked', () async {
        final inner = stubResult(statusCode: 404);
        final client = RestOfflineQueueClient(inner, requestManager);
        await client.get(Uri.parse('http://0.0.0.0:3000'));

        expect(await requestManager.unprocessedRequests(), isEmpty);
      });

      test('${RestOfflineQueueClient.policyHeader} requireRemote requests are not tracked',
          () async {
        final inner = stubResult(statusCode: 404);
        final client = RestOfflineQueueClient(inner, requestManager);
        await client.post(
          Uri.parse('http://0.0.0.0:3000'),
          body: 'new record',
          headers: {RestOfflineQueueClient.policyHeader: 'requireRemote'},
        );

        expect(await requestManager.unprocessedRequests(), isEmpty);
      });

      test('ignored path is not not tracked', () async {
        final inner = stubResult(statusCode: 404);
        final client =
            RestOfflineQueueClient(inner, requestManager, ignorePaths: {'/ignored-path'});
        await client.post(
          Uri.parse('http://0.0.0.0:3000/ignored-path'),
          body: 'new record',
        );

        expect(await requestManager.unprocessedRequests(), isEmpty);

        final multiplePaths = RestOfflineQueueClient(
          inner,
          requestManager,
          ignorePaths: {'/ignored-path', '/other-path'},
        );
        await multiplePaths.post(
          Uri.parse('http://0.0.0.0:3000/other-path'),
          body: 'new record',
        );

        expect(await requestManager.unprocessedRequests(), isEmpty);

        final nestedPath =
            RestOfflineQueueClient(inner, requestManager, ignorePaths: {'/v1/ignored-path'});
        await nestedPath.post(
          Uri.parse('http://0.0.0.0:3000/v1/ignored-path'),
          body: 'new record',
        );

        expect(await requestManager.unprocessedRequests(), isEmpty);
      });

      group('request is not deleted', () {
        test('after an unsuccessful response and is created', () async {
          final inner = MockClient((req) {
            throw StateError('server not found');
          });

          final client = RestOfflineQueueClient(inner, requestManager);
          final resp = await client.post(Uri.parse('http://0.0.0.0:3000'), body: 'existing record');

          expect(await requestManager.unprocessedRequests(), hasLength(1));
          expect(resp.statusCode, 501);
        });

        test('after sending to a misconfigured client', () async {
          final inner = stubResult(statusCode: 501);

          final client = RestOfflineQueueClient(inner, requestManager);
          final resp = await client.post(Uri.parse('http://0.0.0.0:3000'), body: 'existing record');

          expect(await requestManager.unprocessedRequests(), hasLength(1));
          expect(resp.statusCode, 501);
        });

        test('after sending to an inaccessible endpoint', () async {
          const body = 'Tunnel http://0.0.0.0:3000 not found';
          final inner = stubResult(response: body, statusCode: 404);
          final client = RestOfflineQueueClient(inner, requestManager);

          final resp = await client.post(Uri.parse('http://0.0.0.0:3000'), body: 'new record');
          expect(await requestManager.unprocessedRequests(), hasLength(1));
          expect(resp.statusCode, 404);
          expect(resp.body, body);

          await client.put(Uri.parse('http://0.0.0.0:3000'), body: 'new record');
          expect(await requestManager.unprocessedRequests(), hasLength(2));

          await client.delete(Uri.parse('http://0.0.0.0:3000'));
          expect(await requestManager.unprocessedRequests(), hasLength(3));

          await client.patch(Uri.parse('http://0.0.0.0:3000'), body: 'new record');
          expect(await requestManager.unprocessedRequests(), hasLength(4));
        });

        test('after receiving a status code that should be reattempted', () async {
          const body = 'Too many requests';
          final inner = stubResult(response: body, statusCode: 429);
          final client =
              RestOfflineQueueClient(inner, requestManager, reattemptForStatusCodes: [429]);

          final resp = await client.post(Uri.parse('http://0.0.0.0:3000'), body: 'new record');
          expect(await requestManager.unprocessedRequests(), hasLength(1));
          expect(resp.statusCode, 429);
          expect(resp.body, body);

          await client.put(Uri.parse('http://0.0.0.0:3000'), body: 'new record');
          expect(await requestManager.unprocessedRequests(), hasLength(2));

          await client.delete(Uri.parse('http://0.0.0.0:3000'));
          expect(await requestManager.unprocessedRequests(), hasLength(3));

          await client.patch(Uri.parse('http://0.0.0.0:3000'), body: 'new record');
          expect(await requestManager.unprocessedRequests(), hasLength(4));
        });

        test('onReattempt callback is triggered for reattemptable status code', () async {
          http.Request? capturedRequest;
          int? capturedStatusCode;

          final inner = stubResult(statusCode: 429);
          final client = RestOfflineQueueClient(
            inner,
            requestManager,
            reattemptForStatusCodes: [429],
            onReattempt: (request, statusCode) {
              capturedRequest = request;
              capturedStatusCode = statusCode;
            },
          );

          final uri = Uri.parse('http://0.0.0.0:3000');

          await client.post(uri, body: 'test');

          expect(capturedRequest?.method, equals('POST'));
          expect(capturedRequest?.url, equals(uri));
          expect(capturedStatusCode, equals(429));
        });

        test('onReattempt is not triggered for non-reattemptable status code', () async {
          var callbackTriggered = false;

          final inner = stubResult(statusCode: 404);
          final client = RestOfflineQueueClient(
            inner,
            requestManager,
            reattemptForStatusCodes: [429],
            onReattempt: (request, statusCode) {
              callbackTriggered = true;
            },
          );

          await client.post(Uri.parse('http://0.0.0.0:3000'), body: 'test');

          expect(callbackTriggered, isFalse);
        });

        test('onRequestException callback is triggered for SocketException', () async {
          http.Request? capturedRequest;
          Object? capturedException;

          final inner = MockClient((req) {
            throw const SocketException('test error');
          });

          final client = RestOfflineQueueClient(
            inner,
            requestManager,
            onRequestException: (request, exception) {
              capturedRequest = request;
              capturedException = exception;
            },
          );

          final uri = Uri.parse('http://0.0.0.0:3000');

          await client.post(uri, body: 'test');

          expect(capturedRequest?.method, equals('POST'));
          expect(capturedRequest?.url, equals(uri));
          expect(capturedException, isA<SocketException>());
          expect((capturedException! as SocketException).message, equals('test error'));
        });

        test('onRequestException is not triggered for successful request', () async {
          var callbackTriggered = false;

          final inner = stubResult(statusCode: 200);
          final client = RestOfflineQueueClient(
            inner,
            requestManager,
            onRequestException: (request, exception) {
              callbackTriggered = true;
            },
          );

          await client.post(Uri.parse('http://0.0.0.0:3000'), body: 'test');

          expect(callbackTriggered, isFalse);
        });
      });
    });

    test('.isATunnelNotFoundResponse', () async {
      const body = 'Tunnel http://0.0.0.0:3000 not found';
      final inner = stubResult(response: body, statusCode: 404);
      final client = RestOfflineQueueClient(inner, requestManager);
      final resp = await client.put(Uri.parse('http://0.0.0.0:3000'), body: 'new record');
      expect(RestOfflineQueueClient.isATunnelNotFoundResponse(resp), isTrue);
    });
  });
}
