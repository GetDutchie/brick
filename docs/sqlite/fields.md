# Field Configuration

`Map`s can be serialized, but they must be digestible by `jsonEncode`.

## `@Sqlite(name:)`

SQLite column names can be named per field except with associations. Using `name:` is **strongly discouraged** as Brick's naming consistency is reliable and easily managed through migrations.

```dart
@Sqlite(name: "full_name")
final String lastName;
```

## `@Sqlite(index:)`

## `@Sqlite(unique:)`

## `@Sqlite(onDeleteSetDefault:)`

## `@Sqlite(onDeleteCascade:)`

## Unsupported Field Types

The following are not serialized to SQLite. However, unsupported types can still be accessed in the model as non-final fields.

* Nested `List<>` e.g. `<List<List<int>>>`
* Many-to-many associations
