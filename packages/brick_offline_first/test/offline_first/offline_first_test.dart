import 'package:brick_offline_first/testing.dart' hide MockClient;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart' show TypeMatcher;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '__mocks__.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  group('OfflineFirstModel', () {
    test('instantiates', () {
      final m = Mounty(name: 'Thomas');
      expect(m, const TypeMatcher<Mounty>());
    });
  });

  group('OfflineFirstAdapter', () {
    test('instantiates', () {
      final m = MountyAdapter();
      expect(m, const TypeMatcher<MountyAdapter>());
      expect(m.tableName, 'Demo');
    });
  });

  group('OfflineFirstRepository', () {
    final baseUrl = 'http://localhost:3000';
    final client = MockClient();

    TestRepository.configure(
      baseUrl: baseUrl,
      restDictionary: restModelDictionary,
      sqliteDictionary: sqliteModelDictionary,
      client: client,
    );

    setUpAll(() async {
      await StubOfflineFirstWithRest(
        repository: TestRepository(),
        modelStubs: [
          StubOfflineFirstWithRestModel<Mounty>(
            repository: TestRepository(),
            filePath: 'offline_first/api/mounties.json',
            endpoints: ['mounties'],
          ),
        ],
      ).initialize();
    });

    test('instantiates', () {
      final repository = TestRepository.createInstance(
        baseUrl: baseUrl,
        restDictionary: restModelDictionary,
        sqliteDictionary: sqliteModelDictionary,
      );

      // isA matcher didn't work
      expect(repository.remoteProvider.client.runtimeType.toString(), 'OfflineQueueHttpClient');
    });

    test('#delete', () {}, skip: 'Is this worth testing because of all the stubbing?');

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
      });
    });

    test('#getBatched', () async {
      final results = await TestRepository().getBatched<Mounty>(requireRemote: false);
      expect(results.first, isA<Mounty>());
      expect(results.first.name, 'SqliteName');
    });

    test('#hydrateSqlite / #get requireRest:true', () async {
      await TestRepository().get<Mounty>(requireRemote: true);

      verify(TestRepository()
          .remoteProvider
          .client
          .get('http://localhost:3000/mounties', headers: anyNamed('headers')));
    });

    test('#storeRestResults', () async {
      final instance = Mounty(name: 'SqliteName');
      final results = await TestRepository().storeRemoteResults([instance]);

      expect(results, hasLength(1));
      expect(results.first.primaryKey, greaterThanOrEqualTo(1));
    });

    test('#upsert', () async {
      final instance = Mounty(name: 'SqliteName');
      final results = await TestRepository().upsert<Mounty>(instance);

      expect(results.name, 'SqliteName');
      expect(results.primaryKey, greaterThanOrEqualTo(1));
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
