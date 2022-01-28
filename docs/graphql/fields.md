?> The GraphQL domain is currently in Alpha. APIs are subject to change.

# Field Configuration

## Annotations

### `@Graphql(enumAsString:)`

Brick by default assumes enums from a GraphQL API will be delivered as integers matching the index in the Flutter app. However, if your API delivers strings instead, the field can be easily annotated without writing a custom generator.

Given the API:

```json
{ "user": { "hats": [ "bowler", "birthday" ] } }
```

Simply convert `hats` into a Dart enum:

```dart
enum Hat { baseball, bowler, birthday }

...

@Rest(enumAsString: true)
final List<Hat> hats;
```

### `@Graphql(name:)`

GraphQL keys can be renamed per field. This will override the default set by `GraphqlSerializable#fieldRename`.

```dart
@Graphql(
  name: "full_name"  // "full_name" is used in from and to requests to GraphQL instead of "last_name"
)
final String lastName;
```

### `@Graphql(ignoreFrom:)` and `@Graphql(ignoreTo:)`

When true, the field will be ignored by the (de)serializing function in the adapter.

## Unsupported Field Types

The following are not serialized to GraphQL. However, unsupported types can still be accessed in the model as non-final fields.

* Nested `List<>` e.g. `<List<List<int>>>`
* Many-to-many associations
