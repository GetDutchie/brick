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
      final m = DemoModel('Thomas');
      expect(m, const TypeMatcher<DemoModel>());
    });
  });

  group('OfflineFirstAdapter', () {
    test('instantiates', () {
      final m = DemoModelAdapter();
      expect(m, const TypeMatcher<DemoModelAdapter>());
      expect(m.tableName, 'Demo');
    });
  });

  group('OfflineFirstRepository', () {
    final baseUrl = 'http://localhost:3000';
    final client = MockClient();
    final List<Map<String, dynamic>> responses = [
      {'name': 'SqliteName'},
    ];

    TestRepository.configure(
      baseUrl: baseUrl,
      dbName: 'db.sqlite',
      restDictionary: restDictiontary,
      sqliteDictionary: sqliteDictionary,
      client: client,
    );

    setUpAll(() {
      StubOfflineFirstWithRest(
        repository: TestRepository(),
        modelStubs: [
          StubOfflineFirstWithRestModel<DemoModel>(
            repository: TestRepository(),
            filePath: 'offline_first/api/people.json',
            endpoints: ['people'],
          ),
        ],
      );
    });

    test('instantiates', () {
      final repository = TestRepository.createInstance(
        baseUrl: baseUrl,
        restDictionary: restDictiontary,
        sqliteDictionary: sqliteDictionary,
      );

      // isA matcher didn't work
      expect(repository.remoteProvider.client.runtimeType.toString(), 'OfflineQueueHttpClient');
    });

    test('#delete', () {}, skip: 'Is this worth testing because of all the stubbing?');

    test('#get', () async {
      final results = await TestRepository().get<DemoModel>();
      expect(results, hasLength(1));
      expect(results.first.name, 'SqliteName');
    });

    test('#getBatched', () async {
      final results = await TestRepository().getBatched<DemoModel>(requireRemote: false);
      expect(results, [DemoModel('SqliteName')]);
    });

    test('#hydrateSqlite / #get requireRest:true', () async {
      await TestRepository().get<DemoModel>(requireRemote: true);

      verify(TestRepository()
          .remoteProvider
          .client
          .get('http://localhost:3000/people', headers: anyNamed('headers')));
    });

    test('#reset', () async {
      final instance = MemoryDemoModel('SqliteName');
      await TestRepository().upsert<MemoryDemoModel>(instance);

      expect(TestRepository().memoryCacheProvider.managedObjects, isNotEmpty);
      await TestRepository().reset();
      expect(TestRepository().memoryCacheProvider.managedObjects, isEmpty);
    });

    test('#storeRestResults', () async {
      final instance = DemoModel('SqliteName');
      final results = await TestRepository().storeRemoteResults([instance]);

      expect(results, hasLength(1));
      expect(results.first.primaryKey, responses.length + 1);
    });

    test('#upsert', () async {
      final instance = DemoModel('SqliteName');
      final results = await TestRepository().upsert<DemoModel>(instance);

      expect(results.name, 'SqliteName');
      expect(results.primaryKey, 2);
    });
  });
}
