## 4.0.0

- **BREAKING CHANGE** `brick_offline_first_with_rest_build/builder.dart` has been renamed to `brick_offline_first_with_rest_build/brick_offline_first_with_rest_build.dart`. This will only affect implementations that have overridden `build.yaml`.
- Dart minimum SDK is updated to `3.4.0`
- All dependency restrictions are updated to include the minimum released version.

## 3.2.0

- (test) remove analysis options override for non-standard library prefixes
- Apply minimum constraint on `brick_offline_first_build` to `3.2.0`
- Upgrade `brick_core` to `1.3.0`
- Apply standardized lints
- Update `analyzer` constraints to `>=6.0.0 <7.0.0`
- Format CHANGELOG.md

## 3.1.0

- _Soft breaking change_: Rename `build.yaml` builder keys from camelCase to snake_case (e.g. `brickAggregateBuilder` becomes `brick_aggregate_builder`). This shouldn't affect implementations because these builders do not support configuration, but some implementations may use `runs_before`. For these implementations, please rename all configured builders from this package.
- Update `build.yaml` to support Dart 3 (#343 #344)
- Add `brick_new_migration_builder` (separated from `brick_schema_builder`)

## 3.0.1

- Support Dart 3

## 3.0.0

- Remove `brick_sqlite_abstract`; import `brick_sqlite` directly
- Remove `brick_offline_first_abstract` depedency
- Remove `brick_offline_first_with_rest_abstract` depedency
- Update references to renamed v3 files like `brick_rest/brick_rest.dart`

## 2.1.1

- Merge `brickSchemaBuilder` into `brickNewMigrationBuilder` and rename to `brickSchemaBuilder` to ensure the schema is compiled before the migration. `runs_before` was not working, perhaps because of [the combination](https://github.com/dart-lang/build/blob/85900b19ee186d133b41e957fd60836282b45d7c/docs/builder_author_faq.md#why-cant-my-builder-resolve-code-output-by-another-builder) with `combining_builder`

## 2.1.0

- Upgrade analyzer to version 4

## 2.0.1+1

- Fix migration and model discovery

## 2.0.1

- Permit using `part` and `part of` files outside of models

## 2.0.0

- Loosen dependency restrictions to major versions
- Update brick packages to 2.0.0

## 1.3.0

- Upgrade `analyzer` dependency to `3.2.0`
- Bump `brick_rest_generators` and `brick_sqlite_generators` to `1.3.0`
- Bump `brick_offline_first_build` to `1.1.0`

## 1.2.0

- Remove unnecessary import in `brick.g.dart`
- Upgrade `brick_build`, `brick_rest_generators`, `brick_sqlite_generators`, `brick_sqlite_abstract`

## 1.1.4

- Always use `whereType<T>` casts after awaiting `Future.wait()` in Rest deserializing adapters.
- Bump `brick_build`

## 1.1.3

- Bump `brick_sqlite_generators`

## 1.1.2

- Prefer constructor field type (including nullability) over field definition for type inference in adapter generation.
- **BREAKING CHANGE**: Remove support for nullable futures as the outer-most type (eg brick now reads `Future<String?>?` as `Future<String?>`, but `List<Future<String?>?>?` remains valid).
- Bump `brick_build`
- Bump `brick_rest_generators`

## 1.1.1

- Always cast when deserializing `OfflineFirstSerdes` from SQLite
- Always cast when deserializing `OfflineFirstSerdes` from REST
- Use null aware operators when deserializing `OfflineFirstSerdes` iterables from REST

## 1.1.0

- Add Dart Lints
- Update to use new `brick_build` API for `getAssociationMethod` and `repositoryHasBeenForceCast`
- Fix Dart null safety complaints when accessing repository in a subsequent null or non null safe way after a force cast to non-null.

## 1.0.0+2

- Fix null safety for one-to-one REST serializing associations (#186)

## 1.0.0+1

- Remove `source_gen_test` and `glob` dependencies

## 1.0.0

- Null safety

## 0.0.1

- Fix a a JSON encode error. `.map` returns a `MappedListIterable` which `jsonEncode` cannot parse. It can parse `List<dynamic>`.
