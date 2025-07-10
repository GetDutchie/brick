## 4.1.0

- Add ability to run migrations `down` by calling `#migrate(down: true)` #594

## 4.0.2

- Fix query statements with mixed non-association and association fields to permit any order (#573)

## 4.0.1

- Fix ambiguous column in association queries with ORDER BY statements (#561)

## 4.0.0

- **BREAKING CHANGE** Require `brick_core: >= 2.0.0` and remove support for `Query(providerArgs:)`; see [migration steps](https://github.com/GetDutchie/brick/issues/510)
- Dart minimum SDK is updated to `3.4.0`
- All dependency restrictions are updated to include the minimum released version.

## 3.2.2

- Fix: nullable maps are not cast to a default value on serialization (#531)

## 3.2.1

- Remove `dart:io` dependency

## 3.2.0

- **DEPRECATION** `Query(providerArgs: {'collate':})` is now `Query(forProviders: [SqliteProviderQuery(collate:)])` #510
- **DEPRECATION** `Query(providerArgs: {'having':})` is now `Query(forProviders: [SqliteProviderQuery(having:)])` #510
- **DEPRECATION** `Query(providerArgs: {'groupBy':})` is now `Query(forProviders: [SqliteProviderQuery(groupBy:)])` #510
- Association ordering is supported. For example, `Query(orderBy: [OrderBy.desc('assoc', associationField: 'name')])` on `DemoModel` will produce the following SQL statement:
  ```sql
  'SELECT DISTINCT `DemoModel`.* FROM `DemoModel` ORDER BY `DemoModelAssoc`.name DESC'
  ```
- New `SqliteProviderQuery` adds Sqlite-specific support for the new `Query`.
- `Column` enum is enhanced, performing the conversion between Dart and SQLite column types on the enum instead of in `Migration`.
- Barrel files are no longer imported to `src/` implementations
- Upgrade `brick_core` to `1.3.0`
- Update analysis to modern lints

## 3.1.1

- Expose a generic type for `MemoryCacheProvider` models
- Expose a generic type for `SqliteProvider` models

## 3.1.0

- Apply standardized lints
- Upgrade minimum Dart to 2.18
- Add extra documentation to the `@Sqlite(unique:)` annotation

## 3.0.1

- Support Dart 3

## 3.0.0

Please follow the [v3 migration guide](https://github.com/GetDutchie/brick/issues/325) to easily upgrade.

- Combine `brick_sqlite_abstract` to this package, adding `db.dart` as an export. This merge also includes `SqliteSerializable` and `SqliteModel`, both now exported by `brick_sqlite/brick_sqlite.dart`
- **BREAKING CHANGE** Rename main export `sqlite.dart` to `brick_sqlite.dart`
- Remove `brick_sqlite_abstract` dependency
- Add `collection` as a direct dependency
- Add `transaction` to `SqliteProvider`
- Update signature for `rawQuery` to mirror Sqflite's signature

## 2.1.0

- Support deeply-nested association querying:
  ```dart
  Where('pizza').isExactly(
    Where('customer').isExactly(
      Where('name', name)
    ),
  )
  // In this example, Car, Pizza, and Customer are all independent Brick models.
  // Car has `final List<Pizza> pizzas`
  // Pizza has `final Person customer`
  // Customer has `final String name`
  ```

## 2.0.1

- Use the table name prefix in SQL queries for identically-named association columns

## 2.0.0

- Loosen dependency restrictions to major versions
- Privatize `SqliteProvider.MIGRATION_VERSIONS_TABLE_NAME` to `_migrationVersionsTableName`
- **BREAKING CHANGE** Use `sqflite_common` instead of `sqflite`, permitting this package to be used without Flutter.

## 1.2.0

- When using a DateTime field with an operator (`ORDER BY`, `HAVING`, `GROUP BY`, etc), wrap the `ORDER BY` queries in `datetime`

## 1.1.0

- Fix edge case where 'ambiguous column name' was thrown on `exists` queries with an association constraint and declared `OFFSET`
- Add Flutter Lints
- Change `instance` and `data` positional arguments in `SqliteAdapter` to `input` to match generator variable

## 1.0.0+1

- Require `provider` in `SqliteAdapter#fromSqlite`, `SqliteAdapter#toSqlite`, `SqliteAdapter#beforeSave`, `SqliteAdapter#afterSave`

## 1.0.0

- Migrate to null safety

## 0.1.7

- Support `columnType` from SQLite annotations
- When deleting many associations from a parent, remove the association in the joins table but do not delete the instance. This is only applicable to non-final instance fields. (#112)
- Support spaces in compound orderBy clauses (i.e. `'orderBy': 'firstField DESC, secondField ASC'` where previously only `'orderBy': 'firstField DESC,secondField ASC'` worked)

## 0.1.6+1

- Fix: when non-SQLite providerArgs are provided in a query, false is no longer returned from `SqliteProvider#exists`

## 0.1.6

- Internal: Change `SqliteAdpater#fieldsToSqliteColumns` type from `Map<String, Map<String, dynamic>>` to `Map<String, RuntimeSqliteColumnDefinition>`. Using such a dynamic type option will lead to inconsistency when accessing the values.
- `SqliteAdapter#primaryKeyByUniqueColumn` will return `instance?.primaryKey` instead of null when no `@Sqlite(unique: true)` fields exist.
- Internal: Refactor organization of files: `SqliteProvider`, `SqliteAdapter`, `SqliteModelDictionary` are separated. `lib/sqlite.dart` is now a barrel file with the same exports.

## 0.1.5+1

- Fix: recreate SQLite DB after reset instead of attempting to open a closed DB

## 0.1.5

- Access SQLite db safely to [avoid race conditions](https://github.com/tekartik/sqflite/blob/master/sqflite/doc/opening_db.md#prevent-database-locked-issue)
- Lint: do not use implicit types

## 0.1.4

- Handle empty conditions when constructing a statement from a `WherePhrase`
- SQL `COUNT(*)` does not work with `OFFSET` clauses; run an inexpensive SELECT query instead in `.exists` to accomodate `OFFSET`

## 0.1.3

- Revise `exists` in SqliteProvider to query with a SQL statement instead of hydrating whole models and associations
- Add `selectStatement` to `QuerySqlTransformer`'s default constructor. When `true,` `statement` will begin `SELECT FROM`; when `false`, `statement` will begin `SELECT COUNT(*)`. Defaults `true`.

## 0.1.2

- When searching with `doesNotContain` apply same fuzzy search `%` that `Compare.contains` enjoys

## 0.1.1

- Bump SQFlite
- Remove `path` as a dependency and rely on SQFlite's default accessors when opening a database
- Mark `SqliteProvider#migrateFromStringToJoinsTable` as deprecated to signal that it should be removed from implementations as soon as possible.
- Support migrations in SQLite >=3.26. 3.26 introduced a [better way to update foreign key associations](https://www.sqlite.org/lang_altertable.html#alter_table_rename) that is accessible in iOS's FMDB. However, since versions prior to [3.26 are used by Android](https://developer.android.com/reference/android/database/sqlite/package-summary), the foreign_keys hack is still necessary to maintain backwards compatibility. Hat tip to this [SO answer](https://stackoverflow.com/questions/4897867/update-foreign-key-references-when-doing-the-sqlite-alter-table-trick#comment98105840_4897867).

## 0.1.0+2

- Ignore when inserting associations

## 0.1.0+1

- Fix SQL query for joins

## 0.1.0

- Add `beforeSave` and `a fterSave` hooks to the `SqliteAdapter`
- **BREAKING CHANGE** One-to-many and many-to-many SQLite associations are no longer stored as JSON-encoded strings (i.e. `[1, 2, 3]` in a varchar column). Join tables are now generated by Brick. To convert existing data, please follow the next steps carefully. If you do not care about existing migration and have not widely distributed your app, simply delete all existing migrations, delete all existing app installs, and run `flutter pub run build_runner build` in your project root.
  1. Run `flutter pub run build_runner build` in your project root.
  1. In the created migration file, remove any `DropColumn` commands from the `up` statements.
  1. Run this **for each DropColumn** after `super.migrate`.
     ```dart
     class MyRepository extends OfflineFirstWithRestRepository {
       @override
       Future<void> migrate() async {
         await super.migrate();
         // TODO update this table with information from the deleted `DropColumn` commands in step 2.
         final joinsTableColumnMigrations = [
           {
             'localTableName': 'User'
             'columnName': 'hats',
             'foreignTableName': 'Hat',
           },
         ];
         for (var entry in joinsTableColumnMigrations) {
           await sqliteProvider.migrateFromStringToJoinsTable(entry['columnName'], entry['localTableName'], entry['foreignTableName']);
         }
       }
     }
     ```
  1. Continue to remove `DropColumn` from generated migrations until you've safely distributed the update.

## 0.0.7

- Add `StubSqlite.queryValueForColumn` to discover the passed argument for a specific column
- Support OR clauses in `StubSqlite`. This publicly exposes `StubSqlite.queryMatchesResponse`.
- Bump `synchronized` and `sqflite` packages to support `reentrant` locks
- #52 Support multiplatform with `sqlite_ffi`
- **BREAKING CHANGE** Remove `StubSqlite`. `sqlite_ffi` is an in-memory instance of SQLite that can be used in unit test environments. `StubSqlite` can introduce edge cases not consistent with a real-world SQLite instance.

## 0.0.6

- Field names should always be used instead of column names in `Query#providerArgs:`
- Boolean responses from `StubSqlite` are converted to 1 and 0. `QuerySqlTransformer` converts input boolean values in queries to 1 or 0 to ensure they're serialized and compared properly in SQLite; this change ensures the other end performs the same conversion
- Add test coverage for `StubSqlite`
- Fixes an edge case in the `QuerySqlTransformer` where overlapping field names were replaced multiple times by the `fieldsToColumns` map, resulting in an improper column names

## 0.0.5

- Rename `Query#params` to `Query#providerArgs`, reflecting the much narrower purpose of the member

## 0.0.2

- Fix linter hints
