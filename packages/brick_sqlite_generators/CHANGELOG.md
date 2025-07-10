## 4.0.1

- Fix: `@Sqlite(enumAsString:)` generates a varchar column instead of an integer

## 4.0.0

- Dart minimum SDK is updated to `3.4.0`
- All dependency restrictions are updated to include the minimum released version.
- Update `analyzer` constraint to `>=6.11.0 <7.0.0`

## 3.3.1

- Fix: nullable maps are not cast to a default value on serialization (#531)

## 3.3.0

- Upgrade `brick_core` to `1.3.0`
- Update analysis to modern lints

## 3.2.2

- Revert `.getDisplayString()` change due to Flutter 3.22 being restricted to analyzer <6.4.1. `meta` is pinned to `1.12` in this version of Flutter, and `analyzer >=6.5.0`, where the change was made, requires `meta >= 1.15`. This change will eventually be re-reverted.

## 3.2.1

- Use `SharedChecker.withoutNullability` instead of stripping null suffixes manually
- Standardize `_finalTypeForField` to `SharedChecker#withoutNullResultType`
- (test) remove analysis options override for non-standard library prefixes

## 3.2.0

- Update `analyzer` constraints to `>=6.0.0 <7.0.0`
- Format CHANGELOG.md

## 3.1.0

- Apply standardized lints
- Upgrade minimum Dart to 2.18
- Add `SqliteSerialize#uniqueValueForField` for advanced control of unique field genertion

## 3.0.2

- Fix discovery path for injecting new migration `part` into schema from legacy `brick_sqlite_abstract` to `brick_sqlite/db`

## 3.0.1

- Support Dart 3

## 3.0.0

- Replace `brick_sqlite_abstract/db.dart` with `brick_sqlite/db.dart`
- Remove `brick_sqlite_abstract` dependency
- Update minimum `analyzer` constraint to `5.0.0`

## 2.4.1

- Update replacement RegEx for `migrations =` and `schema =` to account for whitespace and removed type names

## 2.2.0

- If a field is annotated `@Sqlite(ignore: true)` do not create a column for it.

## 2.1.4

- Remove `FallThroughError` after Dart beta deprecation

## 2.1.3

- Respect enum `fromSqlite` constructors and `toSqlite` methods

## 2.1.2

- Upgrade analyzer to version 4

## 2.1.1

- Return `null` for nullable iterable fields instead of defaulting to an empty list or set

## 2.1.0

- When updating associations from a parent, remove the association in the joins table but do not delete the instance. **This now applies to final fields as well**. (modifies addition from #119)
- Respect declared non-nullability for Dart-primitive `Set`s when serializing

## 2.0.3

- Fix serializing iterable `toJson` classes to SQLite
- Fix migration generation for iterable `toJson` classes

## 2.0.2

- Loosen dependency restrictions to major versions
- Remove type from `Map` on `toJson` fields

## 2.0.1

- If `.fromJson` is defined on a field's class, the field will be recognized in the adapter and `.fromJson` will be used when deserializing.
- If `#toJson` is defined on a field's class, the field will be recognized in the adapter and `#toJson` will be used when serializing. The column created to hold the field's value will be a varchar.

## 2.0.0

- Use `brick_build`s new `manuallyUpsertBrickFile` method instead of `manuallyUpsertAppFile`

## 2.0.0-rc.3

- Include `1.3.0` changes

## 2.0.0-rc.2

- Use `brick_build`s new `manuallyUpsertBrickFile` method instead of `manuallyUpsertAppFile`

## 2.0.0-rc.1

- Expose `SqliteSerdesGenerator` in `generators.dart`
- Upgrade `analyzer` dependency to `3.2.0`
- Update enum discovery from `ConstantReader` to utilize new Analyzer methods (index instead of string)

## 1.3.0

- Expose `SqliteSerdesGenerator` in `generators.dart`
- Upgrade `analyzer` dependency to `3.2.0`
- Update enum discovery from `ConstantReader` to utilize new Analyzer methods (index instead of string)

## 1.2.0

- Supports `ignoreFrom`, `ignoreTo`, and `enumAsString`

## 1.1.4

- Fix casting when deserializing enums. The analyzer does not alert for `cast` on a list that could contain nullable values; if the field type is non-nullable, null types must be removed before the cast.
- Remove unnecessary import in `schema.g.dart`

## 1.1.3

- Bump `brick_build`
- Explicitely override `checkerForField` function in order to have SQLite maintain member field typing as it's source of truth over any constructor definitions

## 1.1.2

- Always cast when using `toList` and deserializing

## 1.1.1+1

- Fix adapter when deserializing single siblings

## 1.1.1

- Update to use new `brick_build` API for `getAssociationMethod` and `repositoryHasBeenForceCast`

## 1.1.0+1

- Apply `const` for individual migrations in `schema.g.dart`

## 1.1.0

- Fix analyzer's nullable warning when serializing non-final iterables (#185)
- Expose `SqliteSchemaGenerator#schemaColumn` for calling super in sub classes
- Prepend `const` before `RuntimeSqliteColumnDefinition`
- Use `const` when declaring migrations at the top of `schema.g.dart`
- Add Dart Lints

## 1.0.0+5

- Fix nullable warning when serializing non-nullable maps (#187)

## 1.0.0+4

- Fix pubspec dependencies

## 1.0.0+3

- Fix deserialization for associations, enum, and DateTime in Dart >=2.12
- Fix serialization for associations, afterSave, enum, core types, booleans, and DateTime in Dart >=2.12

## 1.0.0+2

- Remove `source_gen_test` dependency

## 1.0.0+1

- Loosen `brick_build` pubspec restriction

## 1.0.0

- Null safety

## 0.0.1

- Fix sibling set serialization
- Do not create joins tables for ignored fields
- Type arguments are stripped from fields when building the `fieldsToSqliteColumns` definition (#31)
- Fixes a bug where sets were not serialized by SQLite
- Single siblings are upserted to SQLite as they're received; previously only iterable siblings were upserted
- Fix deserializing for null sibling arrays
- Booleans are serialized as 1s or 0s
- Foreign keys are no longer serialized in a JSON array and stored as a string
- Support `columnType` from SQLite annotations
- Reconcile changes for non-final associations (#112)
