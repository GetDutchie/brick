import 'package:brick_core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '__helpers__.dart';
import 'test_domain/__mocks__.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  group('OfflineFirstWithGraphqlRepository', () {
    test('instantiates', () {
      final repository = TestRepository.configure(link: stubGraphqlLink({}));
      expect(repository.remoteProvider.link.runtimeType.toString(), 'GraphqlOfflineQueueLink');
    });

    group('#get', () {
      test('simple', () async {
        final repository = TestRepository.configure(link: stubGraphqlLink({'name': 'SqliteName'}));
        await repository.initialize();
        await repository.migrate();

        final results = await repository.get<Mounty>();
        expect(results, hasLength(1));
        expect(results.first.name, 'SqliteName');
      });

      test('one-to-many, many-to-many', () async {
        final mounties = [Mounty(name: 'Thomas'), Mounty(name: 'Guy')];
        final horse = Horse(name: 'Not Thomas', mounties: mounties);
        final repository = TestRepository.configure(link: stubGraphqlLink({'name': 'SqliteName'}));
        await repository.initialize();
        await repository.migrate();

        await repository.sqliteProvider.upsert<Horse>(horse);
        final results = await repository.sqliteProvider.get<Horse>(repository: repository);

        expect(results.first.mounties, hasLength(2));
        expect(results.first.mounties.first.primaryKey, greaterThan(0));
        expect(results.first.mounties.last.primaryKey, greaterThan(0));
        final findByName = await repository.sqliteProvider.get<Horse>(
          repository: repository,
          query: Query(where: [
            const Where('mounties').isExactly(Where.exact('name', mounties.first.name)),
          ]),
        );

        expect(findByName.first.name, horse.name);
      });
    });

    test('#getBatched', () async {
      final repository = TestRepository.configure(link: stubGraphqlLink({'name': 'SqliteName'}));
      await repository.initialize();
      await repository.migrate();

      final results = await repository.getBatched<Mounty>(requireRemote: false);
      expect(results.first, isA<Mounty>());
      expect(results.first.name, 'SqliteName');
    });

    group('#subscribe', () {
      test('adds controller and query to #subscriptions', () async {
        final repository = TestRepository.configure(link: stubGraphqlLink({}));
        await repository.initialize();
        await repository.migrate();

        expect(repository.subscriptions, hasLength(0));
        final query = Query.where('name', 'Thomas');
        repository.subscribe<Mounty>(query: query);
        expect(repository.subscriptions, hasLength(1));
        expect(repository.subscriptions[Mounty], hasLength(1));
        expect(repository.subscriptions[Mounty]!.entries.first.key, query);
        expect(repository.subscriptions[Mounty]!.entries.first.value, isNotNull);
      });

      test('adds controller and null query to #subscriptions', () async {
        final repository = TestRepository.configure(link: stubGraphqlLink({}));
        await repository.initialize();
        await repository.migrate();

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
        await repository.migrate();

        expect(repository.subscriptions, hasLength(0));
        final subscription = repository.subscribe<Mounty>().listen((event) {});
        expect(repository.subscriptions[Mounty], hasLength(1));
        await subscription.cancel();
        expect(repository.subscriptions[Mounty], hasLength(0));
      });

      test('pausing does not remove from #subscriptions', () async {
        final repository = TestRepository.configure(link: stubGraphqlLink({}));
        await repository.initialize();
        await repository.migrate();

        expect(repository.subscriptions, hasLength(0));
        final subscription = repository.subscribe<Mounty>().listen((event) {});
        expect(repository.subscriptions, hasLength(1));
        subscription.pause();
        expect(repository.subscriptions, hasLength(1));
        expect(repository.subscriptions[Mounty]!.entries.first.value.isPaused, isTrue);
      });

      test('stores fetched data', () async {
        final repository = TestRepository.configure(link: stubGraphqlLink({'name': 'SqliteName'}));
        await repository.initialize();
        await repository.migrate();

        final sqliteResults = await repository.sqliteProvider.get<Mounty>();
        expect(sqliteResults, hasLength(0));
        repository.subscribe<Mounty>();
        // Wait for the repository to fetch and insert the data
        // I can't figure out a better way to do this since the controller
        // stream doesn't close on its own
        await Future.delayed(const Duration(milliseconds: 500));
        final afterSubscribe = await repository.sqliteProvider.get<Mounty>();
        expect(afterSubscribe, hasLength(1));
      });

      test('streams filtered data with query', () async {
        final repository = TestRepository.configure(link: stubGraphqlLink({'name': 'SqliteName'}));
        await repository.initialize();
        await repository.migrate();

        var eventReceived = false;
        final subscription =
            repository.subscribe<Mounty>(query: Query.where('name', 'Thomas')).listen((event) {
          eventReceived = event.first.name == 'Thomas';
        });
        expect(repository.subscriptions[Mounty], hasLength(1));
        await repository.upsert<Mounty>(Mounty(name: 'Thomas'));
        await subscription.cancel();
        expect(eventReceived, isTrue);
      });

      test('notifies when upsert is invoked', () async {
        final repository = TestRepository.configure(link: stubGraphqlLink({'name': 'SqliteName'}));
        await repository.initialize();
        await repository.migrate();

        var eventReceived = false;
        final subscription = repository.subscribe<Mounty>().listen((event) {
          eventReceived = event.first.name == 'Thomas';
        });
        await repository.upsert<Mounty>(Mounty(name: 'Thomas'));
        await subscription.cancel();
        expect(eventReceived, isTrue);
      });

      test('notifies when delete is invoked', () async {
        final repository = TestRepository.configure(link: stubGraphqlLink({'name': 'SqliteName'}));
        await repository.initialize();
        await repository.migrate();

        final instance = await repository.upsert<Mounty>(Mounty(name: 'Thomas'));
        var noEvents = true;
        final subscription =
            repository.subscribe<Mounty>(query: Query.where('name', 'Thomas')).listen((event) {
          noEvents = false;
        });
        await repository.delete<Mounty>(instance);
        await subscription.cancel();
        expect(noEvents, isTrue);
      });
    });

    group('#notifySubscriptionsWithLocalData', () {
      test('retrieves from SQLite', () async {
        final repository = TestRepository.configure(
          link: stubGraphqlLink({'name': 'SqliteName'}),
        );
        await repository.initialize();
        await repository.migrate();

        var eventReceived = false;
        final subscription = repository.subscribe<Mounty>().listen((event) {
          eventReceived = event.first.name == 'Guy';
        });
        await repository.sqliteProvider.upsert<Mounty>(Mounty(name: 'Guy'));
        await repository.notifySubscriptionsWithLocalData<Mounty>();
        await Future.delayed(const Duration(milliseconds: 500));
        await subscription.cancel();

        expect(eventReceived, isTrue);
      });
    });
  });
}
