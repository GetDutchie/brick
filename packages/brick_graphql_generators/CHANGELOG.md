## Unreleased

* Apply standardized lints

## 3.0.1

* Support Dart 3

## 3.0.0

* Update dependency import paths
* Update minimum `analyzer` constraint to `5.0.0`

## 2.0.1

* Remove `FallThroughError` after Dart beta deprecation

## 2.0.0

* Breaking Change upgrade to support `brick_graphql` v2. Please [review the migration guide](https://github.com/GetDutchie/brick/blob/main/packages/brick_graphql/CHANGELOG.md#200).

## 1.4.0

* Upgrade analyzer to version 4

## 1.3.0

* Generate `RuntimeGraphqlDefinitions#subfields` as `Map<String, Map<String, dynamic>>` to support nested properties of JSON-encoded fields.

## 1.2.2

* Abstract the logic for `GraphqlSerialize#instanceFieldsAndMethods` to be populated by overrideable method `generateGraphqlDefinition`
* Remove ignored fields from `fieldsToGraphqlRuntimeDefinition` if they are `@Graphql(ignore:)`

## 1.2.1

* Generate `subfields` from the return type `toJson` methods
* Strip arg type arguments from `toJson` return types to maintain support for Dart <2.15

## 1.2.0

* Loosen dependency restrictions to major versions
* Support `fromJson` and `toJson` methods

## 1.1.0

* Stable release

## 1.0.3

* Use `brick_json_generators` instead of `brick_rest_generators`

## 1.0.2

* Upgrade Analyzer to 3.2.0
* Revise `FieldRename` enum discovery to use Analyzer's new API

## 1.0.1

* Loosen restriction for `brick_build`

## 1.0.0+1

* Use `brick_graphql` from pub
