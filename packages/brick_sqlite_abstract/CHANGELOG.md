## Unreleased

* Add Dart Lints

## 1.0.0+3

* Fixes migration generation error that included `null` when an `up` migration did not have a `down` generator.

## 1.0.0+1

* Null safety cleanup and refactor
* Fixes foreign key column bug introduced in 1.0.0: explicitly declared column names are no longer regenerated

## 1.0.0

* Null safety

## 0.1.0

* Declare a custom `columnType` with `@Sqlite`. Because this feature overrides Brick assumptions about the column type, the field will be inserted (toSqlite) **as is** and returned **as is** from deserialization (fromSqlite).
* **BREAKING CHANGE** Positional argument `type`is no longer accepted when initializing `SchemaColumn`. The type was converted to a SQLite column type and rendered as the SQLite type in generators. Instead, explicitly define the `columnType` to use, such as `Column.integer`. For existing implementations, `SchemaColumn` should only be declared in generated `schema.g.dart` files. If the schema has not been committed to VCS (as recommended), no update steps will be necessary. Migrations remain unaffected.

## 0.0.9+1

* Escape tables created with reserved names in the index statement. For example: `CREATE INDEX IF NOT EXISTS index_Group_on_id \`Group\`(\`id\`)`

## 0.0.9

* Remove `Migration.wrapInTransaction` static method. This was a misleading and unused method.
* Add `index:` option in `@Sqlite` for creating an index on a column.

## 0.0.8+1

* Add a `DropIndex` command to revert `CreateIndex` changes
* Detect `CreateIndex` changes and generate a migration

## 0.0.8

* When joins tables are created, add a unique index by both columns to ensure no duplicates are inserted. Prior applications will need to manually specify `CreateIndex` in a custom migration for existing joins tables. When new joins tables are generated in migrations, `CreateIndex` will also be generated.

## 0.0.7+4

* Fix a bug where a many-to-many association shared the same class name

## 0.0.7+2, 0.0.7+3

* Define `onDeleteSetDefault` on the field annotation. This 1) generates a new migration and 2) allows the schema to regenerate from user preferences instead of strictly historic migrations.

## 0.0.7+1

* Define `onDeleteCascade` on the field annotation. This 1) generates a new migration and 2) allows the schema to regenerate from user preferences instead of strictly historic migrations.

## 0.0.7

* When defining the migration for `InsertForeignKey`, `onDeleteCascade` can be set to determine whether the deletion of the record will delete all referencing children records. Defaults `false`.

## 0.0.4

* `Sqlite#defaultValue` updated to reflect `FieldSerializable#defaultValue` change

## 0.0.2

* Use single quotes when generating `Migration#version` to comply with default analyzer options
* Fix linter hints

## 0.0.1+1

* SqliteModel moved to this package from `brick_offline_first_abstract`
