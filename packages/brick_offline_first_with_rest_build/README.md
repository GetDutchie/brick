![brick_offline_first_with_rest_build workflow](https://github.com/GetDutchie/brick/actions/workflows/brick_offline_first_with_rest_build.yaml/badge.svg)

# Brick Offline First with Rest Build

Code generator that provides (de)serializing functions for Brick adapters using RestProvider and SqliteProvider within the OfflineFirstWithRest domain. Classes annotated with `ConnectOfflineFirstWithRest` **and** extending the model `OfflineFirstWithRest` will be discovered.

## Setup

`dart:mirrors` will conflict with Flutter, so this package should be imported as a dev dependency and executed before an app's run time.

```yaml
dev_dependencies:
  brick_offline_first_with_rest_build:
    git:
      url: git@github.com:GetDutchie/brick.get
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
      class MyClassRequestTransformer extends RestRequestTransformer {
        final get = RestRequest(url: "=> '/my/endpoint/to/models';");
        const MyClassRequestTransformer(Query? query, RestModel? instance) : super(query, instance);
      }

      @ConnectOfflineFirstWithRest(
        sqliteConfig: SqliteSerializable(
          nullable: false
        ),
        restConfig: RestSerializable(
          requestTransformer:
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

## FAQ

### Why doesn't this library use [JsonSerializable](https://pub.dartlang.org/packages/json_serializable)?

While `JsonSerializable` is an incredibly robust library, it is, in short, opinionated. Just like this library is opinionated. This prevents incorporation in a number of ways:

* `@JsonSerializable` detects serializable models [via a class method check](https://github.com/dart-lang/json_serializable/blob/6a39a76ff8967de50db0f4b344181328269cf978/json_serializable/lib/src/type_helpers/json_helper.dart#L131-L133). Since `@ConnectOfflineFirstWithRest` uses an abstracted builder, checking the source class is not effective.
* `@JsonSerializable` only supports enums as strings, not as indexes. While this is admittedly more resilient, it can’t be retrofitted to enums passed as integers from an API.
* Lastly, dynamically applying a configuration is an uphill battle with `ConstantReader` (the annotation would have to be converted into a [digestable format](https://github.com/dart-lang/json_serializable/blob/5cbe2f9b3009cd78c7a55277f5278ea09952340d/json_serializable/lib/src/json_serializable_generator.dart#L103)). While ultimately this could be possible, the library is still unusable because of the aforementioned points.

`JsonSerializable` is an incredibly robust library and should be used for all other scenarios.
