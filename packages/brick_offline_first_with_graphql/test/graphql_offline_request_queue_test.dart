import 'dart:async';

import 'package:brick_offline_first_with_graphql/src/graphql_offline_queue_link.dart';
import 'package:brick_offline_first_with_graphql/src/graphql_offline_request_queue.dart';
import 'package:brick_offline_first_with_graphql/src/graphql_request_sqlite_cache_manager.dart';
import 'package:gql_exec/gql_exec.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:test/test.dart';

import '__helpers__.dart';

void main() {
  final offlineClient = GraphqlOfflineQueueLink(
    GraphqlRequestSqliteCacheManager('db', databaseFactory: databaseFactoryFfi),
  );

  group('GraphqlOfflineRequestQueue', () {
    final requestManager = GraphqlRequestSqliteCacheManager(
      inMemoryDatabasePath,
      databaseFactory: databaseFactoryFfi,
    );

    group('Queue Lifecycle', () {
      test('#start', () {
        final queue = GraphqlOfflineRequestQueue(
          link: offlineClient,
          requestManager: requestManager,
        )..start();
        expect(queue.isRunning, isTrue);
        queue.stop();
      });

      test('#stop', () {
        final queue = GraphqlOfflineRequestQueue(
          link: offlineClient,
          requestManager: requestManager,
        )..start();
        expect(queue.isRunning, isTrue);
        queue.stop();
        expect(queue.isRunning, isFalse);
      });
    });

    group('Request Processing', () {
      test('#transmitRequest', () async {
        final mockLink = MockLink();
        var streamConsumed = false;

        when(mockLink.request(any)).thenAnswer((_) {
          return Stream<Response>.eventTransformed(
            Stream.fromIterable([
              const Response(
                data: {'test': 'data'},
                response: {'body': '{"test":"data"}'},
              ),
            ]),
            (sink) {
              streamConsumed = true;
              return sink;
            },
          );
        });

        final testQueue = GraphqlOfflineRequestQueue(
          link: mockLink,
          requestManager: requestManager,
        );

        final testRequest = Request(
          operation: Operation(
            document: gql('mutation TestMutation { test }'),
          ),
        );

        await testQueue.transmitRequest(testRequest);

        expect(streamConsumed, isTrue);
      });

      test('#transmitRequest with errors', () async {
        final mockLink = MockLink();
        when(mockLink.request(any)).thenAnswer(
          (_) => Stream.error(Exception('Network error')),
        );

        final testQueue = GraphqlOfflineRequestQueue(
          link: mockLink,
          requestManager: requestManager,
        );

        final testRequest = Request(
          operation: Operation(
            document: gql('mutation TestMutation { test }'),
          ),
        );

        expect(
          () => testQueue.transmitRequest(testRequest),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
