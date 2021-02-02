# Field Configuration

`Map`s can be serialized, but they must be digestible by `jsonEncode`.

## `@Sqlite(name:)`

SQLite column names can be named per field except with associations. Using `name:` is **strongly discouraged** as Brick's naming consistency is reliable and easily managed through migrations.

```dart
@Sqlite(name: "full_name")
final String lastName;
```

## `@Sqlite(index:)`

Create an `INDEX` on a single column. A `UNIQUE` index will be created when `unique` is `true`. When `unique` is `true` and `index` is absent or `false`, an index is not created. Iterable associations are automatically indexed through a generated joins table. `index` declared on these fields will be ignored. Defaults `false`.

## `@Sqlite(unique:)`

This fields are marked `UNIQUE` in SQLite and are useful for external identifiers. An error will throw if a non-unique value is inserted.

```dart
@Sqlite(unique: true)
final String lastName;
```

## `@Sqlite(onDeleteSetDefault:)`

When true, deletion of a parent will set this table's referencing column to the default,
usually `NULL` unless otherwise declared. Defaults `false`. This value is only applicable when decorating fields that are **single associations** (e.g. `final SqliteModel otherSqliteModel`). It is otherwise ignored.

## `@Sqlite(onDeleteCascade:)`

When true, deletion of the referenced record by `foreignKeyColumn` on the `foreignTableName` this record. For example, if the foreign table is "departments" and the local table is "employees," whenever that department is deleted, "employee" will be deleted. Defaults `false`.

This value is only applicable when decorating fields that are **single associations** (e.g. `final SqliteModel otherSqliteModel`). It is otherwise ignored.

## Unsupported Field Types

The following are not serialized to SQLite. However, unsupported types can still be accessed in the model as non-final fields.

* Nested `List<>` e.g. `<List<List<int>>>`
* Many-to-many associations
