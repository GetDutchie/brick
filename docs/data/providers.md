# Providers

Providers deliver data from a single source as a model. For example, a provider could fetch from Firebase. Or from a SQL database.

A provider is **only accessed from the repository**. Invoking the provider from the application is strongly discouraged; if a custom method or extension is required, the repository should be customized instead of the provider.

To generate code for a custom provider, please see [brick_build](https://github.com/GetDutchie/brick/tree/main/packages/brick_build#provider).

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

## Field-level Configuration

A provider may choose to implement configuration at the field-level with annotations. Double check your provider's documentation to review all options.

```dart
@Rest(ignore: true, name: "e-mail")
@Sqlite(unique: true)
final String email;
```
