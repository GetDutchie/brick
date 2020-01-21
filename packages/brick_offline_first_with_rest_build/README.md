# Brick Offline First with Rest Build

Code generator that provides (de)serializing functions for Brick adapters using RestProvider and SqliteProvider within the OfflineFirstWithRest domain. Classes annotated with `ConnectOfflineFirstWithRest` **and** extending the model `OfflineFirstWithRest` will be discovered.

## Setup

`dart:mirrors` will conflict with Flutter, so this package should be imported as a dev dependency and executed before an app's run time.

```yaml
dev_dependencies:
  brick_offline_first_with_rest_build:
    git:
      url: git@github.com:greenbits/brick.get
      path: packages/brick_offline_first_with_rest_build
```

Build your code:

```shell
cd my_app; (flutter) pub run build_runner build
```

## How does this work?

![OfflineFirst Builder](https://user-images.githubusercontent.com/865897/72175884-1c399900-3392-11ea-8baa-7d50f8db6773.jpg)

1. A class is discovered with the `@ConnectOfflineFirstWithRest` annotation.
      ```dart
      @ConnectOfflineFirstWithRest(
        sqliteConfig: SqliteSerializable(
          nullable: false
        ),
        restConfig: RestSerializable(
          endpoint: "=> '/my/endpoint/to/models';"
        )
      )
      class MyClass extends OfflineFirstModel
      ```
1. `OfflineFirstGenerator` expands respective sub configuration from the `@ConnectOfflineFirstWithRest` configuration.
1. Instances of `RestFields` and `SqliteFields` are created and passed to their respective generators. This will expand all fields of the class into consumable code. Namely, the `#sorted` method ensures there are no duplicates and the fields are passed in the order they're declared in the class.
1. `RestSerialize`, `RestDeserialize`, `SqliteSerialize`, and `SqliteDeserialize` generators are created from the previous configurations and the aforementioned fields. Since these generators inherit from the same base class, this documentation will continue with `RestSerialize` as the primary example.
1. The fields are iterated through `RestSerialize#coderForField` to generate the transforming code. This function produces output by checking the field's type. For example, `final List<Future<int>> futureNumbers` may produce `'future_numbers': await Future.wait<int>(futureNumbers)`.
1. The output is gathered via `RestSerialize#generate` and wrapped in a function such as `MODELToRest()`. All such functions from all generators are included in the output of the adapter generator. As some down-stream providers or repositories may require extra information in the adapter (such as `restEndpoint` or `tableName`), this data is also passed through `#generate`.
1. Now with the complete adapter code, the AdapterBuilder saves `adapters/MODELNAME.g.dart`.
1. Now with all annotated classes having adapter counterparts, a model dictionary is generated and saved to `brick.g.dart` with the ModelDictionaryBuilder.
1. Concurrently, the super generator may produce a new schema that reflects the new data structure. `SqliteSchemaGenerator` generates a new schema. Using `SchemaDifference`, a new migration is created (this will be saved to `db/migrations/VERSION_migration.dart`). The new migration is logged and prepended to the generated code. This will be saved to `db/schema.g.dart` with the SqliteSchemaBuilder. A new migration will be saved to `db/<INCREMENT_VERSION>.g.dart` with the NewMigrationBuilder.
