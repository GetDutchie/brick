import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'helpers/__mocks__.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  group('OfflineFirstRepository', () {
    setUp(() async {
      TestRepository.configure(
        sqliteDictionary: sqliteModelDictionary,
      );

      await TestRepository().initialize();
    });

    tearDown(() {
      TestRepository.throwOnNextRemoteMutation = false;
    });

    test('#applyPolicyToQuery', () async {
      const policy = OfflineFirstGetPolicy.localOnly;
      final query = TestRepository().applyPolicyToQuery(Query(), get: policy);
      expect(query?.providerArgs, {'policy': policy.index});
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
        expect(await TestRepository().sqliteProvider.get<Mounty>(), hasLength(1));

        TestRepository.throwOnNextRemoteMutation = true;
        await TestRepository()
            .delete<Mounty>(upserted, policy: OfflineFirstDeletePolicy.requireRemote);
        expect(await TestRepository().sqliteProvider.get<Mounty>(), hasLength(1));
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
              query: Query(where: [
                const Where('mounties').isExactly(Where.exact('name', mounties.first.name)),
              ]),
            );

        expect(findByName.first.name, horse.name);
      });

      test('OfflineFirstGetPolicy.localOnly', () async {
        final results = await TestRepository().get<Mounty>(policy: OfflineFirstGetPolicy.localOnly);

        expect(results, isEmpty);
      });

      test('OfflineFirstGetPolicy.awaitRemoteWhenNoneExist', () async {
        final results = await TestRepository()
            .get<Mounty>(policy: OfflineFirstGetPolicy.awaitRemoteWhenNoneExist);

        expect(results, isNotEmpty);
      });
    });

    test('#hydrateSqlite / #get requireRest:true', () async {
      await TestRepository().get<Mounty>(policy: OfflineFirstGetPolicy.awaitRemote);

      // verify(TestRepository()
      //     .remoteProvider
      //     .client
      //     .get(Uri.parse('http://0.0.0.0:3000/mounties'), headers: anyNamed('headers')));
    }, skip: 'Client is no longer a Mockito instance');

    test('#getBatched', () async {
      final results = await TestRepository().getBatched<Mounty>(
        policy: OfflineFirstGetPolicy.localOnly,
      );
      expect(results.first, isA<Mounty>());
      expect(results.first.name, 'SqliteName');
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

      test('OfflineFirstUpsertPolicy.requireRemote', () async {
        final instance = Mounty(name: 'SqliteName');
        TestRepository.throwOnNextRemoteMutation = true;
        final results = await TestRepository()
            .upsert<Mounty>(instance, policy: OfflineFirstUpsertPolicy.requireRemote);

        expect(results.name, 'SqliteName');
        expect(results.primaryKey, greaterThanOrEqualTo(1));
      });
    });

    test('#reset', () async {
      final instance = MemoryDemoModel('SqliteName');
      await TestRepository().upsert<MemoryDemoModel>(instance);

      expect(TestRepository().memoryCacheProvider.managedObjects, isNotEmpty);
      await TestRepository().reset();
      expect(TestRepository().memoryCacheProvider.managedObjects, isEmpty);
    });
  });
}
