// ignore_for_file: unawaited_futures

import 'package:brick_offline_first_with_supabase/src/offline_first_with_supabase_repository.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_sqlite/memory_cache_provider.dart';
import 'package:brick_supabase/brick_supabase.dart';
import 'package:brick_supabase/testing.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:supabase/supabase.dart';
import 'package:test/test.dart';

import '__mocks__.dart';

class TestRepository extends OfflineFirstWithSupabaseRepository {
  TestRepository._({
    required super.supabaseProvider,
    required super.sqliteProvider,
    required super.offlineRequestQueue,
    super.memoryCacheProvider,
  }) : super(
          migrations: {
            const Migration20240906052847(),
          },
        );

  static TestRepository configure(SupabaseMockServer mock) {
    final (client, queue) = OfflineFirstWithSupabaseRepository.clientQueue(
      databaseFactory: databaseFactoryFfi,
      reattemptForStatusCodes: [],
    );

    final provider = SupabaseProvider(
      SupabaseClient(mock.serverUrl, mock.apiKey, httpClient: client),
      modelDictionary: supabaseModelDictionary,
    );

    return TestRepository._(
      offlineRequestQueue: queue,
      memoryCacheProvider: MemoryCacheProvider(),
      supabaseProvider: provider,
      sqliteProvider: SqliteProvider(
        'my_repository.sqlite',
        databaseFactory: databaseFactoryFfi,
        modelDictionary: sqliteModelDictionary,
      ),
    );
  }
}

void main() async {
  sqfliteFfiInit();

  final mock = SupabaseMockServer(modelDictionary: supabaseModelDictionary);

  group('OfflineFirstWithSupabaseRepository', () {
    late TestRepository repository;

    setUp(() async {
      await mock.setUp();
      repository = TestRepository.configure(mock);
      await repository.initialize();
    });

    tearDown(() async {
      await mock.tearDown();
      await repository.reset();
    });

    group('#get', () {
      test('stores locally', () async {
        final req = SupabaseRequest<Customer>();
        final resp = SupabaseResponse([
          await mock.serialize(
            Customer(
              id: 1,
              firstName: 'Thomas',
              lastName: 'Guy',
              pizzas: [
                Pizza(id: 2, toppings: [Topping.pepperoni], frozen: false),
              ],
            ),
          ),
        ]);
        mock.handle({req: resp});

        final customers = await repository.get<Customer>();
        expect(customers, hasLength(1));
        final localPizzas = await repository.sqliteProvider.get<Pizza>();
        expect(localPizzas, hasLength(1));
      });
    });
  });
}
