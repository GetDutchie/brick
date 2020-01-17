# Brick Build

Code generator for [Brick](https://github.com/greenbits/brick) adapters, model dictionaries.

## Install

```yaml
# pubspec.yaml
dev_dependencies:
  build_runner: any
  brick_build: any
```

All annotated models **must** be in `lib/app/models`.

## Setup

It's recommended to use `watch` when editing models.

```shell
(flutter) pub run build_runner watch
```

If you're not using `watch`, be sure to run `build` twice for the schema to detect new migrations.

```shell
(flutter) pub run build_runner build
```

An application directory **must** resemble the following:
```
| my-app
|--lib
|--|--app
|--|--|--adapters
|--|--|--db
|--|--|--models
```

This ensures a consistent path to access child data, such as models, [by build generators](#why-are-all-models-hacked-into-a-single-file).

## Glossary

* **generator** - code producer. The output of a generator is most often a function that converts input to normalized data. The output of a generator does not always constitute a complete file (e.g. one generator is a serializer, another generator is a deserializer, and both generators are combined in a super adapter generator).
* **builder** - a class that interfaces between source files and generator(s) before writing generated code to file(s). They are invoked and configured by build.yaml. Builders are primarly concerned with annotations that exist in the source (e.g. a Flutter app).
* **serdes** - shorthand for serialize/deserialize
* **checker** - an accessible utility that type checks analyzed type from a source. For example, `isBool` for a source of `final bool isDeleted` would return `true`. With a source of `final String isDeleted`, `isBool` would return `false`.
* **domain** - the encompassing system. For example, the `OfflineFirst` domain builds REST serdes and SQLite serdes as well as its own annotation.

## Creating a Domain Builder

A new provider will likely require expected data to be massaged before creating a model.

### Configurations and Annotations

Before reading further, this process appears to require a lot of code. This is largely boilerplate required for type checking and Dart's analyzer. The majority of the custom code and logic will live in the adapter serdes.

:warning: Annotation and configuration definitions must be declared outside of the build package if they depend on a package that conflicts with mirrors (Flutter conflicts with mirrors). As other packages may use these annotations (for example, `OfflineFirst` considers `@Rest` and `@Sqlite` annotations along with `@OfflineFirst`), it's safest to keep annotations and builders as independent packages.

#### Declaring Class-level Configuration

A provider will likely require high-level information about a class that would be inappropriate to define on every instance of a class. And, because Dart's Type system can't infer static methods, this must be declared outside the class in an annotation:

```dart
// in this example, @ConnectOfflineFirstWithRest is our super or class-level annotation
@ConnectOfflineFirstWithRest(
  // RestSerializable is our configuration body.
  restConfig: RestSerializable(
    // a REST endpoint is inappropriate to define as an instance-level definition
    endpoint: '=> "/users";',
    // super annotations are also useful for setting a default for subsequent field-level definitions in the class
    fieldRename: FieldRename.snake,
  )
)
class MyModel
```

These configurations may be injected directly into the adapater (like `endpoint`) or may change behavior for generated code (like `fieldRename`).

When creating a model that the provider relies on, only declare members if they're used by the provider. Using these members should be discouraged in the application.

```dart
abstract class SqliteModel {
  // the provider relies on the primary key to make associations with other models
  int primaryKey;
}
```

#### Declaring Field-level Configuration

Field-level annotations may be useful to override behavior at a finer level.

```dart
class MyModel
  @Rest(
    // a property here may override previously-specified behavior at the class-level
    name: "deleted"
  )
  final bool isDeleted;
```

#### Advanced Type Checking

Most generators may not require an extension of basic type checking (e.g. is this a string, is this an int, is this a list). For advanced checking, say, for the discovery of a package-specific class, a new checker will have to be created:

```dart
final _serdesClassChecker = TypeChecker.fromRuntime(OfflineFirstSerdes);

class OfflineFirstChecker extends SharedChecker {
  bool get isSerdes => _serdesClassChecker.isSuperTypeOf(targetType);
}
```

For every new or removed type check, always update `SharedChecker`'s computed getter `isSerializable`.

### Interpreting Class-level Annotations

Class-level annotations must be expanded from their constantized versions back to an easily-digestible Dart form:

```dart
// RestSerializable is our previously-noted configuration class
class RestSerdes extends ProviderSerializable<RestSerializable> {
  RestSerdes(Element element, ConstantReader reader)
      : super(element, reader, configKey: "restConfig");

  get config {
    if (reader.read(configKey).isNull) return RestSerializable.defaults;

    return RestSerializable(
      // withinConfigKey safely navigates the constantized values, interpreting as digestible Dart code
      endpoint: withinConfigKey("endpoint")?.stringValue ?? RestSerializable.defaults.endpoint,
    );
  }
}
```

#### Discovering and Interpreting Field-level Annotations

Field-level annotations must be expanded from their constantized versions back to an easily-digestible form. Brick provides a base class for this:

```dart
// @Rest is our annotation AND field-level configuration class, declared via AnnotationFinder<Rest>
class RestAnnotationFinder extends AnnotationFinder<Rest> {
  // this is the previously-defined class-level config
  final RestSerializable config;

  RestAnnotationFinder([this.config]);

  // element is the field, e.g. `final bool isDeleted`
  from(element) {
    // objectForField converts the analyzer's raw data into manageable code
    final obj = objectForField(element);

    // if this field is
    // final bool isDeleted
    // and not
    // @Rest(ignore:)
    // final bool isDeleted
    // then we generate the config with defaults
    if (obj == null) {
      return Rest(
        ignore: Rest.defaults.ignore
      );
    }

    // finally, we reconvert the annotation's configuration to digestible Dart code
    return Rest(
      ignore: obj.getField('ignore').toBoolValue() ?? Rest.defaults.ignore,
    );
  }
}
```

This reinitializes at the field level. However, a class will require that all fields go through the same process, and so a `FieldsForClass` class must be made.

```dart
// @Rest is still our annotation
// This class is boilerplate and can be safely copied with changes to the type
class RestFields extends FieldsForClass<Rest> {
  final RestAnnotationFinder finder;
  final RestSerializable config;

  RestFields(ClassElement element, [RestSerializable this.config])
      : finder = RestAnnotationFinder(config),
        super(element: element);
}
```

For providers that do not make use of a class-level config, the `Fields` interpreter can be adjusted:

```dart
class RestFields extends FieldsForClass<Rest> {
  final finder = RestAnnotationFinder();

  RestFields(ClassElement element) : super(element: element);
}
```

#### Discovering Class-level Annotations

An AnnotationSuperGenerator manages sub generators. This generator is most likely the entrypoint for other builders. It should be simple, with most of its logic delegated to sub generators.

```dart
// @ConnectOfflineFirstWithRest is the annotation that decorates our models
class OfflineFirstGenerator extends AnnotationSuperGenerator<ConnectOfflineFirstWithRest> {
  final ConnectOfflineFirstWithRest config;

  const OfflineFirstGenerator({
    ConnectOfflineFirstWithRest argConfig,
  }) : config = argConfig ?? ConnectOfflineFirstWithRest.defaults;

  String generateAdapter(Element element, ConstantReader annotation, BuildStep buildStep) {
    final rest = RestSerdes(element, annotation);
    // generated code is returned (and discussed next)
  }
}
```

### Adapter

Adapter serdes generators should be as atomic as possible and not expect code from other adapter generators.

An adapter always includes serialization and deserialization methods. It can also include useful information such as schema data for a SQLite provider or a function to generate an endpoint for a REST provider. The provider can and should access generic (i.e. not related to a specific model instance) model information via the adapter.

Domains should subclass the `SerdesGenerator` to configure default generated code:

```dart
// FieldSerializable is a protocol for field-level annotations defined in brick_core
abstract class OfflineFirstSerdesGenerator extends SerdesGenerator<T extends FieldSerializable> {
  final repositoryName = "OfflineFirst";
}
```

Serializing and deserializing functions should live in separate classes for legibility:

```dart
// @Rest is our field-level annotation
class RestSerialize extends OfflineFirstGenerator<Rest> {
  final doesDeserialize = false;
}
class RestDeserialize extends OfflineFirstGenerator<Rest> {
  final doesDeserialize = true;
}
```

Every field of a model will be interpreted by the SerdesGenerator via `addField`:

```dart
class RestSerialize extends OfflineFirstGenerator<Rest> {
  // All discovered fields of the class pass through this function for generator output
  // Private fields, methods, static members, and computed setters are automatically ignored
  String addField(field, annotation) {
    // interpret the field's type:
    final checker = SharedChecker(field.type);

    if (checker.isString) {
      // annotation is our already-expanded field-level config
      final propertyName = annotation.name;
      // field comes from the analyzer and has a lot of useful information
      return "'$propertyName' : instance.${field.name}";
    }

    // falling through to an unsupported type, null won't add to the generated output
    return null;
  }
}
```

At a minimum, all primitive types should be evaluated by the checker and returned to the generator with appropriate serializing or deserializing code. Serdes generators come out as code spaghetti and _that's OK_. Explicit, verbose declarations - even when duplicated across generators - are reliable and easy to debug.

Adapter members, like models, should only be declared if they are used by the provider.

```dart
abstract class SqliteAdapter extends Adapter<SqliteModel> {
  // the analyzer won't be available at run time, so the provider needs to be aware
  // of relevant information to build a SQLite query
  final fieldsToColumns = {
    'firstName': {
      'type': String,
      'association': false,
      'columnName': 'first_name',
    },
  };
}
```

#### Associations

Associations can require complex fetching. When a domain supports associations between providers, the class-level annotation should be used in a custom checker. For example, `isSibling` or `isAssociation`.

It is recommended to use a repository method dedicated to association fetching instead of the provider, as the repository may route the lookup to a different provider. For example, a User may have 1 Hat, and the repository may already have that Hat in a memory provider. By requesting the repository, the `SqliteProvider` is spared a potentially expensive query.

### Generating Class-level Annotations

The two adapter serdes classes are associated in the original serdes:

```dart
class RestSerdes extends ProviderSerializable<RestSerializable> {
  RestSerdes(Element element, ConstantReader reader)
      : super(element, reader, configKey: "restConfig");

  get generators {
    final classElement = element as ClassElement;
    // RestFields interprets all fields at the class level into our custom config (e.g. `name`, `ignore`)
    //
    // `config` comes from our expanded class-level annotation
    final fields = RestFields(classElement, config);
    return [RestDeserialize(classElement, fields), RestSerialize(classElement, fields)];
  }
}
```

Finally, the adapter code is ready to be sent to a builder.

```dart
class OfflineFirstGenerator extends AnnotationSuperGenerator<ConnectOfflineFirstWithRest> {
  final ConnectOfflineFirstWithRest config;

  const OfflineFirstGenerator({
    ConnectOfflineFirstWithRest argConfig,
  }) : config = argConfig ?? ConnectOfflineFirstWithRest.defaults;

  String generateAdapter(Element element, ConstantReader annotation, BuildStep buildStep) {
    final rest = RestSerdes(element, annotation);

    final adapterGenerator = AdapterGenerator(
      superAdapterName: 'OfflineFirst',
      className: element.name,
      // other provider serializing functions can be passed to the adapter generator,
      // allowing an adapter to interpret between providers
      generators: [rest.generators],
    );

    return adapterGenerator.generate();
  }
}
```

### Model Dictionary

The Model Dictionary generator must generate model dictionaries for **each** provider. Defining instructions - such as not committing generated code - and guiding code comments - such as the contents of a `mapping` - are important but not required.

As each model should extend/implement each provider's model type, and each adapter should extend/implement each provider's adapter type, the same dictionary is used for each provider mapping:

```dart
// this method is inherited from the super class
final dictionary = dictionaryFromFiles(classNamesToFileNames);

return """
/// REST mappings should only be used when initializing a [RestProvider]
final Map<Type, RestAdapter<RestModel>> restMappings = {
  $dictionary
};
final restModelDictionary = RestModelDictionary(restMappings);

/// Sqlite mappings should only be used when initializing a [SqliteProvider]
final Map<Type, SqliteAdapter<SqliteModel>> sqliteMappings = {
  $dictionary
};
final sqliteModelDictionary = SqliteModelDictionary(sqliteMappings);
""";
```

To support the maps, every adapter must be included as a `part` and every model must be included as an import:

```dart
// These methods are inherited from the super class
final adapters = adaptersFromFiles(classNamesToFileNames);
final models = modelsFromFiles(classNamesToFileNames);

return """
$models

$adapters
""";
```

Any imports used within adapters must also be imported:

```dart
return """
import 'dart:convert';
import 'package:brick_sqlite/sqlite.dart' show SqliteModel, SqliteAdapter, SqliteModelDictionary;
import 'package:brick_rest/rest.dart' show RestProvider, RestModel, RestAdapter, RestModelDictionary;
// ignore: unused_import, unused_shown_name
import 'package:brick_core/core.dart' show Query, QueryAction;
// ignore: unused_import, unused_shown_name
import 'package:sqflite/sqflite.dart' show DatabaseExecutor;
""";
```

:bulb: To reduce analyzer errors, include `// ignore: unused_import` for imports used in part files.

### Builder

Generators are invoked by builders and builders are invoked by `build.yaml` using Dart's native task runner. As `build.yaml` can be opaque to the uninitiated and is not part of this repo, documentation about customization can be found on [the package page](https://pub.dartlang.org/packages/build_config). For basic, battle-tested usage, [the build.yaml in this repo](build.yaml) can be used as a base and modified appropriately for custom domains.

The primary build functions will be adapters and the model dictionary, as these are critical to the Brick system:

```dart
// RestGenerator is our AnnotationSuperGenerator
final restGenerator = RestGenerator();
Builder restAdaptersBuilder(options) => AdapterBuilder(restGenerator);
Builder restModelDictionaryBuilder(options) => ModelDictionaryBuilder(
  restGenerator,
  RestModelDictionaryGenerator(),
  // these files were only imported for our source code to interpret annotations
  // they're not required by adapters now that code has been generated
  expectedImportRemovals: [
    "import 'package:brick_rest/rest.dart';",
    'import "package:brick_rest/rest.dart";',
  ],
);
```

## How does this work?

### End-to-end Case Study: `@ConnectOfflineFirstWithRest`

![OfflineFirst Builder](https://user-images.githubusercontent.com/865897/72175884-1c399900-3392-11ea-8baa-7d50f8db6773.jpg)

1. A class is discovered with the `@ConnectOfflineFirstWithRest` annotation.
      ```dart
      @ConnectOfflineFirstWithRest(
        sqliteConfig: SqliteSerializable(
          nullable: false
        ),
        restConfig: RestSerializable(
          endpoint: """=> '/my/path/to/classes'"""
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

### Why are all models hacked into a single file?

Dart's build discovers one file at a time. Because Brick makes use of associations, it must be aware of all files, including similarly-annotated models that may not be in the same file. Therefore, one build step handles combining all files via a known directory (this is why folder organization is so important) and then combines them into a file. By writing that file, another build step listening for the extension kicks off _the next_ build step to interpret each annotation.

### Why doesn't this library use [JsonSerializable](https://pub.dartlang.org/packages/json_serializable)?

While `JsonSerializable` is an incredibly robust library, it is, in short, opinionated. Just like this library is opinionated. This prevents incorporation in a number of ways:

* `@JsonSerializable` detects serializable models [via a class method check](https://github.com/dart-lang/json_serializable/blob/6a39a76ff8967de50db0f4b344181328269cf978/json_serializable/lib/src/type_helpers/json_helper.dart#L131-L133). Since `@ConnectOfflineFirstWithRest` uses an abstracted builder, checking the source class is not effective.
* `@JsonSerializable` only supports enums as strings, not as indexes. While this is admittedly more resilient, it can’t be retrofitted to enums passed as integers from an API.
* Lastly, dynamically applying a configuration is an uphill battle with `ConstantReader` (the annotation would have to be converted into a [digestable format](https://github.com/dart-lang/json_serializable/blob/5cbe2f9b3009cd78c7a55277f5278ea09952340d/json_serializable/lib/src/json_serializable_generator.dart#L103)). While ultimately this could be possible, the library is still unusable because of the aforementioned points.

`JsonSerializable` is an incredibly robust library and should be used for all other scenarios.
