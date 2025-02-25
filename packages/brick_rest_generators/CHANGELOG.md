## 4.0.0

- Dart minimum SDK is updated to `3.4.0`
- All dependency restrictions are updated to include the minimum released version.
- Update `analyzer` constraint to `>=6.11.0 <7.0.0`

## 3.3.1

- Upgrade `brick_core` to `1.4.0`

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

- Update reference from `brick_rest/rest.dart` to `brick_rest/brick_rest.dart`
- Update minimum `analyzer` constraint to `5.0.0`
- Use Dart 2.15's `.byName` accessor for iterable enum values

## 2.1.1

- Remove `FallThroughError` after Dart beta deprecation

## 2.1.0

- Loosen dependency restrictions to major versions
- Upgrade analyzer to version 4

## 2.0.0

- Separate JSON generators to their own package in `brick_json_generators`

## 2.0.0-rc.2

- Include `1.3.0` updates

## 2.0.0-rc.1

- Prepare for 2.0.0 launch

## 1.3.0+1

- Fix FieldRename enums deserialization to use new Analyzer API

## 1.3.0

- Upgrade `analyzer` dependency to `3.2.0`

## 1.2.0

- Separate logic into more agnostic classes `JsonSerdesGenerator`, `JsonDeserialize` and `JsonSerialize`.

## 1.1.0

- Upgrade `brick_build` and `brick_core`

## 1.0.2

- Prefer constructor field type (including nullability) over field definition for type inference in adapter generation.
- Bump `brick_build`

## 1.0.1

- Add Dart Lints
- Bump `brick_build`
- Always cast from list when deserializing siblings

## 1.0.0+4

- Fix deserialize and serialize `enumAsString` for non-nullable types (#183)

## 1.0.0+3

- Fix pubspec dependencies

## 1.0.0+2

- Fix nullable analyzer errors around DateTime and enum (de)serialization and association serialization

## 1.0.0+1

- Remove `source_gen_test` dependency

## 1.0.0

- Null safety

## 0.0.1

- Fix a a JSON encode error in REST serialization. `.map` returns a `MappedListIterable` which `jsonEncode` cannot parse. It can parse `List<dynamic>`.
- Fix REST's iterable enum serialization
- #58 fixes sibling serialization when null
- Dart style: prefer collection literals
