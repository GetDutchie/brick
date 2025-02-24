import 'dart:io';

import 'package:brick_core/query.dart';
import 'package:brick_offline_first/src/offline_first_policy.dart';
import 'package:brick_sqlite/db.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:test/test.dart';

import 'helpers/__mocks__.dart';
import 'helpers/test_domain.dart';

void main() {
  sqfliteFfiInit();

  group('OfflineFirstRepository', () {
    setUp(() async {
      TestRepository.configure();

      await TestRepository().initialize();
    });

    tearDown(() {
      TestRepository.throwOnNextRemoteMutation = false;
      (TestRepository().remoteProvider as TestProvider).methodsCalled.clear();
    });

    test('#applyPolicyToQuery', () {
      const policy = OfflineFirstGetPolicy.localOnly;
      final query = TestRepository().applyPolicyToQuery(const Query(), get: policy);
      expect(query?.action?.index, policy.index);
    });

    group('#delete', () {
      test('OfflineFirstDeletePolicy.optimisticLocal', () async {
        final instance = Mounty(name: 'SqliteName');
        final upserted = await TestRepository().upsert<Mounty>(instance);
        expect(await TestRepository().sqliteProvider.get<Mounty>(), hasLength(1));

        TestRepository.throwOnNextRemoteMutation = true;
        await TestRepository().delete<Mounty>(upserted);
        expect(await TestRepository().sqliteProvider.get<Mounty>(), isEmpty);
      });

      test('OfflineFirstDeletePolicy.requireRemote', () async {
        final instance = Mounty(name: 'SqliteName');
        final upserted = await TestRepository().upsert<Mounty>(instance);

        TestRepository.throwOnNextRemoteMutation = true;
        expect(
          () async => await TestRepository()
              .delete<Mounty>(upserted, policy: OfflineFirstDeletePolicy.requireRemote),
          throwsA(const TypeMatcher<SocketException>()),
        );
      });
    });

    group('#get', () {
      test('simple', () async {
        final results = await TestRepository().get<Mounty>();
        expect(results, hasLength(1));
        expect(results.first.name, 'SqliteName');
      });

      test('one-to-many, many-to-many', () async {
        final mounties = [Mounty(name: 'Thomas'), Mounty(name: 'Guy')];
        final horse = Horse(name: 'Not Thomas', mounties: mounties);

        await TestRepository().sqliteProvider.upsert<Horse>(horse);
        final results =
            await TestRepository().sqliteProvider.get<Horse>(repository: TestRepository());

        expect(results.first.mounties, hasLength(2));
        expect(results.first.mounties.first.primaryKey, greaterThan(0));
        expect(results.first.mounties.last.primaryKey, greaterThan(0));
        final findByName = await TestRepository().sqliteProvider.get<Horse>(
              repository: TestRepository(),
              query: Query(
                where: [
                  const Where('mounties').isExactly(Where.exact('name', mounties.first.name)),
                ],
              ),
            );

        expect(findByName.first.name, horse.name);
      });

      test('OfflineFirstGetPolicy.awaitRemote', () async {
        TestRepository().memoryCacheProvider.managedModelTypes.add(Horse);

        try {
          final fetchFirst =
              await TestRepository().get<Horse>(policy: OfflineFirstGetPolicy.awaitRemote);
          expect(fetchFirst, isNotEmpty);
          final fetchMemory = TestRepository().memoryCacheProvider.get<Horse>(
                query: Query.where(InsertTable.PRIMARY_KEY_FIELD, fetchFirst.first.primaryKey),
              );
          expect(fetchMemory, isNotEmpty);
          final fetchAgain =
              await TestRepository().get<Horse>(policy: OfflineFirstGetPolicy.awaitRemote);

          // The TestProvider does not have unique keys, so Brick can't compare based on the name,
          // giving the appearance of two distinct records
          expect(fetchAgain, hasLength(2));
          expect((TestRepository().remoteProvider as TestProvider).methodsCalled, hasLength(2));
        } finally {
          TestRepository().memoryCacheProvider.managedModelTypes.remove(Horse);
        }
      });

      test('OfflineFirstGetPolicy.localOnly', () async {
        final results = await TestRepository().get<Horse>(policy: OfflineFirstGetPolicy.localOnly);

        expect(results, isEmpty);
      });

      test('OfflineFirstGetPolicy.awaitRemoteWhenNoneExist', () async {
        final results = await TestRepository()
            .get<Mounty>(policy: OfflineFirstGetPolicy.awaitRemoteWhenNoneExist);

        expect(results, isNotEmpty);
      });
    });

    test(
      '#hydrateSqlite / #get requireRest:true',
      () async {
        await TestRepository().get<Mounty>(policy: OfflineFirstGetPolicy.awaitRemote);

        // verify(TestRepository()
        //     .remoteProvider
        //     .client
        //     .get(Uri.parse('http://0.0.0.0:3000/mounties'), headers: anyNamed('headers')));
      },
      skip: 'Client is no longer a Mockito instance',
    );

    test('#getBatched', () async {
      final instance = Mounty(name: 'SqliteName');
      await TestRepository().upsert<Mounty>(instance);
      final results = await TestRepository().getBatched<Mounty>(
        policy: OfflineFirstGetPolicy.localOnly,
      );
      expect(results.first, isA<Mounty>());
      expect(results.first.name, instance.name);
    });

    group('#notifySubscriptionsWithLocalData', () {
      test('retrieves from SQLite', () async {
        var eventReceived = false;
        final subscription = TestRepository().subscribe<Mounty>().listen((event) {
          eventReceived = event.first.name == 'Guy';
        });
        await TestRepository().sqliteProvider.upsert<Mounty>(Mounty(name: 'Guy'));
        await TestRepository().notifySubscriptionsWithLocalData<Mounty>();
        await Future.delayed(const Duration(milliseconds: 500));
        await subscription.cancel();

        expect(eventReceived, isTrue);
      });
    });

    test('#storeRestResults', () async {
      final instance = Mounty(name: 'SqliteName');
      final results = await TestRepository().storeRemoteResults([instance]);

      expect(results, hasLength(1));
      expect(results.first.primaryKey, greaterThanOrEqualTo(1));
    });

    group('#upsert', () {
      test('OfflineFirstUpsertPolicy.optimisticLocal', () async {
        final instance = Mounty(name: 'SqliteName');
        final results = await TestRepository().upsert<Mounty>(instance);

        expect(results.name, 'SqliteName');
        expect(results.primaryKey, greaterThanOrEqualTo(1));
      });

      test('OfflineFirstUpsertPolicy.requireRemote', () {
        final instance = Mounty(name: 'SqliteName');
        TestRepository.throwOnNextRemoteMutation = true;
        expect(
          () async => await TestRepository()
              .upsert<Mounty>(instance, policy: OfflineFirstUpsertPolicy.requireRemote),
          throwsA(const TypeMatcher<SocketException>()),
        );
      });
    });

    test('#reset', () async {
      final instance = MemoryDemoModel('SqliteName');
      await TestRepository().upsert<MemoryDemoModel>(instance);

      expect(TestRepository().memoryCacheProvider.managedObjects, isNotEmpty);
      await TestRepository().reset();
      expect(TestRepository().memoryCacheProvider.managedObjects, isEmpty);
    });

    group('#subscribe', () {
      test('adds controller and query to #subscriptions', () {
        expect(TestRepository().subscriptions, hasLength(0));
        final query = Query.where('name', 'Thomas');
        TestRepository().subscribe<Mounty>(query: query);
        expect(TestRepository().subscriptions, hasLength(1));
        expect(TestRepository().subscriptions[Mounty], hasLength(1));
        expect(TestRepository().subscriptions[Mounty]!.entries.first.key, query);
        expect(TestRepository().subscriptions[Mounty]!.entries.first.value, isNotNull);
      });

      test('subscription succeeds when policy is non-default .awaitRemote', () {
        expect(TestRepository().subscriptions, hasLength(0));
        final query = Query.where('name', 'Thomas');
        TestRepository().subscribe<Mounty>(policy: OfflineFirstGetPolicy.awaitRemote, query: query);
        expect(TestRepository().subscriptions, hasLength(1));
        expect(TestRepository().subscriptions[Mounty], hasLength(1));
      });

      test('adds controller and null query to #subscriptions', () {
        expect(TestRepository().subscriptions, hasLength(0));
        TestRepository().subscribe<Mounty>();
        expect(TestRepository().subscriptions, hasLength(1));
        expect(TestRepository().subscriptions[Mounty], hasLength(1));
        expect(TestRepository().subscriptions[Mounty]!.entries.first.key, isNotNull);
        expect(TestRepository().subscriptions[Mounty]!.entries.first.value, isNotNull);
      });

      test('cancelling removes from #subscriptions', () async {
        expect(TestRepository().subscriptions, hasLength(0));
        final subscription = TestRepository().subscribe<Mounty>().listen((event) {});
        expect(TestRepository().subscriptions[Mounty], hasLength(1));
        await subscription.cancel();
        expect(TestRepository().subscriptions, hasLength(0));
      });

      test('pausing does not remove from #subscriptions', () async {
        expect(TestRepository().subscriptions, hasLength(0));
        final subscription = TestRepository().subscribe<Mounty>().listen((event) {});
        expect(TestRepository().subscriptions, hasLength(1));
        subscription.pause();
        expect(TestRepository().subscriptions, hasLength(1));
        expect(TestRepository().subscriptions[Mounty]!.entries.first.value.isPaused, isTrue);
        await subscription.cancel();
      });

      test('stores fetched data', () async {
        final sqliteResults = await TestRepository().sqliteProvider.get<Mounty>();
        expect(sqliteResults, hasLength(0));
        // eager load
        await TestRepository().get<Mounty>();
        TestRepository().subscribe<Mounty>();
        // Wait for the repository to fetch and insert the data
        // I can't figure out a better way to do this since the controller
        // stream doesn't close on its own
        await Future.delayed(const Duration(milliseconds: 500));
        final afterSubscribe = await TestRepository().sqliteProvider.get<Mounty>();
        expect(afterSubscribe, hasLength(1));
      });

      test('streams filtered data with query', () async {
        var eventReceived = false;
        var eventCount = 0;
        // eager load
        await TestRepository().get<Mounty>();
        final subscription = TestRepository()
            .subscribe<Mounty>(query: Query.where('name', 'Thomas'))
            .listen((event) {
          eventReceived = event.first.name == 'Thomas';
          eventCount += 1;
        });
        expect(TestRepository().subscriptions[Mounty], hasLength(1));
        await TestRepository().upsert<Mounty>(Mounty(name: 'Thomas'));
        await subscription.cancel();
        expect(eventReceived, isTrue);
        // once for initial subscribe
        // and again for upsert
        expect(eventCount, 2);
      });

      test('notifies when storeRemoteResults is invoked', () async {
        var eventReceived = false;
        final subscription = TestRepository().subscribe<Mounty>().listen((event) {
          eventReceived = event.first.name == 'Thomas';
        });
        await TestRepository().storeRemoteResults<Mounty>([Mounty(name: 'Thomas')]);
        await subscription.cancel();
        expect(eventReceived, isTrue);
      });

      test('notifies when upsert is invoked', () async {
        var eventReceived = false;
        var eventCount = 0;
        final subscription = TestRepository().subscribe<Mounty>().listen((event) {
          eventReceived = event.first.name == 'Thomas';
          eventCount += 1;
        });
        await TestRepository().upsert<Mounty>(Mounty(name: 'Thomas'));
        await subscription.cancel();
        expect(eventReceived, isTrue);
        // once for initial subscribe
        // and again for upsert
        expect(eventCount, 2);
      });

      test('notifies when delete is invoked', () async {
        final instance = await TestRepository().upsert<Mounty>(Mounty(name: 'Thomas'));
        var eventCount = 0;
        final subscription = TestRepository()
            .subscribe<Mounty>(query: Query.where('name', 'Thomas'))
            .listen((event) {
          eventCount += 1;
        });
        await TestRepository().delete<Mounty>(instance);
        await subscription.cancel();

        // once for the original `subscribe`
        // and again for `delete`
        expect(eventCount, 2);
      });
    });
  });
}
