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

When true, deletion of a parent will set this table's referencing column to the default, usually `NULL` unless otherwise declared. Defaults `false`.

This value is only applicable when decorating fields that are **single associations** (e.g. `final SqliteModel otherSqliteModel`). It is otherwise ignored.

## `@Sqlite(onDeleteCascade:)`

When true, deletion of the referenced record by `foreignKeyColumn` on the `foreignTableName` this record. For example, if the foreign table is "departments" and the local table is "employees," whenever that department is deleted, "employee" will be deleted. Defaults `false`.

This value is only applicable when decorating fields that are **single associations** (e.g. `final SqliteModel otherSqliteModel`). It is otherwise ignored.

### `@Sqlite(columnType:)`

In some exceptional circumstances, low-level manipulation of Brick's automatic schema creation is necessary.

:warning: This is an advanced feature. In nearly every case, you can trust Brick's determination of your field. If you're frequently using this option, consider your greater architecture and use of Brick.

```dart
@Sqlite(columnType: Column.blob)
final Uint8List image;
```

!> Because this feature overrides Brick assumptions about the column type, the field will be inserted (toSqlite) **as is** and returned **as is** from deserialization (fromSqlite). `@Sqlite(fromGenerator:)` and `@Sqlite(toGenerator:)` are required if Brick does not know how [to serialize the field](https://github.com/GetDutchie/brick/blob/main/packages/brick_build/lib/src/utils/shared_checker.dart#L94-L109).

## Updating Associations

If your instance fields are mutable (i.e. non `final`), Brick will reconcile associations after saving the instance.

```dart
class MyModel extends SqliteModel {
  /// if this field were `final List<AssociationModel> associations`
  /// calling `associations.clear()` and then `upsert(instance)` **would not**
  /// change the value of associations.
  List<AssociationModel> associations;

  MyModel(this.associations)
}

final instance = MyModel([AssociationModel()]);
instance.associations.length // => 1
instance.associations.clear();
await provider.upsert<MyModel>(instance);
final instanceFromSqlite = await provider.get<MyModel>(
  query: Query.where('primaryKey', instance.primaryKey, limit1: true)
);
instanceFromSqlite.associations.length // => 0
```

## Unsupported Field Types

The following are not serialized to SQLite. However, unsupported types can still be accessed in the model as non-final fields.

* Nested `List<>` e.g. `<List<List<int>>>`
* Many-to-many associations
