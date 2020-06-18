## Unreleased

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
