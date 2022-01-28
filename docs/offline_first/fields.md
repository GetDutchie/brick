# Field Config

## `@OfflineFirst(where:)`

Using unique identifiers, `where:` can connect multiple providers. It is declared using a map between a local provider (key) and a remote provider (value). This is useful when a remote provider only includes unique identifiers (such as `"id": 1`) of associations, the OfflineFirstRepository can lookup that instance from another source and deserialize into a complete model.

!> This is a rare instance where the serializer property name is used instead of the field name, such as `last_name` instead of `lastName`.

For a concrete example, SQLite is the local data source and REST is the remote data source:

Given the API:
```javascript
{ "assoc": {
    // These don't have to map to SQLite columns.
    // They can also be String uuids that SQLite considers unique
    "id": 12345,
    "ids": [12345, 6789]
    }}
```

The association can be automatically mapped to SQLite (note the inclusion of `data`; this will always be "data" as it specifies the in-progress deserialization):

```dart
@OfflineFirst(where: {'id' : "data['assoc']['id']"})
final Assoc assoc;

@OfflineFirst(where: {'id' : "data['assoc']['ids']"})
final List<Assoc> assoc;
```

`@OfflineFirst(where:)` only applies to associations or iterable associations. If `@OfflineFirst(where:)` is not defined, the model will attempt to be instantiated by the REST key that maps to the field.

!> When `@OfflineFirst(where:)` is defined, the `@Rest(toGenerator:)` generator will not feature the field **unless** a `toRest` custom generator is defined OR only one pair is defined in the map.

## Unsupported Field Types

* Any unsupported field types from `RestProvider`, `GraphqlProvider`, and `SqliteProvider`
* Future iterables of future models (i.e. `Future<List<Future<Model>>>`.
