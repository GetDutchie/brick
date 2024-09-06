// ignore_for_file: unawaited_futures

import 'package:brick_supabase/src/supabase_provider.dart';
import 'package:brick_supabase/testing.dart';
import 'package:test/test.dart';

import '__mocks__.dart';

void main() {
  final mock = SupabaseMockServer(modelDictionary: supabaseModelDictionary);

  group('SupabaseProvider', () {
    setUp(mock.setUp);

    tearDown(mock.tearDown);

    test('#delete', () async {
      final req = SupabaseRequest<DemoModel>(
        requestMethod: 'DELETE',
        filter: 'id=eq.1',
        limit: 1,
      );
      final instance = DemoModel(age: 1, name: 'Demo 1', id: '1');
      final resp = SupabaseResponse(await mock.serialize(instance));

      mock.handle({req: resp});
      final provider = SupabaseProvider(mock.client, modelDictionary: supabaseModelDictionary);
      final didDelete = await provider.delete<DemoModel>(instance);
      expect(didDelete, true);
    });

    test('#exists', () async {
      final req = SupabaseRequest<DemoModel>();
      final instance = DemoModel(age: 1, name: 'Demo 1', id: '1');
      final resp = SupabaseResponse(
        [await mock.serialize(instance)],
        headers: {'content-range': '*/1'},
      );

      mock.handle({req: resp});
      final provider = SupabaseProvider(mock.client, modelDictionary: supabaseModelDictionary);
      final doesExist = await provider.exists<DemoModel>();
      expect(doesExist, true);
    });

    test('#get', () async {
      final req = SupabaseRequest<DemoModel>();
      final resp = SupabaseResponse([
        await mock.serialize(DemoModel(age: 1, name: 'Demo 1', id: '1')),
        await mock.serialize(DemoModel(age: 2, name: 'Demo 2', id: '2')),
      ]);
      mock.handle({req: resp});
      final provider = SupabaseProvider(mock.client, modelDictionary: supabaseModelDictionary);
      final retrieved = await provider.get<DemoModel>();
      expect(retrieved, hasLength(2));
      expect(retrieved[0].id, '1');
      expect(retrieved[1].id, '2');
      expect(retrieved[0].name, 'Demo 1');
      expect(retrieved[1].name, 'Demo 2');
      expect(retrieved[0].age, 1);
      expect(retrieved[1].age, 2);
    });

    group('#upsert', () {
      test('no associations', () async {
        final req = SupabaseRequest<DemoModel>(
          requestMethod: 'POST',
          filter: 'id=eq.1',
          limit: 1,
        );
        final instance = DemoModel(age: 1, name: 'Demo 1', id: '1');
        final resp = SupabaseResponse(await mock.serialize(instance));
        mock.handle({req: resp});

        final provider = SupabaseProvider(mock.client, modelDictionary: supabaseModelDictionary);
        final inserted = await provider.upsert<DemoModel>(instance);
        expect(inserted.id, instance.id);
        expect(inserted.age, instance.age);
        expect(inserted.name, instance.name);
      });

      test('one association', () async {
        final demoModelReq = SupabaseRequest<DemoModel>(
          requestMethod: 'POST',
          filter: 'id=eq.2',
          limit: 1,
        );
        final demoModelResp =
            SupabaseResponse(await mock.serialize(DemoModel(age: 1, name: 'Demo 1', id: '1')));
        final assocReq = SupabaseRequest<DemoAssociationModel>(
          requestMethod: 'POST',
          filter: 'id=eq.1',
          limit: 1,
        );
        final instance = DemoAssociationModel(
          assoc: DemoModel(age: 1, name: 'Nested', id: '2'),
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
    });
  });
}
