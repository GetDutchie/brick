// ignore_for_file: unawaited_futures

import 'package:brick_offline_first/brick_offline_first.dart';
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

    group('#queryToPostgresChangeFilter', () {
      group('returns null', () {
        test('for complex queries', () {
          final query = Query.where('pizza', Where.exact('id', 2));
          expect(repository.queryToPostgresChangeFilter<Customer>(query), isNull);
        });

        test('for empty queries', () {
          final query = Query();
          expect(repository.queryToPostgresChangeFilter<Customer>(query), isNull);
        });

        test('for missing columns', () {
          final query = Query.where('unknown', 1);
          expect(repository.queryToPostgresChangeFilter<Customer>(query), isNull);
        });
      });

      group('Compare', () {
        test('.between', () {
          final query =
              Query(where: [Where('firstName', value: 'Thomas', compare: Compare.between)]);
          final filter = repository.queryToPostgresChangeFilter<Customer>(query);
          expect(filter, isNull);
        });

        test('.doesNotContain', () {
          final query =
              Query(where: [Where('firstName', value: 'Thomas', compare: Compare.doesNotContain)]);
          final filter = repository.queryToPostgresChangeFilter<Customer>(query);
          expect(filter, isNull);
        });

        test('.exact', () {
          final query = Query(where: [Where('firstName', value: 'Thomas', compare: Compare.exact)]);
          final filter = repository.queryToPostgresChangeFilter<Customer>(query);

          expect(filter!.type, PostgresChangeFilterType.eq);
          expect(filter.column, 'first_name');
          expect(filter.value, 'Thomas');
        });

        test('.greaterThan', () {
          final query =
              Query(where: [Where('firstName', value: 'Thomas', compare: Compare.greaterThan)]);
          final filter = repository.queryToPostgresChangeFilter<Customer>(query);

          expect(filter!.type, PostgresChangeFilterType.gt);
          expect(filter.column, 'first_name');
          expect(filter.value, 'Thomas');
        });

        test('.greaterThanOrEqualTo', () {
          final query = Query(
            where: [Where('firstName', value: 'Thomas', compare: Compare.greaterThanOrEqualTo)],
          );
          final filter = repository.queryToPostgresChangeFilter<Customer>(query);

          expect(filter!.type, PostgresChangeFilterType.gte);
          expect(filter.column, 'first_name');
          expect(filter.value, 'Thomas');
        });

        test('.lessThan', () {
          final query =
              Query(where: [Where('firstName', value: 'Thomas', compare: Compare.lessThan)]);
          final filter = repository.queryToPostgresChangeFilter<Customer>(query);

          expect(filter!.type, PostgresChangeFilterType.lt);
          expect(filter.column, 'first_name');
          expect(filter.value, 'Thomas');
        });

        test('.lessThanOrEqualTo', () {
          final query = Query(
            where: [Where('firstName', value: 'Thomas', compare: Compare.lessThanOrEqualTo)],
          );
          final filter = repository.queryToPostgresChangeFilter<Customer>(query);

          expect(filter!.type, PostgresChangeFilterType.lte);
          expect(filter.column, 'first_name');
          expect(filter.value, 'Thomas');
        });

        test('.notEqual', () {
          final query =
              Query(where: [Where('firstName', value: 'Thomas', compare: Compare.notEqual)]);
          final filter = repository.queryToPostgresChangeFilter<Customer>(query);

          expect(filter!.type, PostgresChangeFilterType.neq);
          expect(filter.column, 'first_name');
          expect(filter.value, 'Thomas');
        });

        test('.contains', () {
          final query =
              Query(where: [Where('firstName', value: 'Thomas', compare: Compare.contains)]);
          final filter = repository.queryToPostgresChangeFilter<Customer>(query);

          expect(filter!.type, PostgresChangeFilterType.inFilter);
          expect(filter.column, 'first_name');
          expect(filter.value, 'Thomas');
        });
      });
    });

    group('#subscribeToRealtime', () {
      group('#supabaseRealtimeSubscriptions', () {
        test('adds controller and query to #supabaseRealtimeSubscriptions', () async {
          expect(repository.supabaseRealtimeSubscriptions, hasLength(0));
          final query = Query.where('firstName', 'Thomas');
          repository.subscribeToRealtime<Customer>(query: query);
          expect(repository.supabaseRealtimeSubscriptions, hasLength(1));
          expect(repository.supabaseRealtimeSubscriptions[Customer], hasLength(1));
          expect(
            repository.supabaseRealtimeSubscriptions[Customer]![PostgresChangeEvent.all]!.entries
                .first.key,
            query,
          );
          expect(
            repository.supabaseRealtimeSubscriptions[Customer]![PostgresChangeEvent.all]!.entries
                .first.value,
            isNotNull,
          );
        });

        test('subscription succeeds when policy is non-default .alwaysHydrate', () async {
          expect(repository.supabaseRealtimeSubscriptions, hasLength(0));
          final query = Query.where('firstName', 'Thomas');
          repository.subscribeToRealtime<Customer>(
            policy: OfflineFirstGetPolicy.alwaysHydrate,
            query: query,
          );
          expect(repository.supabaseRealtimeSubscriptions, hasLength(1));
          expect(
            repository.supabaseRealtimeSubscriptions[Customer]![PostgresChangeEvent.all]!,
            hasLength(1),
          );
        });

        test('adds controller and null query to #supabaseRealtimeSubscriptions', () async {
          expect(repository.supabaseRealtimeSubscriptions, hasLength(0));
          repository.subscribeToRealtime<Customer>();
          expect(repository.supabaseRealtimeSubscriptions, hasLength(1));
          expect(repository.supabaseRealtimeSubscriptions[Customer], hasLength(1));
          expect(
            repository.supabaseRealtimeSubscriptions[Customer]![PostgresChangeEvent.all]!.entries
                .first.key,
            isNotNull,
          );
          expect(
            repository.supabaseRealtimeSubscriptions[Customer]![PostgresChangeEvent.all]!.entries
                .first.value,
            isNotNull,
          );
        });

        test('cancelling removes from #supabaseRealtimeSubscriptions', () async {
          expect(repository.supabaseRealtimeSubscriptions, hasLength(0));
          final subscription = repository.subscribeToRealtime<Customer>().listen((event) {});
          expect(repository.supabaseRealtimeSubscriptions[Customer], hasLength(1));
          await subscription.cancel();
          expect(repository.supabaseRealtimeSubscriptions, hasLength(0));
        });

        test('pausing does not remove from #supabaseRealtimeSubscriptions', () async {
          expect(repository.supabaseRealtimeSubscriptions, hasLength(0));
          final subscription = repository.subscribeToRealtime<Customer>().listen((event) {});
          expect(repository.supabaseRealtimeSubscriptions, hasLength(1));
          subscription.pause();
          expect(repository.supabaseRealtimeSubscriptions, hasLength(1));
          expect(
            repository.supabaseRealtimeSubscriptions[Customer]![PostgresChangeEvent.all]!.entries
                .first.value.isPaused,
            isTrue,
          );
        });
      });

      test('uses #subscribe for localOnly', () async {
        final customer = Customer(
          id: 1,
          firstName: 'Thomas',
          lastName: 'Guy',
          pizzas: [
            Pizza(id: 2, toppings: [Topping.pepperoni], frozen: false),
          ],
        );
        final sqliteResults = await repository.sqliteProvider.upsert<Customer>(customer);
        expect(sqliteResults, isNotNull);

        final customers =
            repository.subscribeToRealtime<Customer>(policy: OfflineFirstGetPolicy.localOnly);
        expect(customers, emits([customer]));
      });

      test('PostgresChangeEvent.insert', () async {
        final customer = Customer(
          id: 1,
          firstName: 'Thomas',
          lastName: 'Guy',
          pizzas: [
            Pizza(id: 2, toppings: [Topping.pepperoni], frozen: false),
          ],
        );

        final sqliteResults = await repository.sqliteProvider.get<Customer>();
        expect(sqliteResults, isEmpty);

        final customers =
            repository.subscribeToRealtime<Customer>(eventType: PostgresChangeEvent.insert);
        expect(
          customers,
          emitsInOrder([
            [],
            [customer],
          ]),
        );

        final req = SupabaseRequest<Customer>();
        final resp = SupabaseResponse(
          await mock.serialize(
            customer,
            realtimeEvent: PostgresChangeEvent.insert,
            repository: repository,
          ),
          realtimeEvent: PostgresChangeEvent.insert,
        );
        mock.handle({req: resp});

        await Future.delayed(const Duration(milliseconds: 100));

        final results = await repository.sqliteProvider.get<Customer>(repository: repository);
        expect(results, [customer]);
      });

      test('PostgresChangeEvent.delete', () async {
        final customer = Customer(
          id: 1,
          firstName: 'Thomas',
          lastName: 'Guy',
          pizzas: [
            Pizza(id: 2, toppings: [Topping.pepperoni], frozen: false),
          ],
        );

        final id =
            await repository.sqliteProvider.upsert<Customer>(customer, repository: repository);
        expect(id, isNotNull);

        final customers =
            repository.subscribeToRealtime<Customer>(eventType: PostgresChangeEvent.delete);
        expect(
          customers,
          emitsInOrder([
            [customer],
            [],
          ]),
        );

        final req = SupabaseRequest<Customer>();
        final resp = SupabaseResponse(
          await mock.serialize(
            customer,
            realtimeEvent: PostgresChangeEvent.delete,
            repository: repository,
          ),
          realtimeEvent: PostgresChangeEvent.delete,
        );
        mock.handle({req: resp});

        await Future.delayed(const Duration(milliseconds: 100));

        final results = await repository.sqliteProvider.get<Customer>(repository: repository);
        expect(results, isEmpty);
      });
    });
  });
}
