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

### ConnectOfflineFirstWithSupabase

`@ConnectOfflineFirstWithSupabase` decorates the model that can be serialized by one or more providers. Offline First does not have configuration at the class level and only extends configuration held by its providers:

```dart
@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(),
  sqliteConfig: SqliteSerializable(),
)
class MyModel extends OfflineFirstWithSupabaseModel {}
```

### FAQ

#### Why can't I declare a model argument?

Due to [an open analyzer bug](https://github.com/dart-lang/sdk/issues/38309), a custom model cannot be passed to the repository as a type argument.

## Unsupported Field Types

- Any unsupported field types from `SupabaseProvider`, or `SqliteProvider`
- Future iterables of future models (i.e. `Future<List<Future<Model>>>`).
