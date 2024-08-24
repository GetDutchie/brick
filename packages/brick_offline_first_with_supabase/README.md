![brick_offline_first_with_supabase workflow](https://github.com/GetDutchie/brick/actions/workflows/brick_offline_first_with_supabase.yaml/badge.svg)

`OfflineFirstWithSupabaseRepository` streamlines the Supabase integration with an `OfflineFirstRepository`.

The `OfflineFirstWithSupabase` domain uses all the same configurations and annotations as `OfflineFirst`.

## Repository

Adding offline support to Supabase is slightly more complicated than the average [../brick_offline_first_with_rest/README.md](repository process). Feedback is welcome on a smoother and more intuitive integration.

````dart
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
    required String apiKey,
    required Set<Migration> migrations,
  }) {
    // Convenience method `.clientQueue` makes creating the queue and client easy.
    final (client, queue) = OfflineFirstWithSupabaseRepository.clientQueue(
      databaseFactory: databaseFactory,
    );

    final provider = SupabaseProvider(
      // It's important to pass the offline client to your Supabase#Client instantiation.
      // If you're using supabase_flutter, make sure you initialize with the clientQueue's client
      // before passing it here. For example:
      // ```dart
      // await Supabase.initialize(httpClient: client)
      // SupabaseProvider(Supabase.instance.client, modelDictionary: ...)
      // ```
      SupabaseClient(supabaseUrl, apiKey, httpClient: client),
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
````

## Models

### ConnectOfflineFirstWithSupabase

`@ConnectOfflineFirstWithSupabase` decorates the model that can be serialized by one or more providers. Offline First does not have configuration at the class level and only extends configuration held by its providers:

```dart
@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(),
  sqliteConfig: SqliteSerializable(),
)
class MyModel extends OfflineFirstModel {}
```

### FAQ

#### Why can't I declare a model argument?

Due to [an open analyzer bug](https://github.com/dart-lang/sdk/issues/38309), a custom model cannot be passed to the repository as a type argument.

## Unsupported Field Types

- Any unsupported field types from `SupabaseProvider`, or `SqliteProvider`
- Future iterables of future models (i.e. `Future<List<Future<Model>>>`).
