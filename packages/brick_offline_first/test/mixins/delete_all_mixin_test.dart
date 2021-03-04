import 'package:brick_offline_first/mixins.dart';
import 'package:brick_offline_first/testing.dart' hide MockClient;
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:brick_offline_first/src/offline_queue/request_sqlite_cache_manager.dart';
import 'package:brick_rest/rest.dart';
import 'package:brick_sqlite/memory_cache_provider.dart';
import 'package:brick_offline_first/offline_first_with_rest.dart';
import 'package:brick_sqlite/sqlite.dart';

import 'package:brick_offline_first/offline_first.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite_common/sqlite_api.dart';

import '../offline_first/__mocks__.dart';

class DeleteAllRepository extends OfflineFirstWithRestRepository
    with DeleteAllMixin<OfflineFirstWithRestModel> {
  DeleteAllRepository({
    required String baseUrl,
    required RestModelDictionary restDictionary,
    required SqliteModelDictionary sqliteDictionary,
    required http.Client client,
  }) : super(
          restProvider: RestProvider(baseUrl, modelDictionary: restDictionary, client: client),
          sqliteProvider: SqliteProvider(
            inMemoryDatabasePath,
            databaseFactory: databaseFactoryFfi,
            modelDictionary: sqliteDictionary,
          ),
          memoryCacheProvider: MemoryCacheProvider([MemoryDemoModel]),
          migrations: {const DemoModelMigration()},
          offlineQueueHttpClientRequestSqliteCacheManager: RequestSqliteCacheManager(
            inMemoryDatabasePath,
            databaseFactory: databaseFactoryFfi,
          ),
        );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  group('DeleteAllMixin', () {
    final client = MockClient();
    final repository = DeleteAllRepository(
      baseUrl: 'http://localhost:3000',
      restDictionary: restModelDictionary,
      sqliteDictionary: sqliteModelDictionary,
      client: client,
    );

    setUpAll(() async {
      await StubOfflineFirstWithRest(
        repository: repository,
        modelStubs: [
          StubOfflineFirstWithRestModel<Mounty>(
            repository: repository,
            filePath: 'offline_first/api/mounties.json',
            endpoints: ['mounties'],
          ),
        ],
      ).initialize();
    });

    test('#deleteAll', () async {
      final newModel = Mounty(name: 'GuyDelete');
      final newModel2 = Mounty(name: 'GuyDelete2');

      await repository.upsert<Mounty>(newModel);
      await repository.upsert<Mounty>(newModel2);
      final beforeDelete = await repository.sqliteProvider.get<Mounty>();
      expect(beforeDelete, hasLength(2));

      final deleteAllResult = await repository.deleteAll<Mounty>();
      expect(deleteAllResult, isTrue);

      final afterDelete = await repository.sqliteProvider.get<Mounty>();
      expect(afterDelete, hasLength(0));
    });

    test('#deleteAllExcept', () async {
      final newModel = Mounty(name: 'GuyDelete');
      final newModel2 = Mounty(name: 'GuyDelete2');

      await repository.upsert<Mounty>(newModel);
      await repository.upsert<Mounty>(newModel2);
      final beforeDelete = await repository.sqliteProvider.get<Mounty>();
      expect(beforeDelete, hasLength(2));

      final deleteAllResult =
          await repository.deleteAllExcept<Mounty>(query: Query.where('name', newModel2.name));
      expect(deleteAllResult, isTrue);

      final afterDelete = await repository.sqliteProvider.get<Mounty>();
      expect(afterDelete, hasLength(1));
      expect(afterDelete.first.name, newModel2.name);
    });
  });
}
