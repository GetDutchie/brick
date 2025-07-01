// ignore_for_file: unawaited_futures

import 'package:brick_core/query.dart';
import 'package:brick_supabase/src/supabase_provider.dart';
import 'package:brick_supabase/src/supabase_provider_query.dart';
import 'package:brick_supabase/testing.dart';
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

    group('#upsertMany', () {
      test('insert multiple', () async {
        const req1 = SupabaseRequest<Demo>(
          requestMethod: 'POST',
          filter: 'id=eq.1',
          limit: 1,
        );
        const req2 = SupabaseRequest<Demo>(
          requestMethod: 'POST',
          filter: 'id=eq.2',
          limit: 1,
        );
        final instance1 = Demo(age: 1, name: 'Demo 1', id: '1');
        final instance2 = Demo(age: 2, name: 'Demo 2', id: '2');
        final resp1 = SupabaseResponse(await mock.serialize(instance1));
        final resp2 = SupabaseResponse(await mock.serialize(instance2));
        mock.handle({req1: resp1, req2: resp2});

        final provider = SupabaseProvider(mock.client, modelDictionary: supabaseModelDictionary);
        final inserted = await provider.upsertMany<Demo>([instance1, instance2]);
        expect(inserted, hasLength(2));
        expect(inserted[0].id, instance1.id);
        expect(inserted[1].id, instance2.id);
        expect(inserted[0].name, instance1.name);
        expect(inserted[1].name, instance2.name);
        expect(inserted[0].age, instance1.age);
        expect(inserted[1].age, instance2.age);
      });
    });
  });
}
