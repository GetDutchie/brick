# Offline First With Supabase Repository

`OfflineFirstWithSupabaseRepository` streamlines the Supabase integration with an `OfflineFirstRepository`. A [serial queue](offline_queue.md) is included to track Supabase mutations in a separate SQLite database, only removing requests when a response is returned from the host (i.e. the device has lost internet connectivity).

The `OfflineFirstWithSupabase` domain uses all the same configurations and annotations as `OfflineFirst`.

![OfflineFirst#get](https://user-images.githubusercontent.com/865897/72176226-cdd8ca00-3392-11ea-867d-42f5f4620153.jpg)

!> You can change default behavior on a per-request basis using `policy:` (e.g. `get<Person>(policy: OfflineFirstUpsertPolicy.localOnly)`). This is available for `delete`, `get`, `getBatched`, `subscribe`, and `upsert`.

## Packages

`brick_offline_first_with_supabase` and `brick_offline_first_with_supabase_build` are required in your `pubspec.yaml`:

```yaml
dependencies:
  brick_offline_first_with_supabase: any
dev_dependencies:
  brick_offline_first_with_supabase_build: any
  build_runner: any
```

## Repository Configuration

The repository utilizes the `OfflineFirstWithRestRepository`'s queue because the Supabase client is a thin wrapper around the PostgREST API. There's a small amount of configuration to apply this queue:

```dart
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

### ConnectOfflineFirstWithSupabase

`@ConnectOfflineFirstWithSupabase` decorates the model that can be serialized by one or more providers. Offline First does not have configuration at the class level and only extends configuration held by its providers:

```dart
@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(),
  sqliteConfig: SqliteSerializable(),
)
class MyModel extends OfflineFirstWithSupabaseModel {}
```

## OfflineFirst(where:)

Ideally, `@OfflineFirst(where:)` shouldn't be necessary to specify to make the association between local Brick and remote Supabase because the generated Supabase `.select` should include all nested fields. However, if there are [too many](https://github.com/GetDutchie/brick/issues/399) REST calls, it may be necessary to guide Brick to the right foreign keys.

```dart
@OfflineFirst(where: {'id': "data['otherId']"})
// Explicitly specifying `name:` can ensure that the two annotations
// definitely have the same values
@Supabase(name: 'otherId')
final Pizza pizza;
```

!> Multiple `where` keys (`OfflineFirst(where: {'id': 'data["id"]', 'otherVar': 'data["otherVar"]'})`) will be ignored. Nested properties (`OfflineFirst(where: {'id': 'data["subfield"]["id"]})`) will also be ignored.
