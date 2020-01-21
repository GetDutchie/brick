## Unreleased

* Update for new [brick_core](https://github.com/greenbits/brick/tree/master/packages/brick_core) API on `Where`
* Move shareable methods from `OfflineFirstSerdesGenerator` to `SerdesGenerator`
* Constrain version of [brick_core](https://github.com/greenbits/brick/tree/master/packages/brick_core)
* Split code to separate projects: `rest_serdes` to [brick_rest_build](https://github.com/greenbits/brick/tree/master/packages/brick_rest_build), `sqlite_serdes` and subsequent SQLite builders to [brick_sqlite_build](https://github.com/greenbits/brick/tree/master/packages/brick_sqlite_build), and all OfflineFirst-specific logic to [brick_offline_first_with_rest_build](https://github.com/greenbits/brick/tree/master/packages/brick_offline_first_with_rest).
* `testing.dart` is available for useful testing methods
* This package is now a series of utilities and interfaces; it no longer produces generated code.

## 0.0.3

* Use `ConnectOfflineFirstWithRest`

## 0.0.2

* Uses `getDisplayString` instead of deprecated `name`
* Fix linter hints
