![brick_sqlite_abstract workflow](https://github.com/greenbits/brick/actions/workflows/brick_sqlite_abstract.yaml/badge.svg)

# Brick SQLite Abstract

Adding class- and field-level configuration to the [SQLite provider](https://github.com/greenbits/brick/tree/master/packages/brick_sqlite).

## FAQ

### Why isn't this package part of [brick_sqlite](https://github.com/greenbits/brick/tree/master/packages/brick_sqlite)?

[brick_build](https://github.com/greenbits/brick/tree/master/packages/brick_build) uses `dart:mirrors` to determine field types and class makeup. Flutter cannot use `dart:mirrors`. [brick_sqlite](https://github.com/greenbits/brick/tree/master/packages/brick_sqlite) relies on Flutter. Therefore, to use annotations for SQLite (annotations provide serdes information in generated code), this package has to be separated so that brick_build does not import brick_sqlite.
