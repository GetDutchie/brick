# Brick SQLite Provider

Local storage for Flutter apps using [Brick](https://github.com/greenbits/brick).

## Supported `Query` Configuration

### `providerArgs`

The following map exactly to their SQLite keywords. The values will be inserted into a SQLite statement **without being prepared**.

* `collate`
* `having`
* `groupBy`
* `limit`
* `offset`
* `orderBy`

As the values are directly inserted, use the field name:

```dart
//given this field
@Sqlite(name: 'last_name')
final String lastName;

Query(
  where: [Where.exact('lastName', 'Mustermann')],
  providerArgs: {'orderBy': 'lastName ASC'},
)
```

### `where:`

All fields and associations are supported. All `Compare` values are also supported without additional configuration.

## Models

### Intelligent Migrations

Whenever a new field(s) is added or removed from a connected model, Brick can automatically generate a migration for SQLite. For even less friction, running the watcher while actively developing will create the migration on model save:

```shell
flutter pub run build_runner watch
```

:bulb: While Brick guesses right most of the time, the migration should still be reviewed after it's created (for example, a `DropTable` might just be a `RenameTable`).

## Fields

`Map`s can be serialized, but they must be digestible by `jsonEncode`.

### `@Sqlite(name:)`

SQLite column names can be named per field except with associations. Using `name:` is **strongly discouraged** as Brick's naming consistency is reliable and easily managed through migrations.

```dart
@Sqlite(name: "full_name")
final String lastName;
```

## Unsupported Field Types

The following are not serialized to SQLite. However, unsupported types can still be accessed in the model as non-final fields.

* Nested `List<>` e.g. `<List<List<int>>>`
* Many-to-many associations

## Testing

Responses can be stubbed from a SqliteProvider with actual data using `StubSqlite`:

```dart
import 'package:brick_sqlite/testing.dart';
import 'package:my_app/app/repository.dart';

void main() {
  group("MySqliteProvider", () {
    setUpAll(() {
      StubSqlite(MyRepository().sqliteProvider, responses: {
        MyModel: [
          {'name': 'Thomas' }
          {'name': 'John' }
        ],
      });
    });
  });
}
```

If a model has an association via a primary key, the association must be manually made with the responses:

```dart
StubSqlite(MyRepository().sqliteProvider, responses: {
  User: [
    {
      'name': 'Thomas',
      // for clarity's sake, the table names are directly used here, but
      // they should always be accessed via adapters:
      // MyRepository().sqliteProvider.modelDictionary.adapterFor[User]
      InsertForeignKey.foreignKeyColumnName('User', 'Hat', foreignKeyColumn: 'hat'): 8
    },
  ],
  Hat: [
    {
      InsertTable.PRIMARY_KEY_COLUMN: 8,
      'color': Color.brown.index,
    }
  ],
});
```

:warning: Stubbed data does not support `Query#where` or `Query#param` like native Sqlite. Stubbing should be employed in simple use cases such as simple association lookups or generating models (e.g. for testing a computed getter).

## FAQ

### Can I specify a different table name?

Table names, association column names, and primary key column names are managed by the package. They are currently unchangeable.

# Memory Cache Provider

The Memory Cache Provider is a key-value store that functions based on the SQLite primary keys to optimize the SQLite provider queries. This is especially effective for low-level associations. The provider only caches models it's aware of:

```dart
// app models: `User`, `Hat`
MemoryCacheProvider([Hat])
// `User` is never stored in memory
```

It is not recommended to use this provider with parent models that have child associations, as those children may be updated in the future without notifying the parent.

## FAQ

### Why can't I declare a model argument?

Due to [an open analyzer bug](https://github.com/dart-lang/sdk/issues/38309), a custom model cannot be passed to the repository as a type argument.
