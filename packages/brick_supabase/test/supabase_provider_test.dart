// ignore_for_file: unawaited_futures

import 'package:brick_core/query.dart';
import 'package:brick_supabase/src/supabase_provider.dart';
import 'package:brick_supabase/src/supabase_provider_query.dart';
import 'package:brick_supabase/testing.dart';
import 'package:supabase/supabase.dart';
import 'package:test/test.dart';

import '__mocks__.dart';

void main() {
  final mock = SupabaseMockServer(modelDictionary: supabaseModelDictionary);

  group('SupabaseProvider', () {
    setUp(mock.setUp);

    tearDown(mock.tearDown);

    test('#delete', () async {
      const req = SupabaseRequest<Demo>(
        requestMethod: 'DELETE',
        filter: 'id=eq.1',
      );
      final instance = Demo(age: 1, name: 'Demo 1', id: '1');
      final resp = SupabaseResponse(await mock.serialize(instance));

      mock.handle({req: resp});
      final provider = SupabaseProvider(mock.client, modelDictionary: supabaseModelDictionary);
      final didDelete = await provider.delete<Demo>(instance);
      expect(didDelete, true);
    });

    test('#exists', () async {
      const req = SupabaseRequest<Demo>();
      final instance = Demo(age: 1, name: 'Demo 1', id: '1');
      final resp = SupabaseResponse(
        [await mock.serialize(instance)],
        headers: {'content-range': '*/1'},
      );

      mock.handle({req: resp});
      final provider = SupabaseProvider(mock.client, modelDictionary: supabaseModelDictionary);
      final doesExist = await provider.exists<Demo>();
      expect(doesExist, true);
    });

    test('#get', () async {
      const req = SupabaseRequest<Demo>();
      final resp = SupabaseResponse([
        await mock.serialize(Demo(age: 1, name: 'Demo 1', id: '1')),
        await mock.serialize(Demo(age: 2, name: 'Demo 2', id: '2')),
      ]);
      mock.handle({req: resp});
      final provider = SupabaseProvider(mock.client, modelDictionary: supabaseModelDictionary);
      final retrieved = await provider.get<Demo>();
      expect(retrieved, hasLength(2));
      expect(retrieved[0].id, '1');
      expect(retrieved[1].id, '2');
      expect(retrieved[0].name, 'Demo 1');
      expect(retrieved[1].name, 'Demo 2');
      expect(retrieved[0].age, 1);
      expect(retrieved[1].age, 2);
    });

    test('#insert', () async {
      const req = SupabaseRequest<Demo>(
        requestMethod: 'POST',
        filter: 'id=eq.1',
        limit: 1,
      );
      final instance = Demo(age: 1, name: 'Demo 1', id: '1');
      final resp = SupabaseResponse(await mock.serialize(instance));
      mock.handle({req: resp});

      final provider = SupabaseProvider(mock.client, modelDictionary: supabaseModelDictionary);
      final inserted = await provider.insert<Demo>(instance);
      expect(inserted.id, instance.id);
      expect(inserted.age, instance.age);
      expect(inserted.name, instance.name);
    });

    group('#queryToPostgresChangeFilter', () {
      late SupabaseProvider provider;

      setUp(() {
        provider = SupabaseProvider(mock.client, modelDictionary: supabaseModelDictionary);
      });

      group('returns null', () {
        test('for complex queries', () {
          final query = Query.where('assoc', const Where.exact('id', 2));
          expect(provider.queryToPostgresChangeFilter<DemoAssociationModel>(query), isNull);
        });

        test('for empty queries', () {
          const query = Query();
          expect(provider.queryToPostgresChangeFilter<Demo>(query), isNull);
        });

        test('for missing columns', () {
          final query = Query.where('unknown', 1);
          expect(provider.queryToPostgresChangeFilter<Demo>(query), isNull);
        });
      });

      group('Compare', () {
        test('.between', () {
          final query = Query(where: [const Where('id').isBetween(1, 2)]);
          final filter = provider.queryToPostgresChangeFilter<Demo>(query);
          expect(filter, isNull);
        });

        test('.doesNotContain', () {
          final query = Query(where: [const Where('name').doesNotContain('Thomas')]);
          final filter = provider.queryToPostgresChangeFilter<Demo>(query);
          expect(filter, isNull);
        });

        test('.exact', () {
          const query = Query(where: [Where.exact('name', 'Thomas')]);
          final filter = provider.queryToPostgresChangeFilter<Demo>(query);

          expect(filter!.type, PostgresChangeFilterType.eq);
          expect(filter.column, 'name');
          expect(filter.value, 'Thomas');
        });

        test('.greaterThan', () {
          final query = Query(where: [const Where('age').isGreaterThan(5)]);
          final filter = provider.queryToPostgresChangeFilter<Demo>(query);

          expect(filter!.type, PostgresChangeFilterType.gt);
          expect(filter.column, 'age');
          expect(filter.value, 5);
        });

        test('.greaterThanOrEqualTo', () {
          final query = Query(where: [const Where('age').isGreaterThanOrEqualTo(5)]);
          final filter = provider.queryToPostgresChangeFilter<Demo>(query);

          expect(filter!.type, PostgresChangeFilterType.gte);
          expect(filter.column, 'age');
          expect(filter.value, 5);
        });

        test('.lessThan', () {
          final query = Query(where: [const Where('age').isLessThan(5)]);
          final filter = provider.queryToPostgresChangeFilter<Demo>(query);

          expect(filter!.type, PostgresChangeFilterType.lt);
          expect(filter.column, 'age');
          expect(filter.value, 5);
        });

        test('.lessThanOrEqualTo', () {
          final query = Query(where: [const Where('age').isLessThanOrEqualTo(5)]);
          final filter = provider.queryToPostgresChangeFilter<Demo>(query);

          expect(filter!.type, PostgresChangeFilterType.lte);
          expect(filter.column, 'age');
          expect(filter.value, 5);
        });

        test('.notEqual', () {
          final query = Query(where: [const Where('name').isNot('Thomas')]);
          final filter = provider.queryToPostgresChangeFilter<Demo>(query);

          expect(filter!.type, PostgresChangeFilterType.neq);
          expect(filter.column, 'name');
          expect(filter.value, 'Thomas');
        });

        test('.contains', () {
          final query = Query(where: [const Where('name').contains('Thomas')]);
          final filter = provider.queryToPostgresChangeFilter<Demo>(query);

          expect(filter!.type, PostgresChangeFilterType.inFilter);
          expect(filter.column, 'name');
          expect(filter.value, 'Thomas');
        });
      });
    });

    test('#subscribeToRealtime', () {
      final provider = SupabaseProvider(mock.client, modelDictionary: supabaseModelDictionary);
      final stream = provider.subscribeToRealtime<Demo>(callback: (payload) {});

      expect(stream, isNotNull);
      // ignore: invalid_use_of_internal_member
      expect(stream.joinRef, isNotNull);
      expect(
        // ignore: invalid_use_of_internal_member
        stream.topic,
        'realtime:${supabaseModelDictionary.adapterFor[Demo]!.supabaseTableName}',
      );
    });

    test('#update', () async {
      const req = SupabaseRequest<Demo>(
        requestMethod: 'PATCH',
        filter: 'id=eq.1',
        limit: 1,
      );
      final instance = Demo(age: 1, name: 'Demo 1', id: '1');
      final resp = SupabaseResponse(await mock.serialize(instance));
      mock.handle({req: resp});

      final provider = SupabaseProvider(mock.client, modelDictionary: supabaseModelDictionary);
      final inserted = await provider.update<Demo>(instance);
      expect(inserted.id, instance.id);
      expect(inserted.age, instance.age);
      expect(inserted.name, instance.name);
    });

    group('#upsert', () {
      test('no associations', () async {
        const req = SupabaseRequest<Demo>(
          requestMethod: 'POST',
          filter: 'id=eq.1',
          limit: 1,
        );
        final instance = Demo(age: 1, name: 'Demo 1', id: '1');
        final resp = SupabaseResponse(await mock.serialize(instance));
        mock.handle({req: resp});

        final provider = SupabaseProvider(mock.client, modelDictionary: supabaseModelDictionary);
        final inserted = await provider.upsert<Demo>(instance);
        expect(inserted.id, instance.id);
        expect(inserted.age, instance.age);
        expect(inserted.name, instance.name);
      });

      test('one association', () async {
        const demoModelReq = SupabaseRequest<Demo>(
          requestMethod: 'POST',
          filter: 'id=eq.2',
          limit: 1,
        );
        final demoModelResp =
            SupabaseResponse(await mock.serialize(Demo(age: 1, name: 'Demo 1', id: '1')));
        const assocReq = SupabaseRequest<DemoAssociationModel>(
          requestMethod: 'POST',
          filter: 'id=eq.1',
          limit: 1,
        );
        final instance = DemoAssociationModel(
          assoc: Demo(age: 1, name: 'Nested', id: '2'),
          name: 'Demo 1',
          id: '1',
        );
        final assocResp = SupabaseResponse(await mock.serialize(instance));
        mock.handle({demoModelReq: demoModelResp, assocReq: assocResp});

        final provider = SupabaseProvider(mock.client, modelDictionary: supabaseModelDictionary);

        final inserted = await provider.upsert<DemoAssociationModel>(instance);
        expect(inserted.id, instance.id);
        expect(inserted.assoc.age, instance.assoc.age);
        expect(inserted.assoc.id, instance.assoc.id);
        expect(inserted.name, instance.name);
      });

      test('with non-default method from query', () async {
        const req = SupabaseRequest<Demo>(
          requestMethod: 'PATCH',
          filter: 'id=eq.1',
          limit: 1,
        );
        final instance = Demo(age: 1, name: 'Demo 1', id: '1');
        final resp = SupabaseResponse(await mock.serialize(instance));
        mock.handle({req: resp});

        final provider = SupabaseProvider(mock.client, modelDictionary: supabaseModelDictionary);
        final inserted = await provider.upsert<Demo>(
          instance,
          query: const Query(
            forProviders: [SupabaseProviderQuery(upsertMethod: UpsertMethod.update)],
          ),
        );
        expect(inserted.id, instance.id);
        expect(inserted.age, instance.age);
        expect(inserted.name, instance.name);
      });
    });
  });
}
