[![Build Status](https://travis-ci.org/greenbits/brick.svg?branch=master)](https://travis-ci.org/greenbits/brick)

![An intuitive way to work with persistent data](./docs/logo.svg)

An intuitive way to work with persistent data in Dart.

## [Full documentation](https://greenbits.github.io/brick/)

## Why Brick?

* Out-of-the-box [offline access](packages/brick_offline_first) to data
* [Handle and hide](packages/brick_build) complex serialization/deserialization logic
* Single [access point](https://greenbits.github.io/brick/#/data/repositories) and opinionated DSL
* Automatic, [intelligently-generated migrations](packages/brick_sqlite)
* Legible [querying interface](https://greenbits.github.io/brick/#/data/query)

## What is Brick?

Brick is an extensible query interface for Dart applications. It's an [all-in-one solution](https://www.youtube.com/watch?v=2noLcro9iIw) responsible for representing business data in the application, regardless of where your data comes from. Using Brick, developers can focus on implementing the application, without [concern for where the data lives](https://www.youtube.com/watch?v=jm5i7e_BQq0). Brick was inspired by the need for applications to work offline first, even if an API represents your source of truth.

## Quick Start

1. Add the packages:
    ```yaml
    dependencies:
      brick_offline_first: any
    dev_dependencies:
      brick_offline_first_with_rest_build:
        git:
          url: https://github.com/greenbits/brick.git
          path: packages/brick_offline_first_with_rest_build
      build_runner: any
    ```
1. Configure your app directory structure to match Brick's expectations:
    ```bash
    mkdir -p lib/app/adapters lib/app/db lib/app/models;
    ```
1. Add [models](https://greenbits.github.io/brick/#/data/models) that contain your app logic. Models **must be** saved in `lib/app/models/<class_as_snake_name>.dart`.
1. Run `flutter pub run build_runner run` to generate your models (or `pub run build_runner run` if you're not using Flutter) and [sometimes migrations](https://greenbits.github.io/brick/#/sqlite?id=intelligent-migrations). Rerun after every new model change or `flutter pub run build_runner watch` for automatic generations.
1. Extend [an existing repository](https://greenbits.github.io/brick/#/data/repositories) or create your own:
    ```dart
    // lib/app/repository.dart
    import 'package:brick_offline_first/offline_first_with_rest.dart';
    import 'package:my_app/app/brick.g.dart';
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
                modelDictionary: sqliteModelDictionary,
              ),
            );
    }
    ```
1. Profit.
