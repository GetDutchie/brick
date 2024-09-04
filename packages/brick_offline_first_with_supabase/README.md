![brick_offline_first_with_supabase workflow](https://github.com/GetDutchie/brick/actions/workflows/brick_offline_first_with_supabase.yaml/badge.svg)

`OfflineFirstWithSupabaseRepository` streamlines the Supabase integration with an `OfflineFirstRepository`.

The `OfflineFirstWithSupabase` domain uses all the same configurations and annotations as `OfflineFirst`.

## Repository

The repository utilizes the `OfflineFirstWithRestRepository`'s queue because the Supabase client is a thin wrapper around the PostgREST API. There's a small amount of configuration to apply this queue:

```dart
// import brick.g.dart and brick/db/schema.g.dart

class MyRepository extends OfflineFirstWithSupabaseRepository {
  static late MyRepository? _singleton;

  MyRepository._({
    required super.supabaseProvider,
    required super.sqliteProvider,
    required super.migrations,
    required super.offlineRequestQueue,
    super.memoryCacheProvider,
  });

  factory MyRepository() => _singleton!;

  static void configure({
    required String supabaseUrl,
    required String supabaseAnonKey,
  }) {
    // Convenience method `.clientQueue` makes creating the queue and client easy.
    final (client, queue) = OfflineFirstWithSupabaseRepository.clientQueue(
      // For Flutter, use import 'package:sqflite/sqflite.dart' show databaseFactory;
      // For unit testing (even in Flutter), use import 'package:sqflite_common_ffi/sqflite_ffi.dart' show databaseFactory;
      databaseFactory: databaseFactory,
    );

    final provider = SupabaseProvider(
      SupabaseClient(supabaseUrl, supabaseAnonKey, httpClient: client),
      modelDictionary: supabaseModelDictionary,
    );

    // Finally, initialize the repository as normal.
    _singleton = MyRepository._(
      supabaseProvider: provider,
      sqliteProvider: SqliteProvider(
        'my_repository.sqlite',
        databaseFactory: databaseFactory,
        modelDictionary: sqliteModelDictionary,
      ),
      migrations: migrations,
      offlineRequestQueue: queue,
      memoryCacheProvider: MemoryCacheProvider(),
    );
  }
}
```

When using [supabase_flutter](https://pub.dev/packages/supabase_flutter), create the client and queue before initializing:

```dart
final (client, queue) = OfflineFirstWithSupabaseRepository.clientQueue(databaseFactory: databaseFactory);
await Supabase.initialize(httpClient: client)
final supabaseProvider = SupabaseProvider(Supabase.instance.client, modelDictionary: ...)
```

## Models

### @ConnectOfflineFirstWithSupabase

`@ConnectOfflineFirstWithSupabase` decorates the model that can be serialized by one or more providers. Offline First does not have configuration at the class level and only extends configuration held by its providers:

```dart
@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(),
  sqliteConfig: SqliteSerializable(),
)
class MyModel extends OfflineFirstWithSupabaseModel {}
```

### Associations and Foreign Keys

Field types of classes that `extends OfflineFirstWithSupabaseModel` will automatically be assumed as a foreign key in Supabase. You will only need to specify the column name if it differs from your field name to help Brick fetch the right data and serialize/deserialize it locally.

```dart
class User extends OfflineFirstWithSupabaseModel {
  // The foreign key is a relation to the `id` column of the Address table
  @Supabase(name: 'address_id')
  final Address address;
}

class Address extends OfflineFirstWithSupabaseModel{
  final String id;
}
```

:warning: If your association is nullable (e.g. `Address?`), the Supabase response may include all `User`s from the database from a loosely-specified query. This is caused by PostgREST's [filtering](https://docs.postgrest.org/en/v12/references/api/resource_embedding.html#top-level-filtering). Brick does not use `!inner` to query tables because there is no guarantee that a model does not have multiple fields relating to the same association; it instead explicitly declares the foreign key with [not.is.null](https://docs.postgrest.org/en/v12/references/api/resource_embedding.html#null-filtering-on-embedded-resources) filtering. If a Dart association is nullable, Brick will not append the `not.is.null` which could return [all results](https://github.com/GetDutchie/brick/issues/429#issuecomment-2325941205). If you have a use case that requires a nullable association and you cannot circumvent this problem with [Supabase's policies](https://supabase.com/docs/guides/database/postgres/row-level-security), please open an issue and provide extensive detail.

#### OfflineFirst(where:)

Ideally, `@OfflineFirst(where:)` shouldn't be necessary to specify to make the association between local Brick and remote Supabase because the generated Supabase `.select` should include all nested fields. However, if there are [too many](https://github.com/GetDutchie/brick/issues/399) REST calls, it may be necessary to guide Brick to the right foreign keys.

```dart
@OfflineFirst(where: {'id': "data['otherId']"})
// Explicitly specifying `name:` can ensure that the two annotations
// definitely have the same values
// Alternatively, you can invoke nested maps (e.g. {'id': "data['pizza']['id']"})
@Supabase(name: 'otherId')
final Pizza pizza;
```

### FAQ

#### Why can't I declare a model argument?

Due to [an open analyzer bug](https://github.com/dart-lang/sdk/issues/38309), a custom model cannot be passed to the repository as a type argument.

## Unsupported Field Types

- Any unsupported field types from `SupabaseProvider`, or `SqliteProvider`
- Future iterables of future models (i.e. `Future<List<Future<Model>>>`).
