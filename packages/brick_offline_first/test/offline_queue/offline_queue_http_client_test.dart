import 'package:brick_offline_first/src/offline_queue/request_sqlite_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../lib/src/offline_queue/offline_queue_http_client.dart';

class MockOfflineClient extends Mock implements OfflineQueueHttpClient {}

class MockClient extends Mock implements http.Client {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  group('OfflineQueueHttpClient', () {
    final requestManager = RequestSqliteCacheManager(
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

    test('#send forwards to inner client', () async {
      final inner = stubResult(response: 'hello from inner');
      final client = OfflineQueueHttpClient(inner, requestManager);

      final resp = await client.get('http://localhost:3000');
      expect(resp.body, 'hello from inner');
    });

    test('GET requests are not tracked', () async {
      final inner = stubResult(statusCode: 404);
      final client = OfflineQueueHttpClient(inner, requestManager);
      await client.get('http://localhost:3000');

      expect(await requestManager.unprocessedRequests(), isEmpty);
    });

    test('request is stored in SQLite', () async {
      final inner = stubResult(statusCode: 501);
      final client = OfflineQueueHttpClient(inner, requestManager);
      final resp = await client.post('http://localhost:3000', body: 'new record');

      expect(resp.statusCode, 501);
      expect(await requestManager.unprocessedRequests(), hasLength(1));
    });

    test('request deletes after a successful response', () async {
      final inner = stubResult(requestBody: 'existing record');
      final client = OfflineQueueHttpClient(inner, requestManager);
      final resp = await client.post('http://localhost:3000', body: 'existing record');

      expect(await requestManager.unprocessedRequests(), isEmpty);
      expect(resp.statusCode, 200);
    });

    test('request increments after a unsuccessful response', () async {
      final inner = stubResult(requestBody: 'existing record', statusCode: 501);
      final client = OfflineQueueHttpClient(inner, requestManager);
      await client.post('http://localhost:3000', body: 'existing record');
      var requests = await requestManager.unprocessedRequests();

      expect(requests.first[HTTP_JOBS_ATTEMPTS_COLUMN], 1);

      final resp = await client.post('http://localhost:3000', body: 'existing record');
      requests = await requestManager.unprocessedRequests();
      expect(requests.first[HTTP_JOBS_ATTEMPTS_COLUMN], 2);

      expect(resp.statusCode, 501);
    });

    test('request creates and does not delete after an unsuccessful response', () async {
      final inner = MockClient();
      when(inner.send(any)).thenThrow(StateError('server not found'));

      final client = OfflineQueueHttpClient(inner, requestManager);
      final resp = await client.post('http://localhost:3000', body: 'existing record');

      expect(await requestManager.unprocessedRequests(), hasLength(1));
      expect(resp.statusCode, 501);
    });

    test('request is not deleted after sending to a misconfigured client', () async {
      final inner = MockClient();

      final client = OfflineQueueHttpClient(inner, requestManager);
      final resp = await client.post('http://localhost:3000', body: 'existing record');

      expect(await requestManager.unprocessedRequests(), hasLength(1));
      expect(resp.statusCode, 501);
    });

    test('request is not deleted after sending to an inaccessible endpoint', () async {
      final body = 'Tunnel http://localhost:3000 not found';
      final inner = stubResult(response: body, statusCode: 404);
      final client = OfflineQueueHttpClient(inner, requestManager);

      final resp = await client.post('http://localhost:3000', body: 'new record');
      expect(await requestManager.unprocessedRequests(), hasLength(1));
      expect(resp.statusCode, 404);
      expect(resp.body, body);

      await client.put('http://localhost:3000', body: 'new record');
      expect(await requestManager.unprocessedRequests(), hasLength(2));

      await client.delete('http://localhost:3000');
      expect(await requestManager.unprocessedRequests(), hasLength(3));

      await client.patch('http://localhost:3000', body: 'new record');
      expect(await requestManager.unprocessedRequests(), hasLength(4));
    });

    test('request is not deleted after receiving a status code that should be reattempted',
        () async {
      final body = 'Too many requests';
      final inner = stubResult(response: body, statusCode: 429);
      final client = OfflineQueueHttpClient(inner, requestManager, reattemptForStatusCodes: [429]);

      final resp = await client.post('http://localhost:3000', body: 'new record');
      expect(await requestManager.unprocessedRequests(), hasLength(1));
      expect(resp.statusCode, 429);
      expect(resp.body, body);

      await client.put('http://localhost:3000', body: 'new record');
      expect(await requestManager.unprocessedRequests(), hasLength(2));

      await client.delete('http://localhost:3000');
      expect(await requestManager.unprocessedRequests(), hasLength(3));

      await client.patch('http://localhost:3000', body: 'new record');
      expect(await requestManager.unprocessedRequests(), hasLength(4));
    });

    test(".isATunnelNotFoundResponse", () async {
      final body = 'Tunnel http://localhost:3000 not found';
      final inner = stubResult(response: body, statusCode: 404);
      final client = OfflineQueueHttpClient(inner, requestManager);
      final resp = await client.put('http://localhost:3000', body: 'new record');
      expect(OfflineQueueHttpClient.isATunnelNotFoundResponse(resp), isTrue);
    });
  });
}

MockClient stubResult({String response = 'response', int statusCode, String requestBody}) {
  final inner = MockClient();

  when(inner.send(any)).thenAnswer((_) {
    return Future.value(_buildStreamedResponse(response, statusCode, requestBody));
  });

  return inner;
}

/// Useful for mocking a response to [http.Client]'s `#send` method
http.StreamedResponse _buildStreamedResponse(String response,
    [int statusCode, String requestBody]) {
  statusCode ??= 200;

  // args don't matter,
  final request = http.Request("POST", Uri.parse("http://localhost:3000"));
  request.body = requestBody ?? response;

  final resp = http.Response(response, statusCode, request: request);
  final stream = Stream.fromFuture(Future.value(resp.bodyBytes));
  return http.StreamedResponse(
    stream,
    resp.statusCode,
    request: resp.request,
    headers: resp.headers,
    isRedirect: resp.isRedirect,
    reasonPhrase: resp.reasonPhrase,
  );
}
