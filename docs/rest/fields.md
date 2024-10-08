# Field Configuration

## Annotations

### `@Rest(enumAsString:)`

Brick by default assumes enums from a REST API will be delivered as integers matching the index in the Flutter app. However, if your API delivers strings instead, the field can be easily annotated without writing a custom generator.

Given the API:

```json
{ "user": { "hats": ["bowler", "birthday"] } }
```

Simply convert `hats` into a Dart enum:

```dart
enum Hat { baseball, bowler, birthday }

...

@Rest(enumAsString: true)
final List<Hat> hats;
```

### `@Rest(name:)`

REST keys can be renamed per field. This will override the default set by `RestSerializable#fieldRename`.

```dart
// "full_name" is used in from and to requests to REST instead of "last_name"
@Rest(name: "full_name")
final String lastName;
```

### `@Rest(ignoreFrom:)` and `@Rest(ignoreTo:)`

When true, the field will be ignored by the (de)serializing function in the adapter.

## Unsupported Field Types

The following are not serialized to REST. However, unsupported types can still be accessed in the model as non-final fields.

- Nested `List<>` e.g. `<List<List<int>>>`
- Many-to-many associations
