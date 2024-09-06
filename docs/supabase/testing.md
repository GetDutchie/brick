# Testing

## Mocking a Supabase Instance

Quickly create a convenient mock server within test groups. The server should be configured to reset after every test block. Strongly-typed Dart models can be used to protect against code drift.

```dart
import 'package:brick_supabase/testing.dart';
import 'package:test/test.dart'

void main() {
  // Pass an instance of your model dictionary to the mock server.
  // This permits quick generation of fields and generated responses
  final mock = SupabaseMockServer(modelDictionary: supabaseModelDictionary);

  group('MyClass', () {
    setUp(mock.setUp);

    tearDown(mock.tearDown);

    test('#myMethod', () async {
      // If your request won't exactly match the columns of MyModel, provide
      // the query list to the `fields:` parameter
      final req = SupabaseRequest<MyModel>();
      final resp = SupabaseResponse([
        // mock.serialize converts models to expected Supabase payloads
        // but you don't need to use it - any jsonEncode-able object
        // can be passed to SupabaseRepsonse
        await mock.serialize(MyModel(name: 'Demo 1', id: '1')),
        await mock.serialize(MyModel(name: 'Demo 2', id: '2')),
      ]);
      // This method stubs the server based on the described requests
      // and their matched responses
      mock.handle({req: resp});
      final provider = SupabaseProvider(mock.client, modelDictionary: supabaseModelDictionary);
      final retrieved = await provider.get<MyModel>();
      expect(retrieved, hasLength(2));
    });
  });
}
```

## SupabaseRequest

The request object can be much more detailed. A type argument (e.g. `<MyModel>`) is not necessary if `fields:` are passed as a parameter.

It's important to specify the `filter` parameter for more complex queries or nested association upserts:

```dart
final upsertReq = SupabaseRequest<MyModel>(
  requestMethod: 'POST',
  // Filter will specify to only return the response if the filter also matches
  // This is an important parameter when querying for a specific property
  // or using multiple requests/responses
  filter: 'id=eq.2',
  limit: 1,
);
final associationUpsertReq = SupabaseRequest<AssociationModel>(
  requestMethod: 'POST',
  filter: 'id=eq.1',
  limit: 1,
);
final baseResp = SupabaseResponse(await mock.serialize(MyModel(age: 1, name: 'Demo 1', id: '1')));
final associationResp = SupabaseResponse(
  await mock.serialize(AssociationModel(
    assoc: MyModel(age: 1, name: 'Nested', id: '2'),
    name: 'Demo 1',
    id: '1',
  )),
);
mock.handle({upsertReq: baseResp, associationUpsertReq: associationResp});
```

?> See [supabase_provider_test.dart](https://github.com/GetDutchie/brick/blob/main/packages/brick_supabase/test/supabase_provider_test.dart) for more practial examples that use all `SupabaseProvider` methods, or [offline_first_with_supabase_repository.dart](https://github.com/GetDutchie/brick/blob/main/packages/brick_offline_first_with_supabase/test/offline_first_with_supabase_repository_test.dart) for mocking with a repository.
