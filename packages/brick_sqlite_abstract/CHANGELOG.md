## Unreleased

* When defining the migration for `InsertForeignKey`, `onDeleteCascade` can be set to determine whether the deletion of the record will delete all referencing children records. Defaults `false`.

## 0.0.4

* `Sqlite#defaultValue` updated to reflect `FieldSerializable#defaultValue` change

## 0.0.2

* Use single quotes when generating `Migration#version` to comply with default analyzer options
* Fix linter hints

## 0.0.1+1

* SqliteModel moved to this package from `brick_offline_first_abstract`
