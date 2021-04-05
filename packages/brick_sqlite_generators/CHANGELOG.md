## Unreleased

## 1.0.0+1

* Loosen `brick_build` pubspec restriction

## 1.0.0

* Null safety

## 0.0.1

* Fix sibling set serialization
* Do not create joins tables for ignored fields
* Type arguments are stripped from fields when building the `fieldsToSqliteColumns` definition (#31)
* Fixes a bug where sets were not serialized by SQLite
* Single siblings are upserted to SQLite as they're received; previously only iterable siblings were upserted
* Fix deserializing for null sibling arrays
* Booleans are serialized as 1s or 0s
* Foreign keys are no longer serialized in a JSON array and stored as a string
* Support `columnType` from SQLite annotations
* Reconcile changes for non-final associations (#112)
