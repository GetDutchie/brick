import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:brick_offline_first_with_graphql/src/graphql_offline_queue_link.dart';
import 'package:brick_offline_first_with_graphql/src/graphql_request_sqlite_cache_manager.dart';
import 'package:brick_offline_first_with_graphql/src/offline_first_graphql_policy.dart';
import 'package:gql/language.dart';
import 'package:gql_exec/gql_exec.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:test/test.dart';

import '__helpers__.dart';

void main() {
  sqfliteFfiInit();

  const query = '''query UpsertPerson {
        upsertPerson {
          firstName
        }
      }''';

  const response = Response(
    data: <String, dynamic>{'firstName': 'Thomas'},
    response: {
      'body': <String, dynamic>{'firstName': 'Thomas'},
    },
  );

  final request = Request(
    operation: Operation(document: parseString(query), operationName: 'UpsertPerson'),
    variables: const <String, dynamic>{'firstName': 'Thomas'},
  );

  group('GraphqlOfflineQueueLink', () {
    final requestManager = GraphqlRequestSqliteCacheManager(
      inMemoryDatabasePath,
      databaseFactory: databaseFactoryFfi,
    );

    setUpAll(() async {
      await requestManager.migrate();
    });

    tearDown(() async {
      final requests = await requestManager.unprocessedRequests();
      final requestsToDelete = requests.map((request) {
        return requestManager.deleteUnprocessedRequest(request[GRAPHQL_JOBS_PRIMARY_KEY_COLUMN]);
      });

      await Future.wait(requestsToDelete);
    });

    test('verify link request made', () async {
      final mockLink = stubGraphqlLink({});
      final client = GraphqlOfflineQueueLink(requestManager).concat(mockLink);

      await client.request(request).first;

      verify(
        mockLink.request(request),
      ).called(1);
    });

    test('#send forwards to inner client', () async {
      final mockLink = MockLink();
      final client = GraphqlOfflineQueueLink(requestManager).concat(mockLink);

      when(
        mockLink.request(request),
      ).thenAnswer(
        (_) => Stream.fromIterable([response]),
      );

      expect(await client.request(request).first, response);
    });

    test('Query / Subscriptions are not tracked', () async {
      final mockLink = stubGraphqlLink({});
      final client = GraphqlOfflineQueueLink(requestManager).concat(mockLink);

      await client
          .request(
            Request(
              operation: Operation(
                document: parseString('''query {
                  helloWorld {
                    name
                  }
                }'''),
              ),
            ),
          )
          .first;
      expect(await requestManager.unprocessedRequests(), isEmpty);
    });

    test('request is stored in SQLite', () async {
      final mockLink = stubGraphqlLink({}, errors: ['Unavailable']);
      final client = GraphqlOfflineQueueLink(requestManager).concat(mockLink);

      await client
          .request(
            Request(
              operation: Operation(
                document: parseString('''mutation {}'''),
              ),
            ),
          )
          .first;
      expect(await requestManager.unprocessedRequests(), hasLength(1));
    });

    group('.shouldCache', () {
      test('mutations', () {
        final mutationRequest = Request(
          operation: Operation(
            document: parseString('''mutation {}'''),
          ),
        );
        expect(GraphqlOfflineQueueLink.shouldCache(mutationRequest), isTrue);
      });

      test('mutations with requireRemote policy are ignored', () {
        final context = const Context().withEntry<OfflineFirstGraphqlPolicy>(
          const OfflineFirstGraphqlPolicy(upsert: OfflineFirstUpsertPolicy.requireRemote),
        );
        final mutationRequest = Request(
          operation: Operation(
            document: parseString('''mutation {}'''),
          ),
          context: context,
        );
        expect(GraphqlOfflineQueueLink.shouldCache(mutationRequest), isFalse);
      });

      test('queries', () {
        final queryRequest = Request(
          operation: Operation(
            document: parseString('''query {}'''),
          ),
        );
        expect(GraphqlOfflineQueueLink.shouldCache(queryRequest), isFalse);
      });

      test('subscriptions', () {
        final subscriptionRequest = Request(
          operation: Operation(
            document: parseString('''subscription {}'''),
          ),
        );
        expect(GraphqlOfflineQueueLink.shouldCache(subscriptionRequest), isFalse);
      });
    });

    group('#onReattempt', () {
      test('callback is triggered when request retries', () async {
        Request? capturedRequest;

        final mockLink = stubGraphqlLink({}, errors: ['Test failure']);
        final client = GraphqlOfflineQueueLink(
          requestManager,
          onReattempt: (r) => capturedRequest = r,
        ).concat(mockLink);

        final mutationRequest = Request(
          operation: Operation(
            document: parseString('''mutation {}'''),
            operationName: 'fakeMutate',
          ),
        );
        await client.request(mutationRequest).first;

        expect(capturedRequest, isNotNull);
        expect(capturedRequest, mutationRequest);
      });

      test('callback is not triggered when request succeeds', () {
        Request? capturedRequest;

        final mockLink = MockLink();
        final client = GraphqlOfflineQueueLink(
          requestManager,
          onReattempt: (r) => capturedRequest = r,
        ).concat(mockLink);

        when(
          mockLink.request(request),
        ).thenAnswer(
          (_) => Stream.fromIterable([response]),
        );

        client.request(
          Request(
            operation: Operation(
              document: parseString('''mutation {}'''),
            ),
          ),
        );

        expect(capturedRequest, isNull);
      });
    });

    group('#onRequestException', () {
      test('callback is triggered for a failed response', () async {
        Request? capturedRequest;
        Object? capturedonException;

        final mockLink = stubGraphqlLink({}, errors: ['Test failure']);
        final client = GraphqlOfflineQueueLink(
          requestManager,
          onRequestException: (request, exception) {
            capturedRequest = request;
            capturedonException = exception;
          },
        ).concat(mockLink);

        final mutationRequest = Request(
          operation: Operation(
            document: parseString('''mutation {}'''),
            operationName: 'fakeMutate',
          ),
        );
        await client.request(mutationRequest).first;

        expect(capturedRequest, isNotNull);
        expect(capturedonException, isNotNull);
        expect(capturedonException.toString(), contains('Test failure'));
      });

      test('callback is not triggered on successful response', () {
        Request? capturedRequest;
        Object? capturedException;

        final mockLink = MockLink();
        final client = GraphqlOfflineQueueLink(
          requestManager,
          onRequestException: (request, exception) {
            capturedRequest = request;
            capturedException = exception;
          },
        ).concat(mockLink);

        when(
          mockLink.request(request),
        ).thenAnswer(
          (_) => Stream.fromIterable([response]),
        );

        client.request(
          Request(
            operation: Operation(
              document: parseString('''mutation {}'''),
            ),
          ),
        );

        expect(capturedRequest, isNull);
        expect(capturedException, isNull);
      });
    });

    test('request deletes after a successful response', () async {
      final mockLink = MockLink();
      final client = GraphqlOfflineQueueLink(requestManager).concat(mockLink);

      when(
        mockLink.request(request),
      ).thenAnswer(
        (_) => Stream.fromIterable([response]),
      );

      client.request(
        Request(
          operation: Operation(
            document: parseString('''mutation {}'''),
          ),
        ),
      );

      expect(await requestManager.unprocessedRequests(), isEmpty);
    });

    test('request increments after a unsuccessful response', () async {
      final mockLink = stubGraphqlLink({}, errors: ['Unsuccessful']);
      final client = GraphqlOfflineQueueLink(requestManager).concat(mockLink);

      final mutationRequest = Request(
        operation: Operation(
          document: parseString('''mutation {}'''),
          operationName: 'fakeMutate',
        ),
      );
      await client.request(mutationRequest).first;

      client.request(mutationRequest);

      var unprocessedRequests = await requestManager.unprocessedRequests();

      expect(unprocessedRequests.first[GRAPHQL_JOBS_ATTEMPTS_COLUMN], 1);

      await client.request(mutationRequest).first;

      unprocessedRequests = await requestManager.unprocessedRequests();
      expect(unprocessedRequests.first[GRAPHQL_JOBS_ATTEMPTS_COLUMN], 2);
    });

    test('request creates and does not delete after an unsuccessful response', () async {
      final mockLink = stubGraphqlLink({}, errors: ['Unknown error']);
      final client = GraphqlOfflineQueueLink(requestManager).concat(mockLink);

      final mutationRequest = Request(
        operation: Operation(
          document: parseString('''mutation {}'''),
          operationName: 'fakeMutate',
        ),
      );

      await client.request(mutationRequest).first;

      client.request(mutationRequest);

      expect(await requestManager.unprocessedRequests(), hasLength(1));
    });

    test('request is not deleted after sending to a misconfigured client', () async {
      final mockLink = stubGraphqlLink({}, errors: ['Misconfigured']);
      final client = GraphqlOfflineQueueLink(requestManager).concat(mockLink);

      const document = '''mutation {
            hello{
              hi
            }
          }''';
      final mutationRequest1 = Request(
        operation: Operation(
          document: parseString(document),
          operationName: 'fakeMutate',
        ),
      );

      final mutationRequest2 = Request(
        operation: Operation(
          document: parseString(document),
          operationName: 'fakeMutate',
        ),
        variables: const <String, dynamic>{'j': 16},
      );

      final mutationRequest3 = Request(
        operation: Operation(
          document: parseString(document),
          operationName: 'fakeMutate',
        ),
        variables: const <String, dynamic>{'k': 14},
      );

      await client.request(mutationRequest1).first;

      expect(await requestManager.unprocessedRequests(), hasLength(1));

      await client.request(mutationRequest2).first;

      expect(await requestManager.unprocessedRequests(), hasLength(2));

      await client.request(mutationRequest3).first;

      expect(await requestManager.unprocessedRequests(), hasLength(3));
    });
  });
}
