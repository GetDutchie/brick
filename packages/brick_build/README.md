![brick_build workflow](https://github.com/GetDutchie/brick/actions/workflows/brick_build.yaml/badge.svg)

# Brick Build

Code generator utilities for [Brick](https://github.com/GetDutchie/brick) adapters and model dictionaries.

## Setup

It's recommended to use `watch` when editing models.

```shell
(flutter) pub run build_runner watch
```

If you're not using `watch`, be sure to run `build` twice for the schema to detect new migrations on the first run.

```shell
(flutter) pub run build_runner build
```

An application directory **will/must** resemble the following:

```
| my-app
|--lib
|--|--app
|--|--|--adapters
|--|--|--models
```

This ensures a consistent path to access child data, such as models, [by build generators](#why-are-all-models-hacked-into-a-single-file).

# Table of Contents

- [Glossary](#glossary)
- [API Considerations](#api-considerations)
  - [Provider](#provider)
    - [Class-level Configuration](#class-level-configuration)
    - [Field-level Configuration](#field-level-configuration)
  - [Query](#query)
    - [providerArgs:](#providerargs)
    - [where:](#where)
  - [Adapters](#adapters)
  - [Models](#models)
  - [Repository](#repository)
    - [Class-level Configuration](#class-level-configuration-1)
    - [Field-level Configuration](#field-level-configuration-1)
    - [Associations](#associations)
- [Code Generation](#code-generation)
  - [Package Setup](#package-setup)
  - [Provider](#provider-1)
    - [Class-level Configuration](#class-level-configuration-2)
    - [Field-level Annotation](#discovering-and-interpreting-field-level-annotation)
    - [Adapters](#adapters-1)
    - [Invoking the Generators](#invoking-the-generators)
  - [Domain](#domain)
    - [Class-level Annotation](#the-class-level-annotation)
    - [Model Dictionary (brick.g.dart)](#model-dictionary-brickgdart)
    - [Builder](#builder)
- [Testing](#testing)
- [Advanced Techniques](#advanced-techniques)
  - [Custom Type Checking](#custom-type-checking)
- [FAQ](#faq)

# Glossary

- **generator** - code producer. The output of a generator is most often a function that converts input to normalized data. The output of a generator does not always constitute a complete file (e.g. one generator is a serializer, another generator is a deserializer, and both generators are combined in a super adapter generator).
- **builder** - a class that interfaces between source files and generator(s) before writing generated code to file(s). They are invoked and configured by build.yaml. Builders are primarly concerned with annotations that exist in the source (e.g. a Flutter app).
- **serdes** - shorthand for serialize/deserialize
- **checker** - an accessible utility that type checks analyzed type from a source. For example, `isBool` for a source of `final bool isDeleted` would return `true`. With a source of `final String isDeleted`, `isBool` would return `false`.
- **domain** - the encompassing system. For example, the `OfflineFirstWithRest` domain builds REST serdes and SQLite serdes within an adapter and is discovered via its own annotation.

# API Considerations

Brick is an opinionated library, and providing consistent, predictable interaction regardless of provider or domain is a major goal of the project. Implementing the following guidelines is not a requirement, but please strongly consider them when building custom providers and domains.

## Provider

### Class-level Configuration

While models should never be aware of providers, a provider's configuration may be used by a repository or supply necessary information to an adapter. As this is accessed via an annotation, configurations **must be `const`**. Class-level configuration is useful for setting defaults, describing behavior that relies on an instance:

```dart
RestSerializable(
  fieldName: FieldRename.pascal,
  nullable: true,
)
```

Configuration can also describe behavior that relies on an instance. Since functions cannot be passed in a `const` class, a `const`-antized function body can be used:

```dart
RestSerializable(
  requestTransformer: UserRequestTransformer.new
)
```

It is **not recommended** to require the end implemenation to declare arguments for stringified functions. If the provider's arguments for the property changes, the Dart type system will not detect the error ahead of run time.

:warning: If the provider conflicts with usage of `dart:mirrors`, the configuration should be hosted in an independent package. For example, `brick_sqlite` and `brick_sqlite_abstract`.

### Field-level Configuration

A provider may choose to implement configuration at the field-level with annotations. Field-level annotations may be useful to override behavior at a finer level. These annotations should implement `FieldSerializable`:

```dart
@Rest(
  // a property here may override previously-specified behavior at the class-level
  name: "deleted"
)
final bool isDeleted;

@Rest(ignore: true, name: "e-mail")
@Sqlite(unique: true)
final String email;
```

As the field-level annotations are the most often written, they have the most accessible names. Convention for field-level annotation names is simply the provider name minus "Provider."

:bulb: Keep annotations as atomic as possible. A provider annotation is not reliable to another provider.

## Query

Every public instance method should support a named argument of `{Query query}`. `Query` is the glue between an application and an abstracted provider or repository. It is accessed by both the repository and the provider, but as the last mile, the provider should interpret the `Query` at its barest level.

### `limit:`

The ceiling for how many results a provider should return from the source.

```
Query(limit: 10)
```

### `offset:`

The starting index for a provider's search for results.

```
Query(offset: 10)
```

### `forProviders:`

Available arguments can vary from provider to provider; this allows implementations to query exclusive statements from a specific source.

### `where:`

`where` queries with a model's properties. A provider may optionally support `where` arguments. For example, while a SQLite provider will always support column querying, a RESTful API will likely be less consistent and may require massaging the field name:

```dart
[Where('firstName').isExactly('Thomas'), Where('age').isExactly(42)];
// SQLite => SELECT * FROM Users WHERE first_name = "Thomas" AND age = 42;
// REST => https://api.com/users?by_first_name=Thomas&age=42
```

The translation from model field name (e.g. `firstName`) to serializer field name (e.g. `first_name`) may occur in the adapter or in a class-level configuration (e.g. `RestSerializable#endpoint`). However, it should always be accessed by the provider from the adapter.

## Adapters

After the provider receives raw data from its source, it must be built into a model or a list of models. This translation occurs in the adapter. First, the adapter is discovered via the model dictionary, a simple hash table that connects models with adapters

```dart
Future<_Model> get<_Model extends RestModel>({Query query}) async {
  // Connects to _ModelAdapter
  final adapter = modelDictionary.forAdapter[_Model];
  final resp = ... // fetch from HTTP

  // Now the provider can (de)serialize
  return response.map((r) => adapter.fromRest(r));
}
```

The adapter can also facilitate deserialization in the provider with other information about the class:

```dart
class UserAdapter {
  // class-level configurations can be copied to the adapter
  final String fromKey = "users";

  // translate field names (provided by Query#where) to their SQLite column names
  final fieldsToSqliteColumns = {
    "primaryKey": {
      "name": "_brick_id",
      "type": int,
      // some information about the type is no longer available after build
      // because this requires mirrors, however, it can be preserved in the adapter
      "iterable": false,
      "association": false,
    },
  };
}
```

Adapters - made up of both serdes code and custom translation maps such as `fieldsToSqliteColumns` or `restEndpoint` - are generated using brick_build.

:warning: A provider should not rely on adapter code generated by another provider library.

## Models

When creating a model that the provider relies on, only declare members if they're used by the provider. These members should be considered protected within the provider's ecosystem: their use should be discouraged in the end implementation.

```dart
abstract class SqliteModel {
  // the provider relies on the primary key to make associations with other models
  int primaryKey;
}
```

## Repository

Please review best practice methods described in [Creating a Custom Repository](https://github.com/GetDutchie/brick#creating-a-custom-repository) before designing an interface. Build libraries should not generate repositories, however, sometimes a domain adds extra configuration that requires extending provider generators (for example, `OfflineFirstSerdes`).

### Class-level Configuration

A model annotation should be named `Connect<DOMAIN>`, include provider configuration, and not manipulate configuration used by other providers. If configuration is required for the repository, it should only be relevant at the repository level:

```dart
// BAD
@ConnectOfflineFirstWithRest(
  fieldRename: FieldRename.snake,
  restConfig: RestSerializable(
    // two places to declare the same configuration
    // with no clear logic for the selection hierarchy
    fieldRename: FieldRename.pascal,
  )
)

// GOOD
@ConnectOfflineFirstWithRest(
  restConfig: RestSerializable(
    fieldRename: FieldRename.pascal,
  ),
  sqliteConfig: SqliteSerializable(
    ignore: true,
  ),
  // this property will affect all interactions with the model
  alwaysHydrate: true,
)
```

### Field-level Configuration

Annotations should only reflect configuration relevant to the repository (e.g. directives on how to synthesize). They should not be shortcuts:

```dart
// BAD:
@OfflineFirst(ignore: true)

// GOOD:
@Rest(ignore: true)
@Sqlite(ignore: true)
```

Annotations are most useful when its explicit purpose combines multiple providers **and**:

```dart
@OfflineFirst(where: "{'email': data['email']}")
```

Unlike atomic provider annotations, repositories **can and should** access all relevant provider annotations:

```dart
// all three of these annotations are useful to the OfflineFirst domain
// when generating adapter code
@Rest(name: 'LastName')
@Sqlite(name: 'last_name')
@OfflineFirst(where: "{'last_name': data['LastName']}")
```

### Associations

Associations can require complex fetching. When a domain supports associations between providers, the class-level annotation should be used in a custom checker. For example, `isSibling` or `isAssociation`.

It is recommended to use a repository method dedicated to association fetching instead of the provider, as the repository may route the lookup to a different provider. For example, a User may have 1 Hat, and the repository may already have that Hat in a memory provider. By requesting the repository, the `SqliteProvider` is spared a potentially expensive query.

# Code Generation

Before reading further, this process appears to require a lot of code. This is largely boilerplate required for type checking and Dart's analyzer. The majority of the custom code and logic will live in the adapter serdes.

## Package Setup

Annotation and configuration definitions must be declared outside of the build package if they depend on a package that conflicts with mirrors (Flutter conflicts with mirrors). As other packages may use these annotations (for example, `OfflineFirst` considers `@Rest` and `@Sqlite` annotations along with `@OfflineFirst`), it's safest to keep annotations and builders as independent packages.

For example, the Cloud Firestore package:

```
brick_cloud_firestore
|--example
|--README.md
|--packages

// this package is the only imported into depedencies: in pubspec.yaml
// it contains the importable provider and repositories
// the repositories may also choose to export annotations from sister packages
|--|--brick_cloud_firestore

// since firestore depends on sqlite, an abstract package includes
// annotations and class-level configuration classes that can be digested by brick_build
// and the brick_cloud_firestore package
|--|--brick_cloud_firestore_abstract

// code generation unique to the provider. exports serialize, deserialize, fields, provider model serdes, and any additional builders
|--|--brick_cloud_firestore_generators

// outputs and saves generated code to disk. this is the only package that includes a build.yaml
// there should only be one discovered annotation per build package
|--|--brick_offline_first_with_cloud_firestore_build
```

- [ ] If the provider has a Flutter dependency, a separate package for annotations and configuration exists as a `_abstract` package
- [ ] The `_generators` package **does not** include a `build.yaml` (multiple `build.yaml` files can cause race collisions)
- [ ] `<Provider>Fields`, `<Provider>SerializeGenerator`, `<Provider>DeserializeGenerator`, and `<Provider>ModelSerdesGenerator` can be accessed outside the `_generators` package
- [ ] Only one class-level annotation is discovered per `_build` package

## Provider

### Class-level Configuration

A provider will likely require high-level information about a class that would be inappropriate to define on every instance of a class. For this, a provider can declare a class-level configuration:

```dart
RestSerializable(
  // a REST endpoint is inappropriate to define as an instance-level definition
  requestTransformer: UserRequestTransformer.new,
  // class-level configs are also useful for setting a default for subsequent field-level definitions in the class
  fieldRename: FieldRename.snake,
)
```

These configurations may be injected directly into the adapater (like `endpoint`) or may change behavior for generated code (like `fieldRename`).

This class **should not** be used as an annotation. Instead, it is received as a member of a class-level annotation discovered by the [domain](#domain).

#### Interpreting Class-level Configurations

Once a class is discovered by a builder, the configuration is pulled from the annotation and expanded into easily-digestible Dart form:

```dart
// RestSerializable is our previously-noted configuration class
class RestModelSerdesGenerator extends ProviderSerializableGenerator<RestSerializable> {
  RestModelSerdesGenerator(Element element, ConstantReader reader)
        // subsequent consumers of this provider generator have to use this config key in their class-level domain annotation
        // or whatever annotation is used to discover the model class
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

### Discovering and Interpreting the Field-level Annotation

Similarly, the field-level annotation must be expanded from their constantized versions back to an easily-digestible form. Brick provides a base class for this:

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

This reinitializes at the field level. However, a class will require that all fields go through the same process, and so a `FieldsForClass` class must be made. These fields will be passed to our (de)serialize generators:

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

For providers that do not make use of a class-level config, the `Fields` implementation can be adjusted:

```dart
class RestFields extends FieldsForClass<Rest> {
  final finder = RestAnnotationFinder();

  RestFields(ClassElement element) : super(element: element);
}
```

### Adapters

Adapter serdes generators should be as atomic as possible and not expect code from other adapter generators. By subclassing `SerdesGenerator`, a `_generators` package can quickly produce (de)serializing functions for later consumption in a generator:

```dart
// FieldSerializable is a protocol for field-level annotations defined in brick_core
abstract class RestSerializeGenerator extends SerdesGenerator<Rest, RestModel> {
  final providerName = 'Rest';
  final doesDeserialize = false;

  RestSerialize(ClassElement element, RestFields fields) : super(element, fields);
}
```

Every unignored field of a model will pass through the end function of `coderForField`. This function provides field-level code generation given as much configuration as available:

```dart
class RestSerialize extends OfflineFirstGenerator<Rest> {
  // All discovered fields of the class pass through this function for generator output
  // Private fields, methods, static members, and computed setters are automatically ignored
  String coderForField(field, checker, {wrappedInFuture, fieldAnnotation}) {
    // in serialize, the field value will be `instance.fieldName`
    // in deserialize, the field value will be `data['field_name']`
    final fieldValue = serdesValueForField(field, fieldAnnotation.name, checker: checker);
    final defaultValue = SerdesGenerator.defaultValueSuffix(fieldAnnotation);

    if (checker.isString) {
      return fieldValue;
    }

    if (checker.isDateTime) {
      return '$fieldValue?.toIso8601String()';
    }

    // falling through to an unsupported type, null won't add to the generated output
    return null;
  }
}
```

An adapter always includes serialization and deserialization methods for a provider. At a minimum, all primitive types should be evaluated by the checker and returned to the generator with appropriate serializing or deserializing code. Serdes generators come out as code spaghetti and _that's OK_. Explicit, verbose declarations - even when duplicated across generators - are reliable and easy to debug.

Adapters can also include useful information such as schema data for a SQLite provider or a function to generate an endpoint for a REST provider. The provider can and should access generic (i.e. not related to a specific model instance) model information via the adapter. Adapter members, like models, should only be declared if they are used by the provider.

```dart
// adapter methods and fields are declared in the <PROVIDER>(De)serializeGenerators
List<String> get instanceFieldsAndMethods {
  var toKey = (fields as RestFields).config?.toKey?.trim();

  // Strings should always be wrapped as this is generated code
  // it won't look natural and the type system won't catch errors,
  // so be sure to write comprehensive tests
  if (toKey != null) toKey = "'$toKey'";

  return ['final String toKey = $toKey;'];
}
```

Lastly, serializing and deserializing generators should live in separate classes for legibility:

```dart
class RestSerializeGenerator extends SerdesGenerator<Rest, RestModel> {
  final doesDeserialize = false;
}
class RestDeserialize extends SerdesGenerator<Rest, RestModel> {
  final doesDeserialize = true;
}
```

### Invoking the Generators

The (De)serialize generators are accessed through the `<PROVIDER>ModelSerdesGenerator` from before:

```dart
class RestModelSerdesGenerator extends ProviderSerializableGenerator<RestSerializable> {
  ...

  @override
  get generators {
    final classElement = element as ClassElement;
    // the config expanded previously is now passed to our Fields class
    final fields = RestFields(classElement, config);
    return [
      // the output of these generators will be accessed via a builder in a later step
      RestDeserialize(classElement, fields),
      RestSerialize(classElement, fields),
    ];
  }
}
```

## Domain

### The Class-level Annotation

Domain annotations at the class-level are discovered by the domain builder. **There must only be one class-level annotation per `_build` package**. The annotation includes configuration options for each provider within the domain:

```dart
@ConnectOfflineFirstWithRest(
  // RestSerializable is our configuration body.
  restConfig: RestSerializable(
    requestTransfomer: MyModelTransformer.new,
    fieldRename: FieldRename.snake,
  )
)
class MyModel
```

#### Interpreting the Class-level Annotation

As the interpretation of the provider's configuration is handled by the `<PROVIDER>ModelSerdesGenerator`, forwarding the annotation to the generator is sufficient.

:warning: When declaring the annotation interface, be sure to name the annotation keys after the provider's `<PROVIDER>ModelSerdesGenerator#configKey`. Otherwise the build package will have to subclass the model generator to lock its config key.

#### Discovering the Class-level Annotation

An AnnotationSuperGenerator manages sub generators. This generator is the entrypoint for other builders. It should be simple, with most of its logic delegated to sub generators.

```dart
// @ConnectOfflineFirstWithRest is the annotation that decorates our domain models
class OfflineFirstGenerator extends AnnotationSuperGenerator<ConnectOfflineFirstWithRest> {
  // required for the adapter output
  final String superAdapterName;

  const OfflineFirstGenerator({
    this.superAdapterName = 'OfflineFirst',
  });

    /// Given an [element] and an [annotation], scaffold generators
  List<SerdesGenerator> buildGenerators(Element element, ConstantReader annotation) {
    // `RestModelSerdesGenerator gathers its configuration from the `ConnectOfflineFirstWithRest` annotation
    final rest = RestModelSerdesGenerator(element, annotation);
    final sqlite = SqliteModelSerdesGenerator(element, annotation);
    return <SerdesGenerator>[]
        ..addAll(rest.generators)
        ..addAll(sqlite.generators);
  }
```

This class will be used by other generators in the [build step](#builder).

### Model Dictionary (brick.g.dart)

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
import 'package:brick_sqlite/db.dart' show SqliteModel, SqliteAdapter, SqliteModelDictionary;
import 'package:brick_rest/brick_rest.dart' show RestProvider, RestModel, RestAdapter, RestModelDictionary;
// ignore: unused_import, unused_shown_name
import 'package:sqflite/sqflite.dart' show DatabaseExecutor;
""";
```

:bulb: To reduce analyzer errors, include `// ignore: unused_import` for imports used in part files.

### Builder

At long last, the generated code is output to file(s) on disk using a `builder.dart` file.

The primary build functions will be adapters and the model dictionary, as these are critical to the Brick system:

```dart
final offlineFirstGenerator = const OfflineFirstGenerator();

// all models must be aggregated to one file to check associations
Builder offlineFirstAggregateBuilder(options) => AggregateBuilder(requiredImports: [
      "import 'package:brick_offline_first/brick_offline_first.dart';",
      "import 'package:brick_sqlite/db.dart';",
    ]);

// The Adapter builder uses the same annotation declared in OfflineFirstGenerator
// it also relies on the `buildGenerators` function
Builder offlineFirstAdaptersBuilder(options) =>
    AdapterBuilder<ConnectOfflineFirstWithRest>(offlineFirstGenerator);

// the model dictionary builder similarly requires the domain's class-level annotation.
// this build will perform optional cleanup as well
Builder offlineFirstModelDictionaryBuilder(options) =>
    ModelDictionaryBuilder<ConnectOfflineFirstWithRest>(
      const OfflineFirstModelDictionaryGenerator(),
      expectedImportRemovals: [
        "import 'package:brick_offline_first/brick_offline_first.dart';",
        'import "package:brick_offline_first/brick_offline_first.dart";',
      ],
    );
```

Generators are invoked by builders [in `builders.dart`] and builders are invoked by `build.yaml` using Dart's native task runner. As `build.yaml` can be opaque to the uninitiated and is not part of this repo, documentation about customization can be found on [the package page](https://pub.dartlang.org/packages/build_config). For basic, battle-tested usage, [the build.yaml in this repo](build.yaml) can be used as a base and modified appropriately for custom domains.

# Testing

Generated code can be compared with expected output using the `lib/testing.dart` helper utilities.

The source of the code-to-be-generated must be saved in a separate file from the test suite:

```dart
// test/generated_source/test_simple.dart
@ConnectMyDomain()
class User extends MyDomainModel {}

// for easy discovery, it's recommended to include the output in the same file
final output = r'''
class MyDomainAdapter....
''';
```

In the test suite, an expectation can be written:

```dart
import 'package:brick_build_test/brick_build_test.dart';
import 'generated_source/test_simple.dart' as _$simple;

final generator = MyDomainGenerator();

test('simple', () {
  final annotation = await annotationForFile<ConnectOfflineFirstWithRest>('generated_source', 'simple');
  final generated = await (generator ?? _generator).generateAdapter(
    annotation?.element,
    annotation?.annotation,
    null,
  );
  expect(generated, _$simple.output);
});
```

As adapters can often include excess code not related to serialization, such as supporting information for the provider, the scope of the test can be narrowed to only the (de)serialization code:

```dart
final generateReader = generateLibraryForFolder('generated_source');
test('simple', () {
  final reader = await generateReader('simple');
  final generated = await generator.generate(reader, null);
  expect(generated, _$simple.output);
});
```

# Advanced Techniques

## Custom Type Checking

Most generators may not require an extension of basic type checking (is this a string, is this an int, is this a list). For advanced checking, (e.g. discovering a package-specific class like `OfflineFirstSerdes`), a new checker will have to be created:

```dart
final _serdesClassChecker = TypeChecker.fromRuntime(OfflineFirstSerdes);

class OfflineFirstChecker extends SharedChecker {
  bool get isSerdes => _serdesClassChecker.isAssignableFromType(targetType);
}
```

For every new or removed type check, always update `SharedChecker`'s computed getter `isSerializable`.

# FAQ

### Why are all models hacked into a single file?

Dart's build discovers annotations within one file at a time. Because Brick makes use of associations, it must be aware of all files, including similarly-annotated models that may not be in the same file. Therefore, one build step handles combining all files via a known directory (this is why folder organization is so important) and then combines them into a file. By writing that file, another build step listening for the extension kicks off _the next_ build step to interpret each annotation.
