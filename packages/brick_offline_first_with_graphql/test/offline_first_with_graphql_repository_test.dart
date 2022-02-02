import 'package:brick_core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '__helpers__.dart';
import 'test_domain/__mocks__.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  group('OfflineFirstWithGraphqlRepository', () {
    group('#subscribe', () {
      test('adds controller and query to #subscriptions', () {
        final repository = TestRepository.configure(link: stubGraphqlLink({}));
        expect(repository.subscriptions, hasLength(0));
        final query = Query.where('name', 'Thomas');
        repository.subscribe<Mounty>(query: query);
        expect(repository.subscriptions, hasLength(1));
        expect(repository.subscriptions[Mounty], hasLength(1));
        expect(repository.subscriptions[Mounty]!.entries.first.key, query);
        expect(repository.subscriptions[Mounty]!.entries.first.value, isNotNull);
      });

      test('adds controller and null query to #subscriptions', () {
        final repository = TestRepository.configure(link: stubGraphqlLink({}));
        expect(repository.subscriptions, hasLength(0));
        repository.subscribe<Mounty>();
        expect(repository.subscriptions, hasLength(1));
        expect(repository.subscriptions[Mounty], hasLength(1));
        expect(repository.subscriptions[Mounty]!.entries.first.key, isNull);
        expect(repository.subscriptions[Mounty]!.entries.first.value, isNotNull);
      });

      test('cancelling removes from #subscriptions', () async {
        final repository = TestRepository.configure(link: stubGraphqlLink({}));
        await repository.initialize();
        expect(repository.subscriptions, hasLength(0));
        final subscription = repository.subscribe<Mounty>().listen((event) {});
        expect(repository.subscriptions[Mounty], hasLength(1));
        await subscription.cancel();
        expect(repository.subscriptions[Mounty], hasLength(0));
      });

      test('pausing does not remove from #subscriptions', () async {
        final repository = TestRepository.configure(link: stubGraphqlLink({}));
        expect(repository.subscriptions, hasLength(0));
        final subscription = repository.subscribe<Mounty>().listen((event) {});
        expect(repository.subscriptions, hasLength(1));
        subscription.pause();
        expect(repository.subscriptions, hasLength(1));
        expect(repository.subscriptions[Mounty]!.entries.first.value.isPaused, isTrue);
      });

      test('streams cached data', () {});
    });

    group('#notifySubscriptionsWithLocalData', () {
      test('does not apply if model has not been subscribed', () {});
      test('appends memory then sqlite', () {});
      test('does not apply memory cache results if null or empty', () {});
    });
  });
}
