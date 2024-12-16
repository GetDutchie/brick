![brick_supabase workflow](https://github.com/GetDutchie/brick/actions/workflows/brick_supabase.yaml/badge.svg)

# Brick Supabase

Connecting [Brick](https://github.com/GetDutchie/brick) with Supabase.

## Supported `Query` Configuration

### `where:`

Brick currently does not support all of Supabase's filtering methods. Consider the associated `Compare` enum value to Supabase's method when building a Brick query:

| Brick                          | Supabase    |
| ------------------------------ | ----------- |
| `Compare.exact`                | `.eq`       |
| `Compare.notEqual`             | `.neq`      |
| `Compare.contains`             | `.like`     |
| `Compare.doesNotContain`       | `.not.like` |
| `Compare.greaterThan`          | `.gt`       |
| `Compare.greaterThanOrEqualTo` | `.gte`      |
| `Compare.lessThen`             | `.lt`       |
| `Compare.lessThenOrEqualTo`    | `.lte`      |
| `Compare.between`              | `.adj`      |

## Models

### `@SupabaseSerializable(tableName:)`

The Supabase table name must be specified to connect `from`, `upsert` and `delete` invocations:

```dart
@SupabaseSerializable(tableName: 'users')
class User
```

### `@SupabaseSerializable(fieldRename:)`

By default, Brick assumes the Dart field name is the camelized version of the Supabase column name (i.e. `final String lastName => 'last_name'`). However, this can be changed to rename all fields.

```dart
@SupabaseSerializable(fieldRename: FieldRename.pascal)
class User
```

`fieldRename` is only the default transformation. Naming can be overriden on a field-by-field basis with `@Supabase(name:)`.

### `@SupabaseSerializable(defaultToNull:)`

Forwards to [Supabase's defaultToNull](https://supabase.com/docs/reference/dart/upsert) during `upsert` operations.

### `@SupabaseSerializable(ignoreDuplicates:)`

Forwards to [Supabase's ignoreDuplicates](https://supabase.com/docs/reference/dart/upsert) during `upsert` operations.

### `@SupabaseSerializable(onConflict:)`

Forwards to [Supabase's onConflict](https://supabase.com/docs/reference/dart/upsert) during `upsert` operations.

## Fields

### `@Supabase(unique:)`

Connect Supabase's primary key (or any other index) to your application code. This is useful for `upsert` and `delete` logic when mutating instances.

```dart
@Supabase(unique: true, name: 'uuid')
final String supabaseUuid;
```

### `@Supabase(enumAsString:)`

Brick by default assumes enums from a Supabase API will be delivered as integers matching the index in the Flutter app. However, if your API delivers strings instead, the field can be easily annotated without writing a custom generator.

Given the API:

```json
{ "user": { "hats": ["bowler", "birthday"] } }
```

Simply convert `hats` into a Dart enum:

```dart
enum Hat { baseball, bowler, birthday }

...

@Supabase(enumAsString: true)
final List<Hat> hats;
```

### `@Supabase(name:)`

Supabase keys can be renamed per field. This will override the default set by `SupabaseSerializable#fieldRename`.

```dart
// "full_name" is used in from and to requests to Supabase instead of "last_name"
@Supabase(name: "full_name")
final String lastName;
```

**Do not use** `name` when annotating an association. Instead, use `foreignKey`.

:bulb: By default, Brick renames fields to be snake case when translating to Supabase, but you can change this default in the `@SupabaseSerializable(fieldRename:)` annotation that [decorates models](models.md).

### `@Supabase(foreignKey:)`

When the annotated field type extends the model's type, the Supabase column should be a foreign key.

```dart
class User extends OfflineFirstWithSupabaseModel{
  // The foreign key is a relation to the `id` column of the Address table
  @Supabase(foreignKey: 'address_id')
  final Address address;
}

class Address extends OfflineFirstWithSupabaseModel{
  final String id;
}
```

:bulb: The remote column type can be different than the local Dart type for associations. For example, `@Supabase(name: 'user_id')` that annotates `final User user` can be a Postgres string type.

### `@Supabase(ignoreFrom:)` and `@Supabase(ignoreTo:)`

When true, the field will be ignored by the (de)serializing function in the adapter.

## Testing

### Mocking a Supabase Instance

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

### SupabaseRequest

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

## Unsupported Field Types

The following are not serialized to Supabase. However, unsupported types can still be accessed in the model as non-final fields.

- Nested `List<>` e.g. `<List<List<int>>>`
- Many-to-many associations
