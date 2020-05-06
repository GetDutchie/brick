## Unreleased

* Type arguments are stripped from fields when building the `fieldsToSqliteColumns` definition (#31)
* Fixes a bug where sets were not serialized by SQLite
* Single siblings are upserted to SQLite as they're received; previously only iterable siblings were upserted
