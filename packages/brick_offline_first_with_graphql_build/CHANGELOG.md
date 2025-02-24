## 4.0.0

- **BREAKING CHANGE** `brick_offline_first_with_graphql_build/builder.dart` has been renamed to `brick_offline_first_with_graphql_build/brick_offline_first_with_graphql_build.dart`. This will only affect implementations that have overridden `build.yaml`.
- Dart minimum SDK is updated to `3.4.0`
- All dependency restrictions are updated to include the minimum released version.
- Update `analyzer` constraint to `>=6.11.0 <7.0.0`
- (test) remove analysis options override for non-standard library prefixes
- Apply minimum constraint on `brick_offline_first_build` to `3.2.0`
- Update analysis to modern lints

## 3.3.0

- Update `analyzer` constraints to `>=6.0.0 <7.0.0`
- Format CHANGELOG.md

## 3.2.0

- Apply standardized lints
- Upgrade minimum Dart to 2.18

## 3.1.0

- _Soft breaking change_: Rename `build.yaml` builder keys from camelCase to snake_case (e.g. `brickAggregateBuilder` becomes `brick_aggregate_builder`). This shouldn't affect implementations because these builders do not support configuration, but some implementations may use `runs_before`. For these implementations, please rename all configured builders from this package.
- Update `build.yaml` to support Dart 3 (#343 #344)
- Add `brick_new_migration_builder` (separated from `brick_schema_builder`)

## 3.0.1

- Support Dart 3

## 3.0.0

- Remove `brick_sqlite_abstract` dependency
- Remove `brick_offline_first_abstract` dependency
- Remove `brick_offline_first_with_graphql_abstract` dependency
- Update import paths

## 1.3.1

- Merge `brickSchemaBuilder` into `brickNewMigrationBuilder` and rename to `brickSchemaBuilder` to ensure the schema is compiled before the migration. `runs_before` was not working, perhaps because of [the combination](https://github.com/dart-lang/build/blob/85900b19ee186d133b41e957fd60836282b45d7c/docs/builder_author_faq.md#why-cant-my-builder-resolve-code-output-by-another-builder) with `combining_builder`

## 1.3.0

- Upgrade analyzer to version 4
- Generate `RuntimeGraphqlDefinitions#subfields` as `Map<String, Map<String, dynamic>>` to support nested properties of JSON-encoded fields.
- Apply `@OfflineFirst(where:)` params to GraphQL document configuration. Note that the current implementation ignores multiple `where` properties (`OfflineFirst(where: {'id': 'data["id"]', 'otherVar': 'data["otherVar"]'})`) and nested values (`OfflineFirst(where: {'id': 'data["subfield"]["id"]})`).
- Support `brick_graphql` v2

## 1.2.0+1

- Fix migration and model discovery

## 1.2.0

- Permit using `part` and `part of` files outside of models

## 1.1.1

- Loosen dependency restrictions to major versions

## 1.1.0

- Stable release

## 1.0.2

- Enforce `brick_build` version `2.0.0-rc.2`

## 1.0.1

- Support `brick_offline_first_with_graphql_abstract`
