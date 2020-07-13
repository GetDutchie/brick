[![Build Status](https://travis-ci.org/greenbits/brick.svg?branch=master)](https://travis-ci.org/greenbits/brick)

![An intuitive way to work with persistent data](./doc/logo.svg)

An intuitive way to work with persistent data in Dart.

**Brick is still in alpha release**. Bugs and API changes will occur frequently; these will be recorded in package CHANGELOGs.

## What is Brick?

Brick is an extensible query interface for Dart applications. It's an [all-in-one solution](https://www.youtube.com/watch?v=2noLcro9iIw) responsible for representing business data in the application, regardless of where your data comes from. Using Brick, developers can focus on implementing the application, without [concern for where the data lives](https://www.youtube.com/watch?v=jm5i7e_BQq0). Brick was inspired by the need for applications to work offline first, even if an API represents your source of truth.

Brick is inspired by [ActiveRecord](https://guides.rubyonrails.org/active_record_basics.html), [Ecto](https://hexdocs.pm/ecto/), and similar libraries.

Brick does a lot at once. [Learn](#learn) includes videos, tutorials, and examples that break down Brick and is a great place to start.

## Why Brick?

* Your app requires [offline access](packages/brick_offline_first) to data
* Handles and [hides](packages/brick_build) all complex serialization/deserialization logic between any external source(s)
* Single [access point](#repository) and opinionated DSL establishes consistency when pushing and pulling data across your app
* Automatic, [intelligently-generated migrations](packages/brick_sqlite)
* Legible [querying interface](#query)

## When should I not use Brick?

* When data doesn't persist between sessions
* When large datasets are frequently used (images, document storage, etc.)
* When key-value data is stored (instead consider [localstorage](https://pub.dev/packages/localstorage))

## Usage

Create a model as the app's business logic:

```dart
// app/models/user.dart
@ConnectOfflineFirstWithRest()
class User extends OfflineFirstWithRestModel {}
```

And generate (de)serializing code to fetch to and from multiple providers:

```shell
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

Brick natively [serializes primitives, associations, and more](packages/brick_offline_first/example/lib/app/models/kitchen_sink.dart).

If it's still murky, [check out Learn](#learn) for videos, tutorials, and examples that break down Brick.

# Table of Contents

- [Setup](#setup)
- [Glossary](#glossary)
- [Models](#models)
  * [Setup](#setup-1)
  * [Serialized Fields](#serialized-fields)
  * [Annotations](#annotations)
  * [Custom Generators](#custom-generators)
    - [Placeholders](#placeholders)
  * [FAQ](#faq)
- [Query](#query)
  * [where:](#where)
    - [Associations](#associations)
    - [compare:](#compare)
    - [required:](#required)
  * [Filtering](#filtering)
    - [Where.byField](#wherebyfield)
    - [Where.firstByField](#wherefirstbyfield)
- [Providers](#providers)
  * [Fetching and Mutating Data](#fetching-and-mutating-data)
  * [Query](#query-1)
    - [providerArgs:](#providerArgs)
    - [where:](#where-1)
  * [Field-level Configuration](#field-level-configuration)
- [Repository](#repository)
  * [Setup](#setup-2)
    - [Access](#access)
  * [Creating a Custom Repository](#creating-a-custom-repository)
    - [Methods](#methods)
      * [Applying Query#action](#applying-queryaction)
  * [FAQ](#faq-1)
- [Providers and Repositories](#providers-and-repositories)
- [Learn](#learn)
- [General FAQ](#general-faq)

# Setup

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
    ```shell
    mkdir -p lib/app/adapters lib/app/db lib/app/models;
    ```

    Models **must be** saved in `lib/app/models/<class_as_snake_name>.dart`.

1. Extend [an existing repository](#providers-and-repositories) or create your own:
    ```dart
    // lib/app/repository.dart
    class MyRepository extends OfflineFirstWithRestRepository {}
    ```

## Recommended but Optional

**Ignore generated files in `.gitignore`**. It is recommended to **not** commit files appended with `.g.dart` to version control. Instead, these files should be built on every `pull` as well as on every build in a CI/CD pipeline. This ensures your code is generated with the most recent version of Brick and remains untouchable by contributors.

```
*.g.dart
# alternately, uncomment the lines below to only target brick files
# app/adapters/*.dart
# app/db/*.g.dart
# app/brick.g.dart
```

**Generate files on every significant change**. While not required, this is recommend especially for teams and open source projects. It's required when `*.g.dart` files are ignored. To automate the generation without using `build_runner watch`, the following can be added to `.git/hooks/post-checkout`:

```shell
# .git/post-checkout
#!/bin/sh

cd `dirname "$0"`
cd ../../
flutter pub get
flutter pub run build_runner build
```

Ensure that the `post-checkout` file is executable:

```shell
chmod 755 .git/hooks/post-checkout
```

# Glossary

* **source** - external information warehouse that delivers unrefined data
* [**Provider**](#providers) - fetches from and pushes to a `source`
* [**Repository**](#repository) - manages `Provider`(s) and determines which provider results to send
* **Adapter** - normalizes data input and output between `Provider`s
* [**Model**](#models) - business logic unique to the app. Fetched by the `Repository`, and if merited by the `Repository` implementation, the `Provider`.
* **ModelDictionary** - guides a `Provider` to the `Model`'s `Adapter`. Unique per `Provider`.
* **field** - single, accessible property of a model. For example, `final String id`
* **deserialize** - convert raw data _from_ a provider
* **serialize** - convert a model instance _to_ raw data for a provider

# Models

## Setup

Every model must be decorated by an annotation and extend a base type that the repository manages:

```dart
@ConnectOfflineFirstWithRest()
class User extends OfflineFirstModel {}
```

The primary constructor of the model **must** include named arguments for all serialized fields. Brick **does not support** unnamed constructor arguments. This is an opinionated choice that enables the adapters to reliably return a hydrated model. The constructor may elect to mutate input data, but the named arguments **must be present**:

```dart
class Hat extends OfflineFirstModel {
  final String color;
  final int width;

  Hat({
    this.color,
    int width,
  }) : width = (width ?? 0) + 1;
}
```

:bulb: Every `import` in a model definition file will be copied to `brick.g.dart` and available to the adapters. This is useful for field-level generators or class-level annotations that stringified functions (`RestSerializable#endpoint`).

## Serialized Fields

All `final` fields of a model, unless specified, will be (de)serialized by the provider. Computed getters (`int get number => 5 + 10`) are not deserialized _from_ providers. However, they are serialized to, allowing generation of custom fields to send to an API or to query cached results in SQLite (to skip, declare `ignore: true` in the field's annotation). Setters are never serialized.

### Annotations

As providers are ultimately responsible for converting raw data into model data, a description of fields on models is overly generic. Field-level annotations always override class-level annotations/configuration. However, providers should adhere to some standards of annotations:

| Named Arg | Description | Example |
|---|---|---|
| `ignore:` | Do not deserialize (from) or serialize (to) this field to a provider | `@Rest(ignore: true)` |
| `name:` | Stored key for this field according to the provider. In SQLite, for example, this would be the column name. | `@Sqlite(name: "address_2")` |
| `defaultValue:` | Value to use in absence or `null` of the instance. It does not dictate what the Dart model will hold on empty instantiation. **Recommended to use Dart's default constructor assignment instead**. | `@Rest(defaultValue: '[]')` |
| `nullable:` | `null` fields are handled gracefully when serializing and deserializing. | `@Rest(nullable: true)` |
| `fromGenerator` | A stringified function with access to [placeholders](#placeholders); replaces adapter's generated deserialize code for the field. Do not include trailing semicolons or function body wrapping symbols (`{}` or `=>`) in the definition. | `@Rest(fromGenerator: "int.tryParse(%DATA_PROPERTY%.toString())")` |
| `toGenerator` | A stringified function with access to [placeholders](#placeholders); replaces adapter's generated serialize code for the field. Do not include trailing semicolons or function body wrapping symbols (`{}` or `=>`) in the definition. | `@Sqlite(toGenerator: "%INSTANCE_PROPERTY% > 1 ? 1 : 0")` |

### Custom Generators

For non-standard input, consider writing a custom (de)serializer. Use caution as this will **completely replace** inferred type serializations. These are available at field-level as arguments.

Since Dart requires annotations to be constants, `Function`s must be stringified.

```dart
// given
final data = {
  'outfit': {
    'hat': 0,
    'shoe': 1,
    'shirt': 1,
  },
};

// a simple generator for the field `final Map<Clothes, Condition> clothesMap`
"""(data['outfit'] as Map<String, dynamic>).map((key, value) {
  return MapEntry(
    Clothes.keys.firstWhere((v) => v.toString().split('.').last == value),
    Condition.values[value]
  );
})""";
```

#### Placeholders

To replace a few parts and DRY up code in custom, field-level generators, placeholders can be employed and replaced with values at build time.

All custom generators passed through field annotations (such as  `@Rest(fromGenerator:)` or `@Sqlite(toGenerator:)`) have access to predefined placeholders and custom placeholders.

To declare your own variables, wrap the variable name like a tag using `@`: `@VARIABLE_NAME@value@/VARIABLE_NAME@`. Placeholders and their values **must** conform to the RegEx `[\w\d]+`.

```dart
// Important parts are swapped out for placeholders:
final customGenerator = """(%DATA_PROPERTY% as Map<String, dynamic>).map((key, value) {
  return MapEntry(
    %ENUM%.keys.firstWhere((v) => v.toString().split('.').last == value),
    Condition.values[value]
  );
})""";

// And variable values are assigned:
@Rest(
  fromGenerator: "$customGenerator@ENUM@Clothes@/ENUM@",
);
```

There are several globally-defined placeholders:

* `%ANNOTATED_NAME%` - key name.
    ```dart
    @Rest(name: 'my_field')
    final String myField
    // => 'my_field'
    ```
* `%DATA_PROPERTY%` - deserializing key name (`@Rest(name:)` or `@Sqlite(name:)` or the default) wrapped in the deserialized map. **Only use in `fromGenerator`**.
    ```dart
    @Rest(name: 'my_field')
    final String myField
    // => data['my_field']
    ```
* `%INSTANCE_PROPERTY%` - serializing property. **Only use in `toGenerator`**.
    ```dart
    @Rest(name: 'my_field')
    final String myField
    // => instance.myField
    ```

## FAQ

### Why are annotations AND extensions required?

The annotation is required to build the generated files (adapters, migrations, etc.). The type extension (e.g. `OfflineFirstModel`) is used by the repository's type system.

# Query

Filter local data using `Query`. Providers will use the `Query` to translate requested data into their query language. For the universality and legibility of SQL, that provider's translations will be used in the following examples but it is not the de facto query language of all providers.

## `where:`

When using `Query`, use the field name to find pertinent data instead of the column name. For example:

```dart
class User extends OfflineFirstModel {
  final SqliteAssociation association;
  @Sqlite(name: 'name')
  final String lastName;
}

// A query for all users with the last name "Mustermann":
Query.where('lastName', 'Mustermann') // note this is lastName and not name or last_name
```

Querying can be done with `Where` or `WherePhrase`:

1) `WherePhrase` is a collection of `Where` statements.
2) `WherePhrase` can't contain mixed `required:` because this will output invalid SQL. For example, when it's mixed: `WHERE id = 2 AND name = 'Thomas' OR name = 'Guy'`. The OR needs to be its own phrase: `WHERE (id = 2 AND name = 'Thomas') OR (name = 'Guy')`.
3) `WherePhrase` can be intermixed with `Where`.
      ```dart
      [
        Where('id').isExactly(2),
        WherePhrase([
          Or('name').isExactly('Guy'),
          Or('name').isExactly('Thomas')
        ], required: false)
      ]
      // => (id == 2) || (name == 'Thomas' || name == 'Guy')
      ```

:warning: Queried enum values should map to a primitive. Plainly, **always include `.index`**: `Where('type').isExactly(MyEnumType.value.index)`.

### Associations

`providerArgs` are forwarded to the provider which chooses to accept or reject specific keys. For example, Rest accepts the `headers` key to control request headers. SQLite supports operators like `groupBy`, `orderBy`, `offset`, and others in its `providerArgs`.

When querying associations, use a nested `Where`, again searching by field name on the association. For example:

```dart
Query(where: [
  Where('association').isExactly(
    Where('name').isExactly('Thomas'),
  ),
])
```

### `compare:`

Fields can be compared to their values beyond an exact match (the default).

```dart
Where('name', value: 'Thomas', compare: Compare.contains);
```

* `between`
* `contains`
* `doesNotContain`
* `exact`
* `greaterThan`
* `greaterThanOrEqualTo`
* `lessThan`
* `lessThanOrEqualTo`
* `notEqual`

Please note that the provider is ultimately responsible for supporting `Where` queries.

### `required:`

Conditions that are required must evaluate to true for the query to satisfy. They can be specified individually:

```dart
Query(where: [
  Where('name', value: 'Thomas', required: true),
  And('age').isExactly(42),
])
// => name == 'Thomas' && age == 42
```

Or specified as a whole phrase:

```dart
Query(where: [
  WherePhrase([
    Where('name', value: 'Thomas', required: false),
    Where('age', value: 42, compare: Compare.notEqual, required: false),
  ], required: true),
  WherePhrase([
    Where('height', value: [182, 186], compare: Compare.between),
    Where('country', value: 'France'),
  ], required: true)
])
// =>  (name == 'Thomas' || age != 42) && (height > 182 && height < 186 && country == 'France')
```

:bulb: If expanded `WherePhrase`s become unlegible, helpers `And` and `Or` can be used:

```dart
Query(where: [
  AndPhrase([
    Or('name').isExactly('Thomas'),
    Or('age').isNot(42),
  ]),
  AndPhrase([
    And('height').isBetween(182, 186),
    And('country').isExactly('France'),
  ]),
])
// =>  (name == 'Thomas' || age != 42) && (height > 182 && height < 186 && country == 'France')
```

## Filtering

In the provider (or even a REST endpoint), convenience methods are available to quickly interpret a query.

### `Where.byField`

Find conditions that evaluate a specific field. A field is a member on a model, such as `myUserId` in `final String myUserId`. If the use case for the field only requires one result, say `id` or `primaryKey`, `Where.firstByField` may be more useful.

```dart
Where.byField('lastName', query.where);
```

### `Where.firstByField`

Find the first occurrance of a condition that evaluates a specific field. This is useful when querying for a unique record. For all conditions, use `Where.byField`.

```dart
final condition = Where.firstByField('id', query.where);
final id = condition?.value;
```

# Providers

Providers deliver data from a single source as a model. For example, a provider could fetch from Firebase. Or from a SQL database.

A provider is **only accessed from the repository**. Invoking the provider from the application is strongly discouraged; if a custom method or extension is required, the repository should be customized instead of the provider.

To generate code for a custom provider, please see [brick_build](https://github.com/greenbits/brick/tree/master/packages/brick_build#provider).

## Fetching and Mutating Data

A provider fetches, inserts, updates, and deletes. Methods only handle one model or instance at a time. These methods should hold minimal amounts of logic and be narrowly focused. If providers require a substantial translation layer (for example, transforming a `WherePhrase` into SQL), the translation layer should be done by a separate class and delivered cleanly to the caller.

```dart
// the only type argument describes the expected return result
// and how the method should deserialize the data
Future<_Model> get<_Model extends RestModel>({Query query}) async {
  // the transforming logic can be tested separately as a separate class
  final queryAsSql = QuerySqlTransformer(query).asSql;
}
```

For methods that mutate data, the first unnamed argument should be an instance of the model with a named argument for `Query`:

```dart
Future<_Model> upsert<_Model extends RestModel>(RestModel instance, {Query query}) async {}
```

Underscore prefixing of type declarations ensure that 1) they will likely not conflict with another class 2) they signal closed, non-exported use. This convention is not required in custom implementations but is recommended for consistency.

## Query

Every public instance method should support a named argument of `{Query query}`. `Query` is the glue between an application and an abstracted provider or repository. It is accessed by both the repository and the provider, but as the last mile, the provider should interpret the `Query` at its barest level.

### `providerArgs:`

`providerArgs` describe how to interact with a provider's source.

```dart
providerArgs: {
  // limit describes how many results the provider requires from the source
  'limit': 10,
},
```

As `providerArgs` can vary from provider to provider and IDE suggestions are unavailable to a string-key map, `providerArgs` should be clearly and accessibly documented within every new provider.

### `where:`

`where` queries with a model's properties. A provider may optionally support `where` arguments. For example, while a SQLite provider will always support column querying, a RESTful API will likely be less consistent and may require massaging the field name:

```dart
[Where('firstName').isExactly('Thomas'), Where('age').isExactly(42)];
// SQLite => SELECT * FROM Users WHERE first_name = "Thomas" AND age = 42;
// REST => https://api.com/users?by_first_name=Thomas&age=42
```

The translation from model field name (e.g. `firstName`) to serializer field name (e.g. `first_name`) may occur in the adapter or in a class-level configuration (e.g. `RestSerializable#endpoint`). However, it should always be accessed by the provider from the adapter.

## Field-level Configuration

A provider may choose to implement configuration at the field-level with annotations. Double check your provider's documentation to review all options.

```dart
@Rest(ignore: true, name: "e-mail")
@Sqlite(unique: true)
final String email;
```

# Repository

A repository routes application data to and from one or many providers. Repositories should only hold repository-specific logic and not pass interpreted data to its providers (e.g. the repository does not transform a `Query` into a SQL statement for its SQLite provider).

## Setup

End-implementation uses (e.g. a Flutter application) should `extend` an abstract repository and pass arguments to `super`. If custom methods need to be added, they can be written in the application-specific repository and not the abstract one. Application-specific `brick.g.dart` are also imported:

```dart
// app/repository.dart
import 'brick.g.dart' show migrations, restModelDictionary;
class MyRepository extends OfflineFirstRepository {
  MyRepository({
    String baseEndpoint,
  }) : super(
    migrations: migrations,
    restProvider: RestProvider(baseEndpoint, modelDictionary: restModelDictionary),
  );
}
```

### Access

To use a repository seamlessly with a state management system like BLoCs without passing around context, access the repository as a singleton:

```dart
import 'package:brick_core/core.dart';
import 'package:brick_rest/rest.dart';
import 'package:my_app/app/brick.g.dart' show restModelDictionary;

// app/repository.dart
class MyRepository extends SingleProviderRepository<RestModel> {
  MyRepository._({
    String baseEndpoint,
  }) : super(
    RestProvider(baseEndpoint, modelDictionary: restModelDictionary),
  );
  factory MyRepository() => _singleton;

  static MyRepository create(String baseEnpoint) {
    _singleton = MyRepository._(
      baseEndpoint: baseEndpoint,
    );
  }
}
```

However, the singleton is not required (such as via an `InheritedWidget`). Multiple repositories can also manage different data streams. Each repository should have only one type of a provider (e.g. a repository cannot have two `RestProvider`s but it can have a `RestProvider`, a `SqliteProvider`, and a `MemoryCacheProvider`).

Once the app is initialized, it is recommended to immediately run `#initialize`. Repositories will execute setup functions (e.g. running SQL migrations) exactly once within this method:

```dart
// configure and initialize at the application's entrypoint
class BootScreenState extends State<BootScreen> {
  ...
  initState() {
    super.initState();
    // initialize only needs to be run once:
    MyRepository.create("https://api.com");
    MyRepository().initialize();
  }
}
```

## Creating a Custom Repository

There are several principles for repositories that should be considered beyond its implementation of `ModelRepository`:

* [ ] The repository only fetches data from providers
* [ ] The repository cannot (de)serialize models with a provider
* [ ] The repository does not preserve model states
* [ ] Every method returns from the same provider
* [ ] `Query#action` is applied when it does not exist on a `query` from arguments

To generate code for a custom repository, please see [brick_build](https://github.com/greenbits/brick/tree/master/packages/brick_build#repository).

### Methods

While repositories share method names with providers, they are distinct from providers in that they are synthesizers:

```dart
class MyRestAndMemoryRepository implements ModelRepository {
  get<_Model>({Query query}) async {
    // check one provider for data
    if (memoryProvider.has(query)) return memoryProvider.get<_Model>(query: query);

    // fetch data from another provider
    final restResults = await restProvider.get<_Model>(query: query);

    // ensure that the data is accessible across all providers
    restResults.forEach((r) => memoryProvider.upsert<_Model>(r));

    // now that the data is inserted, we're confident in a refetch from the provider
    // without checking for existence
    return memoryProvider.get<_Model>(query: query);
  }
}
```

:warning: When juggling multiple providers, consistently resolve with data from the same provider across all methods. When in doubt, prioritize data from a local provider:

```dart
// BAD:
get() {
  ...
  return sqliteProvider.get();
}
upsert() {
  ...
  return memoryProvider.upsert();
}

// GOOD:
get() {
  ...
  return sqliteProvider.get();
}
upsert() {
  ...
  return sqliteProvider.upsert();
}
```

Repositories should be the _only_ class that can call a provider method. This enforces a consistent data stream throughout an application.

#### Applying `Query#action`

Before passing a query to a provider method, it is recommended for the repository to apply an action to a query if it doesn't otherwise exist. For example, while `RestProvider#upsert` accepts both new and updated instances, its invoking repository has separate methods for `update` and `insert`:

```dart
class MyRepository {
  insert<_Model>(_Model instance, {Query query}) {
    query = (query ?? Query()).copyWith(action: QueryAction.insert);
    await restProvider.upsert<_Model>(instance, query: query);
  }

  update(_Model instance, {Query query}) {
    query = (query ?? Query()).copyWith(action: QueryAction.update);
    await restProvider.upsert<_Model>(instance, query: query);
  }
}

class RestProvider {
  upsert<_Model>(_Model instance, {Query query}) {
    final headers = {};
    if (query.action.update) headers['method'] = "PUT";
    if (query.action.insert) headers['method'] = "POST";
  }
}
```

## FAQ

### How can I (de)serialize a model with a repository?

Repositories do not have model dictionaries because they do not interpret sources. Providers are the only classes with access to adapters.

# Providers and Repositories

* [REST Provider](packages/brick_rest) - Connect a REST API to Brick
* [SQLite Provider](packages/brick_sqlite) - Connect a SQLite database to Brick (requires Flutter)
* [Memory Cache Provider](packages/brick_sqlite#memory-cache-provider) - Store models in memory for easy access. Requires [brick_sqlite](packages/brick_sqlite)
* [Firestore Provider](https://github.com/jnhuynh/brick_cloud_firestore) - Connect to Firebase's Cloud Firestore
* [Offline First Repository](packages/brick_offline_first) - Fetch results from a local storage (SQLite or Memory Cache). SQLite is hydrated by a remote provider.
* [Offline First With Rest Repository](packages/brick_offline_first#offline-first-with-rest-repository) - Uses the REST Provider as Offline First Repository's remote provider
* [Offline First with Firestore Repository](https://github.com/jnhuynh/brick_cloud_firestore/tree/master/brick_cloud_firestore) - Uses the Cloud Firestore as Offline First Repository's remote provider

## Learn

* Video: [Brick Architecture](https://www.youtube.com/watch?v=2noLcro9iIw). An explanation of Brick parlance with a supplemental analogy.
* Video: [Brick Basics](https://www.youtube.com/watch?v=jm5i7e_BQq0). An overview of essential Brick mechanics.
* Example: [Simple Associations using the OfflineFirstWithRest domain](example)
* Tutorial: [Setting up a simple app with Brick](http://www.flutterbyexample.com/#/posts/2_adding_a_repository)

## General FAQ

### Do I have to get rid of BLoC or Scoped Model or Redux in my app to use Brick?

Nope. Those are _state_ managers. As a _store_ manager, Brick tracks and delivers persistent data across many sources, but it does not care about how you render that data. In fact, in its first app, Brick was integrated with BLoCs - the BLoC requested the data, Brick discovered the data, delivered the data back to the BLoC, and the BLoC delivered the data to the UI component for rendering.

As Repositories can output streams in `#getBatched`, a state manager could be easily bypassed. However, after trial and error, the Brick team determined the maintainence benefits of separating presentation and logic outweighed forgoing a state manager.

### What's in the name?

Brick isn't a state management library, it's a data _store_ management library. While Brick doesn't persist data itself, it routes data between different source. "Brick" plays on the adage "brick and mortar store."
