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
        final localPizzas = await repository.sqliteProvider.get<Pizza>(repository: repository);
        expect(localPizzas, hasLength(1));
      });
    });

    group('#queryFromSupabaseDeletePayload', () {
      test('simple', () {
        final payload = {
          'id': 1,
        };

        final supabaseDefinitions = {
          'id': RuntimeSupabaseColumnDefinition(columnName: 'id'),
          'name': RuntimeSupabaseColumnDefinition(columnName: 'name'),
        };

        final query = repository.queryFromSupabaseDeletePayload(
          payload,
          supabaseDefinitions: supabaseDefinitions,
        );

        expect(query.where, hasLength(1));
        expect(query.where!.first.evaluatedField, 'id');
        expect(query.where!.first.value, 1);
        expect(query.providerArgs, equals({'limit': 1}));
      });

      test('payload entries not present in supabaseDefinitions', () {
        final payload = {
          'id': 1,
          'unknown_field': 'some value',
        };

        final supabaseDefinitions = {
          'id': RuntimeSupabaseColumnDefinition(columnName: 'id'),
          'name': RuntimeSupabaseColumnDefinition(columnName: 'name'),
        };

        final query = repository.queryFromSupabaseDeletePayload(
          payload,
          supabaseDefinitions: supabaseDefinitions,
        );

        expect(query.where, hasLength(1));
        expect(query.where!.first.evaluatedField, 'id');
        expect(query.where!.first.value, 1);
        expect(query.providerArgs, equals({'limit': 1}));
      });

      test('empty payload', () {
        final payload = <String, dynamic>{};
        final supabaseDefinitions = {
          'id': RuntimeSupabaseColumnDefinition(columnName: 'id'),
        };

        final query = repository.queryFromSupabaseDeletePayload(
          payload,
          supabaseDefinitions: supabaseDefinitions,
        );

        expect(query.where, isEmpty);
      });

      test('payload with no matching definitions', () {
        final payload = {
          'unknown_field': 'some value',
        };
        final supabaseDefinitions = {
          'id': RuntimeSupabaseColumnDefinition(columnName: 'id'),
        };

        final query = repository.queryFromSupabaseDeletePayload(
          payload,
          supabaseDefinitions: supabaseDefinitions,
        );

        expect(query.where, isEmpty);
      });

      test('different column names', () {
        final payload = {
          'user_id': 1,
        };

        final supabaseDefinitions = {
          'id': RuntimeSupabaseColumnDefinition(columnName: 'user_id'),
          'name': RuntimeSupabaseColumnDefinition(columnName: 'full_name'),
        };

        final query = repository.queryFromSupabaseDeletePayload(
          payload,
          supabaseDefinitions: supabaseDefinitions,
        );

        expect(query.where, hasLength(1));
        expect(query.where!.first.evaluatedField, 'id');
        expect(query.where!.first.value, 1);
        expect(query.providerArgs, equals({'limit': 1}));
      });

      test('multiple columns', () {
        final payload = {
          'user_id': 1,
          'full_name': 'Thomas',
        };

        final supabaseDefinitions = {
          'id': RuntimeSupabaseColumnDefinition(columnName: 'user_id'),
          'name': RuntimeSupabaseColumnDefinition(columnName: 'full_name'),
        };

        final query = repository.queryFromSupabaseDeletePayload(
          payload,
          supabaseDefinitions: supabaseDefinitions,
        );

        expect(query.where, hasLength(2));
        expect(query.where!.first.evaluatedField, 'id');
        expect(query.where!.first.value, 1);
        expect(query.where!.last.evaluatedField, 'name');
        expect(query.where!.last.value, 'Thomas');
        expect(query.providerArgs, equals({'limit': 1}));
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
          final query = Query(where: [Where('firstName').isBetween(1, 2)]);
          final filter = repository.queryToPostgresChangeFilter<Customer>(query);
          expect(filter, isNull);
        });

        test('.doesNotContain', () {
          final query = Query(where: [Where('firstName').doesNotContain('Thomas')]);
          final filter = repository.queryToPostgresChangeFilter<Customer>(query);
          expect(filter, isNull);
        });

        test('.exact', () {
          final query = Query(where: [Where.exact('firstName', 'Thomas')]);
          final filter = repository.queryToPostgresChangeFilter<Customer>(query);

          expect(filter!.type, PostgresChangeFilterType.eq);
          expect(filter.column, 'first_name');
          expect(filter.value, 'Thomas');
        });

        test('.greaterThan', () {
          final query = Query(where: [Where('firstName').isGreaterThan('Thomas')]);
          final filter = repository.queryToPostgresChangeFilter<Customer>(query);

          expect(filter!.type, PostgresChangeFilterType.gt);
          expect(filter.column, 'first_name');
          expect(filter.value, 'Thomas');
        });

        test('.greaterThanOrEqualTo', () {
          final query = Query(
            where: [Where('firstName').isGreaterThanOrEqualTo('Thomas')],
          );
          final filter = repository.queryToPostgresChangeFilter<Customer>(query);

          expect(filter!.type, PostgresChangeFilterType.gte);
          expect(filter.column, 'first_name');
          expect(filter.value, 'Thomas');
        });

        test('.lessThan', () {
          final query = Query(where: [Where('firstName').isLessThan('Thomas')]);
          final filter = repository.queryToPostgresChangeFilter<Customer>(query);

          expect(filter!.type, PostgresChangeFilterType.lt);
          expect(filter.column, 'first_name');
          expect(filter.value, 'Thomas');
        });

        test('.lessThanOrEqualTo', () {
          final query = Query(
            where: [Where('firstName').isLessThanOrEqualTo('Thomas')],
          );
          final filter = repository.queryToPostgresChangeFilter<Customer>(query);

          expect(filter!.type, PostgresChangeFilterType.lte);
          expect(filter.column, 'first_name');
          expect(filter.value, 'Thomas');
        });

        test('.notEqual', () {
          final query = Query(where: [Where('firstName').isNot('Thomas')]);
          final filter = repository.queryToPostgresChangeFilter<Customer>(query);

          expect(filter!.type, PostgresChangeFilterType.neq);
          expect(filter.column, 'first_name');
          expect(filter.value, 'Thomas');
        });

        test('.contains', () {
          final query = Query(where: [Where('firstName').contains('Thomas')]);
          final filter = repository.queryToPostgresChangeFilter<Customer>(query);

          expect(filter!.type, PostgresChangeFilterType.inFilter);
          expect(filter.column, 'first_name');
          expect(filter.value, 'Thomas');
        });
      });
    });

    group('#supabaseRealtimeSubscriptions', () {
      test('adds controller and query to #supabaseRealtimeSubscriptions', () async {
        expect(repository.supabaseRealtimeSubscriptions, hasLength(0));
        final query = Query.where('firstName', 'Thomas');
        final subscription = repository.subscribeToRealtime<Customer>(query: query).listen((_) {});

        expect(repository.supabaseRealtimeSubscriptions[Customer], hasLength(1));
        expect(
          repository
              .supabaseRealtimeSubscriptions[Customer]![PostgresChangeEvent.all]!.entries.first.key,
          query,
        );
        expect(
          repository.supabaseRealtimeSubscriptions[Customer]![PostgresChangeEvent.all]!.entries
              .first.value,
          isNotNull,
        );
        await subscription.cancel();
        await Future.delayed(Duration(milliseconds: 10));
      });

      test('subscription succeeds when policy is non-default .alwaysHydrate', () async {
        expect(repository.supabaseRealtimeSubscriptions, hasLength(0));
        final query = Query.where('firstName', 'Thomas');
        final subscription = repository
            .subscribeToRealtime<Customer>(
              policy: OfflineFirstGetPolicy.alwaysHydrate,
              query: query,
            )
            .listen((_) {});
        expect(repository.supabaseRealtimeSubscriptions, hasLength(1));
        expect(
          repository.supabaseRealtimeSubscriptions[Customer]![PostgresChangeEvent.all]!,
          hasLength(1),
        );
        await subscription.cancel();
        await Future.delayed(Duration(milliseconds: 10));
      });

      test('adds controller and null query to #supabaseRealtimeSubscriptions', () async {
        expect(repository.supabaseRealtimeSubscriptions, hasLength(0));
        final subscription = repository.subscribeToRealtime<Customer>().listen((_) {});
        expect(repository.supabaseRealtimeSubscriptions, hasLength(1));
        expect(repository.supabaseRealtimeSubscriptions[Customer], hasLength(1));
        expect(
          repository
              .supabaseRealtimeSubscriptions[Customer]![PostgresChangeEvent.all]!.entries.first.key,
          isNotNull,
        );
        expect(
          repository.supabaseRealtimeSubscriptions[Customer]![PostgresChangeEvent.all]!.entries
              .first.value,
          isNotNull,
        );
        await subscription.cancel();
        await Future.delayed(Duration(milliseconds: 10));
      });

      test('cancelling removes from #supabaseRealtimeSubscriptions', () async {
        expect(repository.supabaseRealtimeSubscriptions, hasLength(0));
        final subscription = repository.subscribeToRealtime<Customer>().listen((event) {});
        expect(repository.supabaseRealtimeSubscriptions[Customer], hasLength(1));
        await subscription.cancel();
        expect(repository.supabaseRealtimeSubscriptions, hasLength(0));
        await Future.delayed(Duration(milliseconds: 10));
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
        await subscription.cancel();
        await Future.delayed(Duration(milliseconds: 10));
      });
    });

    group('#subscribeToRealtime', () {
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

      group('eventType:', () {
        test('PostgresChangeEvent.insert', () async {
          final customer = Customer(
            id: 1,
            firstName: 'Thomas',
            lastName: 'Guy',
            pizzas: [
              Pizza(id: 2, toppings: [Topping.pepperoni], frozen: false),
            ],
          );

          final sqliteResults =
              await repository.sqliteProvider.get<Customer>(repository: repository);
          expect(sqliteResults, isEmpty);

          final customers =
              repository.subscribeToRealtime<Customer>(eventType: PostgresChangeEvent.insert);
          expect(
            customers,
            emitsInOrder([
              [],
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
          );
          mock.handle({req: resp});

          // Wait for request to be handled
          await Future.delayed(const Duration(milliseconds: 200));

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
          );
          mock.handle({req: resp});

          // Wait for request to be handled
          await Future.delayed(const Duration(milliseconds: 200));

          final results = await repository.sqliteProvider.get<Customer>(repository: repository);
          expect(results, isEmpty);
        });

        test('PostgresChangeEvent.update', () async {
          final customer1 = Customer(
            id: 1,
            firstName: 'Thomas',
            lastName: 'Guy',
            pizzas: [
              Pizza(id: 2, toppings: [Topping.pepperoni], frozen: false),
            ],
          );
          final customer2 = Customer(
            id: 1,
            firstName: 'Guy',
            lastName: 'Thomas',
            pizzas: [
              Pizza(id: 2, toppings: [Topping.pepperoni], frozen: false),
            ],
          );

          final id =
              await repository.sqliteProvider.upsert<Customer>(customer1, repository: repository);
          expect(id, isNotNull);

          final customers =
              repository.subscribeToRealtime<Customer>(eventType: PostgresChangeEvent.update);
          expect(
            customers,
            emitsInOrder([
              [customer1],
              [customer1],
              [customer2],
            ]),
          );

          final req = SupabaseRequest<Customer>();
          final resp = SupabaseResponse(
            await mock.serialize(
              customer2,
              realtimeEvent: PostgresChangeEvent.update,
              repository: repository,
            ),
          );
          mock.handle({req: resp});
        });

        group('as .all and ', () {
          test('PostgresChangeEvent.insert', () async {
            final customer = Customer(
              id: 1,
              firstName: 'Thomas',
              lastName: 'Guy',
              pizzas: [
                Pizza(id: 2, toppings: [Topping.pepperoni], frozen: false),
              ],
            );

            final sqliteResults =
                await repository.sqliteProvider.get<Customer>(repository: repository);
            expect(sqliteResults, isEmpty);

            final customers = repository.subscribeToRealtime<Customer>();
            expect(
              customers,
              emitsInOrder([
                [],
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
            );
            mock.handle({req: resp});

            // Wait for request to be handled
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

            final customers = repository.subscribeToRealtime<Customer>();
            expect(
              customers,
              emitsInOrder([
                [customer],
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
            );
            mock.handle({req: resp});

            // Wait for request to be handled
            await Future.delayed(const Duration(milliseconds: 200));

            final results = await repository.sqliteProvider.get<Customer>(repository: repository);
            expect(results, isEmpty);
          });

          test('PostgresChangeEvent.update', () async {
            final customer1 = Customer(
              id: 1,
              firstName: 'Thomas',
              lastName: 'Guy',
              pizzas: [
                Pizza(id: 2, toppings: [Topping.pepperoni], frozen: false),
              ],
            );
            final customer2 = Customer(
              id: 1,
              firstName: 'Guy',
              lastName: 'Thomas',
              pizzas: [
                Pizza(id: 2, toppings: [Topping.pepperoni], frozen: false),
              ],
            );

            final id =
                await repository.sqliteProvider.upsert<Customer>(customer1, repository: repository);
            expect(id, isNotNull);

            final customers = repository.subscribeToRealtime<Customer>();
            expect(
              customers,
              emitsInOrder([
                [customer1],
                [customer1],
                [customer2],
              ]),
            );

            final req = SupabaseRequest<Customer>();
            final resp = SupabaseResponse(
              await mock.serialize(
                customer2,
                realtimeEvent: PostgresChangeEvent.update,
                repository: repository,
              ),
            );
            mock.handle({req: resp});
          });

          test('with multiple events', () async {
            final customer1 = Customer(
              id: 1,
              firstName: 'Thomas',
              lastName: 'Guy',
              pizzas: [
                Pizza(id: 2, toppings: [Topping.pepperoni], frozen: false),
              ],
            );
            final customer2 = Customer(
              id: 1,
              firstName: 'Guy',
              lastName: 'Thomas',
              pizzas: [
                Pizza(id: 2, toppings: [Topping.pepperoni], frozen: false),
              ],
            );

            final customers = repository.subscribeToRealtime<Customer>();
            expect(
              customers,
              emitsInOrder([
                [],
                [],
                [customer1],
                [customer2],
              ]),
            );

            final req = SupabaseRequest<Customer>();
            final resp = SupabaseResponse(
              await mock.serialize(
                customer1,
                realtimeEvent: PostgresChangeEvent.insert,
                repository: repository,
              ),
              realtimeSubsequentReplies: [
                SupabaseResponse(
                  await mock.serialize(
                    customer2,
                    realtimeEvent: PostgresChangeEvent.update,
                    repository: repository,
                  ),
                ),
              ],
            );
            mock.handle({req: resp});
          });
        });
      });
    });
  });
}
