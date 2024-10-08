# Field Configuration

## Annotations

### `@Graphql(enumAsString:)`

Brick by default assumes enums from a GraphQL API will be delivered as integers matching the index in the Flutter app. However, if your API delivers strings instead, the field can be easily annotated without writing a custom generator.

Given the API:

```json
{ "user": { "hats": ["bowler", "birthday"] } }
```

Simply convert `hats` into a Dart enum:

```dart
enum Hat { baseball, bowler, birthday }

...

@Graphql(enumAsString: true)
final List<Hat> hats;
```

### `@Graphql(name:)`

GraphQL keys can be renamed per field. This will override the default set by `GraphqlSerializable#fieldRename`.

```dart
// "full_name" is used in ***fromGraphql*** and ***toGraphql*** requests instead of "last_name"
@Graphql(name: "full_name")
final String lastName;
```

### `@Graphql(ignoreFrom:)` and `@Graphql(ignoreTo:)`

When true, the field will be ignored by the (de)serializing function in the adapter.

## `#toJson` and subfields

When a field's type's class has a `#toJson` method that returns a `Map`, subfields will be automatically populated on fetch requests based on the `final` instance fields of that field's type.

```dart
class Hat {
  final String fabric;
  final int width;

  Hat({this.fabric, this.width});

  Map<String, dynamic> toJson() => {'fabric': fabric, 'width': width};
}

class Mounty {
  final Hat hat;
  final String horseName
  final String name;
}
```

Produces the following GraphQL document on `query` or `subscription`:

```graphql
query {
  myQueryName {
    hat {
      fabric
      width
    }
    horseName
    name
  }
}
```

## Unsupported Field Types

The following are not serialized to GraphQL. However, unsupported types can still be accessed in the model as non-final fields.

- Nested `List<>` e.g. `<List<List<int>>>`
- Many-to-many associations
