## 4.0.0

- Dart minimum SDK is updated to `3.4.0`
- All dependency restrictions are updated to include the minimum released version.
- `analyzer` constraint is now `>=6.11.0 <7.0.0`

## 3.2.0

- (test) remove analysis options override for non-standard library prefixes
- Revert `.getDisplayString()` change due to Flutter 3.22 being restricted to analyzer <6.4.1. `meta` is pinned to `1.12` in this version of Flutter, and `analyzer >=6.5.0`, where the change was made, requires `meta >= 1.15`. This change will eventually be re-reverted.
- Upgrade `brick_core` to `1.4.0`
- Update analysis to modern lints
- Remove redundant nullability checks for enums, siblings and iterable siblings

## 3.1.1

- Apply standardized lints
- Update `analyzer` constraints to `>=6.0.0 <7.0.0`
- Format CHANGELOG.md

## 3.0.2

- Ensure deserializing string-based enums iterate on an array of strings (#345)

## 3.0.1

- Support Dart 3

## 3.0.0

- Update minimum `analyzer` constraint to `5.0.0`
- Use Dart 2.15's `.byName` accessor for iterable enum values

## 1.1.1

- Respect enum `from<Provider>` constructors and `to<Provider>` methods

## 1.1.0

- Upgrade analyzer to version 4

## 1.0.3

- Do not auto assign values for nullable iterables when deserializing

## 1.0.2

- Loosen dependency restrictions to major versions
- Check for nullability before deserializing single associations

## 1.0.1

- If `.fromJson` is defined on a field's class, the field will be recognized in the adapter and `.fromJson` will be used when deserializing.
- If `#toJson` is defined on a field's class, the field will be recognized in the adapter and `#toJson` will be used when serializing.

## 1.0.0

- Separate `brick_json_generators` to its own package from `brick_rest_generators`
