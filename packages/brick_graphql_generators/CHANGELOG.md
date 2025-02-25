## 4.0.0

- Dart minimum SDK is updated to `3.4.0`
- All dependency restrictions are updated to include the minimum released version.
- Update `analyzer` constraint to `>=6.11.0 <7.0.0`

## 3.3.1

- Upgrade `brick_core` to `1.4.0`
- Upgrade `brick_build` to `3.3.1`
- Ignore `Graphql#nullable`

## 3.3.0

- Upgrade `brick_core` to `1.3.0`
- Update analysis to modern lints

## 3.2.1

- Use `renameField` from `brick_build`'s `AnnotationFinderWithFieldRename` mixin
- Standardize `_finalTypeForField` to `SharedChecker#withoutNullResultType`

## 3.2.0

- Update `analyzer` constraints to `>=6.0.0 <7.0.0`
- Format CHANGELOG.md

## 3.1.0

- Apply standardized lints
- Upgrade minimum Dart to 2.18

## 3.0.1

- Support Dart 3

## 3.0.0

- Update dependency import paths
- Update minimum `analyzer` constraint to `5.0.0`

## 2.0.1

- Remove `FallThroughError` after Dart beta deprecation

## 2.0.0

- Breaking Change upgrade to support `brick_graphql` v2. Please [review the migration guide](https://github.com/GetDutchie/brick/blob/main/packages/brick_graphql/CHANGELOG.md#200).

## 1.4.0

- Upgrade analyzer to version 4

## 1.3.0

- Generate `RuntimeGraphqlDefinitions#subfields` as `Map<String, Map<String, dynamic>>` to support nested properties of JSON-encoded fields.

## 1.2.2

- Abstract the logic for `GraphqlSerialize#instanceFieldsAndMethods` to be populated by overrideable method `generateGraphqlDefinition`
- Remove ignored fields from `fieldsToGraphqlRuntimeDefinition` if they are `@Graphql(ignore:)`

## 1.2.1

- Generate `subfields` from the return type `toJson` methods
- Strip arg type arguments from `toJson` return types to maintain support for Dart <2.15

## 1.2.0

- Loosen dependency restrictions to major versions
- Support `fromJson` and `toJson` methods

## 1.1.0

- Stable release

## 1.0.3

- Use `brick_json_generators` instead of `brick_rest_generators`

## 1.0.2

- Upgrade Analyzer to 3.2.0
- Revise `FieldRename` enum discovery to use Analyzer's new API

## 1.0.1

- Loosen restriction for `brick_build`

## 1.0.0+1

- Use `brick_graphql` from pub
