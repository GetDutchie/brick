# SQLite Provider

## Intelligent Migrations

Whenever a new field(s) is added or removed from a connected model, Brick can automatically generate a migration for SQLite. For even less friction, running the watcher while actively developing will create the migration on model save:

```bash
flutter pub run build_runner watch
```

?> While Brick guesses right most of the time, the migration should still be reviewed after it's created (for example, a `DropTable` might just be a `RenameTable` or maybe `onDeleteCascade` needs to be set for a `InsertForeignKey`).

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

## FAQ

### Can I specify a different table name?

Table names, association column names, and primary key column names are managed by the package. They are currently unchangeable.
