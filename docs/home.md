# Quick Start

1. Add the packages:
   ```yaml
   dependencies:
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
1. Add [models](docs/data/models) that contain your app logic. Models **must be** saved with the `.model.dart` suffix (i.e. `lib/brick/models/person.model.dart`).
1. Run `dart run build_runner build` to generate your models and [sometimes migrations](docs/sqlite.md#intelligent-migrations). Rerun after every new model change or `dart run build_runner watch` for automatic generations. You'll need to run this again after your first migration.
1. Extend [an existing repository](docs/data/repositories) or create your own:

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

## Integrations

- [With Rest](offline_first/offline_first_with_rest_repository.md)
- [With GraphQL](offline_first/offline_first_with_graphql_repository.md)
- [With Supabase](offline_first/offline_first_with_supabase_repository.md)

## Learn

- Video: [Brick Architecture](https://www.youtube.com/watch?v=2noLcro9iIw). An explanation of Brick parlance with a [supplemental analogy](https://medium.com/flutter-community/brick-your-app-five-compelling-reasons-and-a-pizza-analogy-to-make-your-data-accessible-8d802e1e526e).
- Video: [Brick Basics](https://www.youtube.com/watch?v=jm5i7e_BQq0). An overview of essential Brick mechanics.
- Example: [Simple Associations using the OfflineFirstWithGraphql domain](https://github.com/GetDutchie/brick/blob/main/example_graphql)
- Example: [Simple Associations using the OfflineFirstWithRest domain](https://github.com/GetDutchie/brick/blob/main/example_rest)
- Example: [Simple Associations using the OfflineFirstWithSupabase domain](https://github.com/GetDutchie/brick/blob/main/example_supabase)
- Tutorial: [Setting up a simple app with Brick](http://www.flutterbyexample.com/#/posts/2_adding_a_repository)
- Blog: [Building offline-first mobile apps with Supabase, Flutter and Brick](https://supabase.com/blog/offline-first-flutter-apps)

## Glossary

- **source** - external information warehouse that delivers unrefined data
- [**Provider**](data/providers.md) - fetches from and pushes to a `source`
- [**Repository**](data/repositories.md) - manages `Provider`(s) and determines which provider results to send
- **Adapter** - normalizes data input and output between `Provider`s
- [**Model**](data/models.md) - business logic unique to the app. Fetched by the `Repository`, and if merited by the `Repository` implementation, the `Provider`.
- **ModelDictionary** - guides a `Provider` to the `Model`'s `Adapter`. Unique per `Provider`.
- **field** - single, accessible property of a model. For example, `final String id`
- **deserialize** - convert raw data _from_ a provider
- **serialize** - convert a model instance _to_ raw data for a provider

## FAQ

### Do I have to get rid of BLoC or Scoped Model or Redux in my app to use Brick?

Nope. Those are _state_ managers. As a _store_ manager, Brick tracks and delivers persistent data across many sources, but it does not care about how you render that data. In fact, in its first app, Brick was integrated with BLoCs - the BLoC requested the data, Brick discovered the data, delivered the data back to the BLoC, and the BLoC delivered the data to the UI component for rendering.

As Repositories can output streams in `#getBatched`, a state manager could be easily bypassed. However, after trial and error, the Brick team determined the maintainence benefits of separating presentation and logic outweighed forgoing a state manager.

### What's in the name?

Brick isn't a state management library, it's a data _store_ management library. While Brick doesn't persist data itself, it routes data between different source. "Brick" plays on the adage "brick and mortar store."
