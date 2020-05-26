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

## Multiplatform Support

Brick SQLite can be used when developing for Windows, MacOS, and Linux platforms. **The following is not required for iOS and Android development except in a test environment.**.

1. Add sqflite_common packages to your pubspec. If you're stubbing SQLite responses for testing, the packages only need to be added under `dev_dependencies:`.
    ```yaml
    sqflite_common: any
    sqflite_common_ffi: any
    ```

1. Use the [SQLite FFI](https://github.com/tekartik/sqflite/tree/master/sqflite_common_ffi) database factory when initializing your provider:
    ```dart
    import 'package:sqflite_common/sqlite_api.dart';
    import 'package:sqflite_common_ffi/sqflite_ffi.dart';

    MyRepository(
      sqliteProvider: SqliteProvider(
        inMemoryDatabase,
        databaseFactory: databaseFactoryFfi,
      ),
    );
    ```

1. Make sure FFI is initialized when starting your app or running unit tests:
    ```dart
    void main() {
      sqfliteFfiInit();
      runApp(MyApp())
    }
    ```

## Testing

SQLite providers should use sqlite_ffi as described in [multiplatform support](#multiplatform-support):

```dart
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  ft.TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  final provider = SqliteProvider(
    inMemoryDatabasePath,
    databaseFactory: databaseFactoryFfi,
    modelDictionary: dictionary,
  );

  setUpAll(() async {
    await provider.migrate(myMigrations);
    // upsert any expected data
    await provider.upsert<DemoModel>(DemoModel('Guy'));
  });
}
```

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
