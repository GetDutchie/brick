import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:brick_offline_first_with_rest/testing.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:test/test.dart';

import 'helpers/__mocks__.dart';

void main() {
  sqfliteFfiInit();

  group('OfflineFirstRepository', () {
    const baseUrl = 'http://0.0.0.0:3000';

    setUp(() async {
      TestRepository.configure(
        baseUrl: baseUrl,
        restDictionary: restModelDictionary,
        sqliteDictionary: sqliteModelDictionary,
        client: StubOfflineFirstWithRest.fromFiles(baseUrl, {
          'mounties': 'api/mounties.json',
        }).client,
      );

      await TestRepository().initialize();
    });

    test('instantiates', () {
      // isA matcher didn't work
      expect(
        TestRepository().remoteProvider.client.runtimeType.toString(),
        'RestOfflineQueueClient',
      );
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

      test('delivers data from HTTP when using awaitRemote policy', () async {
        // Configure test repository with a client that returns a specific response
        const customResponse = '[{"name": "RemoteName"}]';
        final client = StubOfflineFirstWithRest(
          baseEndpoint: baseUrl,
          responses: [
            StubOfflineFirstRestResponse(
              customResponse,
              endpoint: 'mounties',
              method: StubHttpMethod.get,
            ),
          ],
        ).client;

        TestRepository.configure(
          baseUrl: baseUrl,
          restDictionary: restModelDictionary,
          sqliteDictionary: sqliteModelDictionary,
          client: client,
        );
        await TestRepository().initialize();

        // Get data with awaitRemote policy
        final results = await TestRepository().get<Mounty>(
          query: Query(
            where: [
              const Where('name').isExactly('RemoteName'),
            ],
          ),
          policy: OfflineFirstGetPolicy.awaitRemote,
        );

        // Verify data came from HTTP
        expect(results, hasLength(1));
        expect(results.first.name, 'RemoteName');
      });

      test('handles tunnel not found response with non-awaitRemote policy', () async {
        // Configure test repository with a client that returns a tunnel not found response
        const tunnelNotFoundResponse = 'Tunnel 12345 not found';
        final client = MockClient((req) async {
          if (req.url.toString().contains('mounties')) {
            return http.Response(tunnelNotFoundResponse, 404);
          }
          return http.Response('Not found', 404);
        });

        TestRepository.configure(
          baseUrl: baseUrl,
          restDictionary: restModelDictionary,
          sqliteDictionary: sqliteModelDictionary,
          client: client,
        );
        await TestRepository().initialize();

        // Get data with non-awaitRemote policy
        final results = await TestRepository().get<Mounty>(
          policy: OfflineFirstGetPolicy.localOnly,
        );

        // Should return empty list without throwing
        expect(results, isEmpty);
      });
    });

    test('#getBatched', () async {
      final results = await TestRepository().getBatched<Mounty>();
      expect(results.first, isA<Mounty>());
      expect(results.first.name, 'SqliteName');
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

    test('#storeRemoteResults', () async {
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
