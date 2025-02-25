## 4.0.0

- Dart minimum SDK is updated to `3.4.0`
- All dependency restrictions are updated to include the minimum released version.
- Update `analyzer` constraint to `>=6.11.0 <7.0.0`

## 3.3.0

- Upgrade `brick_core` to `1.3.0`
- Update analysis to modern lints

## 3.2.1

- (test) remove analysis options override for non-standard library prefixes
- Revert `.getDisplayString()` change due to Flutter 3.22 being restricted to analyzer <6.4.1. `meta` is pinned to `1.12` in this version of Flutter, and `analyzer >=6.5.0`, where the change was made, requires `meta >= 1.15`. This change will eventually be re-reverted.

## 3.2.0

- Update `analyzer` constraints to `>=6.0.0 <7.0.0`
- Format CHANGELOG.md

## 3.1.0

- Apply standardized lints
- Support using `OfflineFirstSerdes` as a unique field in SQLite

## 3.0.1

- Support Dart 3

## 3.0.0

- Remove `brick_sqlite_abstract`
- Remove `brick_offline_first_abstract`
- Update imports from `_abstract` packages
- Support `applyToRemoteDeserialization` and `fieldsToOfflineFirstRuntimeDefinition`
- Update minimum `analyzer` constraint to `5.0.0`

## 2.1.1

- Respect enum `from<Provider>` constructors and `to<Provider>` methods

## 2.1.0

- Upgrade analyzer to version 4

## 2.0.1

- Import `DatabaseExecutor` from `sqflite_common` instead of `sqflite` to avoid the Flutter dependency
- Loosen dependency restrictions to major versions

## 2.0.0

- Include release candidates of build dependencies

## 1.1.0

- Upgrade `analyzer` dependency to `3.2.0`
- Bump `brick_rest_generators` and `brick_sqlite_generators` to `1.3.0`

## 1.0.1

- Loosen pubspec restrictions

## 1.0.0+2

- Permit v1 and v2 of `brick_offline_first_abstract`

## 1.0.0+1

- Add JSON generators and `brick_rest_generators` dependency

## 1.0.0

- Initial
