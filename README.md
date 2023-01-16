![An intuitive way to work with persistent data](./docs/logo.svg)

An intuitive way to work with persistent data in Dart.

## [Full documentation](https://getdutchie.github.io/brick/)

## Why Brick?

* Out-of-the-box [offline access](packages/brick_offline_first) to data
* [Handle and hide](packages/brick_build) complex serialization/deserialization logic
* Single [access point](docs/data/repositories) and opinionated DSL
* Automatic, [intelligently-generated migrations](docs/sqlite.md#intelligent-migrations)
* Legible [querying interface](docs/data/query)

## What is Brick?

Brick is an extensible query interface for Dart applications. It's an [all-in-one solution](https://www.youtube.com/watch?v=2noLcro9iIw) responsible for representing business data in the application, regardless of where your data comes from. Using Brick, developers can focus on implementing the application, without [concern for where the data lives](https://www.youtube.com/watch?v=jm5i7e_BQq0). Brick was inspired by the need for applications to work offline first, even if an API represents your source of truth.

## Quick Start

1. Add the packages:
    ```yaml
    dependencies:
      # Or brick_offline_first_with_graphql
      brick_offline_first_with_rest: any
    dev_dependencies:
      # Or brick_offline_first_with_graphql_build: any
      brick_offline_first_with_rest_build: any
      build_runner: any
    ```
1. Configure your app directory structure to match Brick's expectations:
    ```bash
    mkdir -p lib/brick/adapters lib/brick/db;
    ```
1. Add [models](docs/data/models) that contain your app logic. Models **must be** saved with the `.model.dart` suffix (i.e. `lib/brick/models/person.model.dart`).
1. Run `flutter pub run build_runner build` to generate your models (or `pub run build_runner build` if you're not using Flutter) and [sometimes migrations](docs/sqlite.md#intelligent-migrations). Rerun after every new model change or `flutter pub run build_runner watch` for automatic generations.
1. Extend [an existing repository](docs/data/repositories) or create your own:
    ```dart
    // lib/brick/repository.dart
    import 'package:brick_offline_first/offline_first_with_rest.dart';
    import 'package:my_app/brick/brick.g.dart';
    import 'package:sqflite/sqflite' show databaseFactory;
    export 'package:brick_offline_first/offline_first_with_rest.dart' show And, Or, Query, QueryAction, Where, WherePhrase;

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
