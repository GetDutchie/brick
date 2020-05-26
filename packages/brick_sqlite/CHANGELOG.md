## Unreleased

## 0.0.7

* Add `StubSqlite.queryValueForColumn` to discover the passed argument for a specific column
* Support OR clauses in `StubSqlite`. This publicly exposes `StubSqlite.queryMatchesResponse`.
* Bump `synchronized` and `sqflite` packages to support `reentrant` locks
* #52 Support multiplatform with `sqlite_ffi`
* **BREAKING CHANGE** Remove `StubSqlite`. `sqlite_ffi` is an in-memory instance of SQLite that can be used in unit test environments. `StubSqlite` can introduce edge cases not consistent with a real-world SQLite instance.

## 0.0.6

* Field names should always be used instead of column names in `Query#providerArgs:`
* Boolean responses from `StubSqlite` are converted to 1 and 0. `QuerySqlTransformer` converts input boolean values in queries to 1 or 0 to ensure they're serialized and compared properly in SQLite; this change ensures the other end performs the same conversion
* Add test coverage for `StubSqlite`
* Fixes an edge case in the `QuerySqlTransformer` where overlapping field names were replaced multiple times by the `fieldsToColumns` map, resulting in an improper column names

## 0.0.5

* Rename `Query#params` to `Query#providerArgs`, reflecting the much narrower purpose of the member

## 0.0.2

* Fix linter hints
