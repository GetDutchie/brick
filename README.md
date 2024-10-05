![An intuitive way to work with persistent data](./docs/logo.svg)

An intuitive way to work with persistent data in Dart.

## [Full documentation](https://getdutchie.github.io/brick/)

- [GraphQL](https://getdutchie.github.io/brick/#/offline_first/offline_first_with_graphql_repository)
- [REST](https://getdutchie.github.io/brick/#/offline_first/offline_first_with_rest_repository)
- [Supabase](https://getdutchie.github.io/brick/#/offline_first/offline_first_with_supabase_repository?id=repository-configuration)

## Why Brick?

- Out-of-the-box [offline access](packages/brick_offline_first) to data
- [Handle and hide](packages/brick_build) complex serialization/deserialization logic
- Single [access point](https://getdutchie.github.io/brick/#/data/repositories) and opinionated DSL
- Automatic, [intelligently-generated migrations](https://getdutchie.github.io/brick/#/sqlite)
- Legible [querying interface](https://getdutchie.github.io/brick/#/data/query)

## What is Brick?

Brick is an extensible query interface for Dart applications. It's an [all-in-one solution](https://www.youtube.com/watch?v=2noLcro9iIw) responsible for representing business data in the application, regardless of where your data comes from. Using Brick, developers can focus on implementing the application, without [concern for where the data lives](https://www.youtube.com/watch?v=jm5i7e_BQq0). Brick was inspired by the need for applications to work offline first, even if an API represents your source of truth.

## Quick Start

1. Add the packages:
   ```yaml
   dependencies:
     # Or brick_offline_first_with_graphql
     # Or brick_offline_first_with_supabase
     brick_offline_first_with_rest:
     sqflite: # optional
   dev_dependencies:
     # Or brick_offline_first_with_graphql_build: any
     # Or brick_offline_first_with_supabase_build: any
     brick_offline_first_with_rest_build:
     build_runner:
   ```
1. Configure your app directory structure to match Brick's expectations:
   ```bash
   mkdir -p lib/brick/adapters lib/brick/db;
   ```
1. Add [models](docs/data/models.md) that contain your app logic. Models **must be** saved with the `.model.dart` suffix (i.e. `lib/brick/models/person.model.dart`).
1. Run `dart run build_runner build` to generate your models and [sometimes migrations](docs/sqlite.md#intelligent-migrations). Rerun after every new model change or `dart run build_runner watch` for automatic generations. You'll need to run this again after your first migration.
1. Extend [an existing repository](docs/data/repositories.md) or create your own (Supabase has [some exceptions](https://getdutchie.github.io/brick/#/offline_first/offline_first_with_supabase_repository)):

   ```dart
   // lib/brick/repository.dart
   import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
   import 'package:brick_rest/brick_rest.dart';
   import 'package:brick_sqlite/brick_sqlite.dart';
   import 'package:my_app/brick/brick.g.dart';
   import 'package:sqflite/sqflite.dart' show databaseFactory;
   import 'package:my_app/brick/db/schema.g.dart';
   export 'package:brick_core/query.dart' show And, Or, Query, QueryAction, Where, WherePhrase;

   class Repository extends OfflineFirstWithRestRepository {
     Repository()
         : super(
             migrations: migrations,
             restProvider: RestProvider(
               'http://0.0.0.0:3000',
               modelDictionary: restModelDictionary,
             ),
             sqliteProvider: SqliteProvider(
               _DB_NAME,
               databaseFactory: databaseFactory,
               modelDictionary: sqliteModelDictionary,
             ),
             offlineQueueManager: RestRequestSqliteCacheManager(
               'brick_offline_queue.sqlite',
               databaseFactory: databaseFactory,
             ),
           );
   }
   ```

1. Profit.

## Usage

Create a model as the app's business logic:

```dart
// brick/models/user.dart
@ConnectOfflineFirstWithRest()
class User extends OfflineFirstWithRestModel {}
```

And generate (de)serializing code to fetch to and from multiple providers:

```bash
$ (flutter) pub run build_runner build
```

### Fetching Data

A repository fetches and returns data across multiple providers. It's the single access point for data in your app:

```dart
class MyRepository extends OfflineFirstWithRestRepository {
  MyRepository();
}

final repository = MyRepository();

// Now the models can be queried:
final users = await repository.get<User>();
```

Behind the scenes, this repository could poll a memory cache, then SQLite, then a REST API. The repository intelligently determines how and when to use each of the providers to return the fastest, most reliable data.

```dart
// Queries can be general:
final query = Query(where: [Where('lastName').contains('Muster')]);
final users = await repository.get<User>(query: query);

// Or singular:
final query = Query.where('email', 'user@example.com', limit1: true);
final user = await repository.get<User>(query: query);
```

Queries can also receive **reactive updates**. The subscribed stream receives all models from its query whenever the local copy is updated (e.g. when the data is hydrated in another part of the app):

```dart
final users = repository.subscribe<User>().listen((users) {})
```

### Mutating Data

Once a model has been created, it's sent to the repository and back out to _each_ provider:

```dart
final user = User();
await repository.upsert<User>(user);
```

### Associating Data

Repositories can support associations and automatic (de)serialization of child models.

```dart
class Hat extends OfflineFirstWithRestModel {
  final String color;
  Hat({this.color});
}
class User extends OfflineFirstWithRestModel {
  // user has many hats
  final List<Hat> hats;
}

final query = Query.where('hats', Where('color').isExactly('brown'));
final usersWithBrownHats = repository.get<User>(query: query);
```

Brick natively [serializes primitives, associations, and more](packages/brick_offline_first/example/lib/brick/models/kitchen_sink.model.dart).

If it's still murky, [check out Learn](https://getdutchie.github.io/brick/#/README?id=learn) for videos, tutorials, and examples that break down Brick.
