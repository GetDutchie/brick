# Offline First With Supabase Repository

`OfflineFirstWithSupabaseRepository` streamlines the Supabase integration with an `OfflineFirstRepository`. A [serial queue](offline_queue.md) is included to track Supabase mutations in a separate SQLite database, only removing requests when a response is returned from the host (i.e. the device has lost internet connectivity).

The `OfflineFirstWithSupabase` domain uses all the same configurations and annotations as `OfflineFirst`.

![OfflineFirst#get](https://user-images.githubusercontent.com/865897/72176226-cdd8ca00-3392-11ea-867d-42f5f4620153.jpg)

?> You can change default behavior on a per-request basis using `policy:` (e.g. `get<Person>(policy: OfflineFirstUpsertPolicy.localOnly)`). This is available for `delete`, `get`, `getBatched`, `subscribe`, and `upsert`.

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
await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey, httpClient: client)
final supabaseProvider = SupabaseProvider(Supabase.instance.client, modelDictionary: ...)
```

### Offline Queue Caveats

For Flutter users, `Supabase.instance.client` inherits this [offline client](https://github.com/supabase/supabase-flutter/blob/main/packages/supabase/lib/src/supabase_client.dart#L141-L142). Brick works around Supabase's default endpoints: the offline queue **will not** cache and retry requests to Supabase's Auth or Storage.

To ensure the queue handles all requests, pass an empty set:

```dart
final (client, queue) = OfflineFirstWithSupabaseRepository.clientQueue(
  databaseFactory: databaseFactory,
  ignorePaths: {},
);
```

For implementations that [do not wish to retry functions](https://github.com/GetDutchie/brick/issues/440) and need to handle a response, add `'/functions/v1'` to this Set:

```dart
final (client, queue) = OfflineFirstWithSupabaseRepository.clientQueue(
  databaseFactory: databaseFactory,
  ignorePaths: {
    '/auth/v1',
    '/storage/v1',
    '/functions/v1'
  },
);
```

!> This is an admittedly brittle solution for ignoring core Supabase paths. If you change the default values for `ignorePaths`, you are responsible for maintaining the right paths when Supabase changes or upgrades their endpoint paths.

## Realtime

Brick can automatically update with [Supabase realtime events](https://supabase.com/docs/guides/realtime). After setting up [your table](https://supabase.com/docs/guides/realtime?queryGroups=language&language=dart#realtime-api) to broadcast, listen for changes in your application:

```dart
// Listen to all changes
final customers = MyRepository().subscribeToRealtime<Customer>();
// Or listen to results of a specific filter
final customers = MyRepository().subscribeToRealtime<Customer>(query: Query.where('id', 1));

// Use the stream results
final customersSubscription = customers.listen((value) {});

// Always close your streams
await customersSubscription.cancel();
```

Complex queries more than one level deep (e.g. with associations) or with comparison operators that are not [supported by Supabase's `PostgresChangeFilterType`](https://github.com/supabase/supabase-flutter/blob/main/packages/realtime_client/lib/src/types.dart#L239-L260) will be ignored - when such invalid queries are used, the realtime connection will be unfiltered even though Brick will respect the query in the stream's results.

!> Realtime can become [expensive quickly](https://supabase.com/pricing). Be sure to design your application for appropriate scale. For cheaper, on-device reactivity, use `.subscribe()` instead.

### @ConnectOfflineFirstWithSupabase

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
// Alternatively, you can invoke nested maps (e.g. {'id': "data['pizza']['id']"})
@Supabase(name: 'otherId')
final Pizza pizza;
```

## Associations and Foreign Keys

Field types of classes that `extends OfflineFirstWithSupabaseModel` will automatically be assumed as a foreign key in Supabase. You will only need to specify the column name if it differs from your field name to help Brick fetch the right data and serialize/deserialize it locally.

```dart
class User extends OfflineFirstWithSupabaseModel {
  // The foreign key is a relation to the `id` column of the Address table
  @Supabase(foreignKey: 'address_id')
  final Address address;

  // If the association will be created by the app, specify
  // a field that maps directly to the foreign key column
  // so that Brick can notify Supabase of the association.
  @Sqlite(ignore: true)
  String get addressId => address.id;
}

class Address extends OfflineFirstWithSupabaseModel{
  final String id;
}
```

!> If your association is nullable (e.g. `Address?`), the Supabase response may include all `User`s from the database from a loosely-specified query. This is caused by PostgREST's [filtering](https://docs.postgrest.org/en/v12/references/api/resource_embedding.html#top-level-filtering). Brick does not use `!inner` to query tables because there is no guarantee that a model does not have multiple fields relating to the same association; it instead explicitly declares the foreign key with [not.is.null](https://docs.postgrest.org/en/v12/references/api/resource_embedding.html#null-filtering-on-embedded-resources) filtering. If a Dart association is nullable, Brick will not append the `not.is.null` which could return [all results](https://github.com/GetDutchie/brick/issues/429#issuecomment-2325941205). If you have a use case that requires a nullable association and you cannot circumvent this problem with [Supabase's policies](https://supabase.com/docs/guides/database/postgres/row-level-security), please open an issue and provide extensive detail.

### Recursive/Looped Associations

If a request includes a nested parent-child recursion, the generated Supabase query will remove the association to prevent a stack overflow.

For example, given the following models:

```dart
class Parent extends OfflineFirstWithSupabaseModel {
  final String parentId;
  final List<Child> children;
}
class Child extends OfflineFirstWithSupabaseModel {
  final String childId;
  final Parent parent;
}
```

A query for `MyRepository().get<Parent>()` would generate a Supabase query that only gets the shallow properties of Parent on the second level of recursion:

```
parent:parent_table(
  parentId,
  children:child_table(
    childId,
    parent:parent_table(
      parentId
    )
  )
)
```

Implementations using looping associations like this should design for their parent (first-level) models to accept `null` or empty child associations:

```dart
class Parent extends OfflineFirstWithSupabaseModel {
  final String parentId;
  final List<Child> children;

  Parent({
    required this.parentId,
    List<Child>? children,
  }) : children = children ?? List<Child>[];
}
```
