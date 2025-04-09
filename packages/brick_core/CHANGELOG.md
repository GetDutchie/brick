- Add additional API documentation discouraging `SingleProviderRepository` usage in practical implementations.

## 2.0.0

- **BREAKING CHANGE** `Query(providerArgs:)` is no longer accepted. See [1.3.0](#1.3.0) for migration steps.
- **BREAKING CHANGE** `Query#copyWith` no longer accepts `providerArgs`. See [1.3.0](#1.3.0) for migration steps.
- **BREAKING CHANGE** `FieldSerializable#nullable` is removed. See [1.4.0](#1.4.0) for migration steps.
- Dart minimum SDK is updated to `3.4.0`

## 1.4.0

- **DEPRECATION** remove `FieldSerializable#nullable`. Builders should evaluate the nullable suffix of the field instead

## 1.3.1

- `const`antize `Where.exactly` and `OrderBy.{desc|asc}`
- Add deprecation annotation to `Query#copyWith#providerArgs`

## 1.3.0

- **DEPRECATION** `Query(providerArgs: {'limit':})` is now `Query(limit:)` #510
- **DEPRECATION** `Query(providerArgs: {'offset':})` is now `Query(offset:)` #510
- **DEPRECATION** `Query(providerArgs: {'orderBy':})` is now `Query(orderBy:)`. `orderBy` is now defined by a class that permits multiple commands. For example, `'orderBy': 'name ASC'` becomes `[OrderBy('name', ascending: true)]`. #510
- **DEPRECATION** `providerArgs` will be removed in the next major release #510
- `OrderBy` will support association ordering and multiple values
- `Query` is constructed with `const`
- `Query#offset` no longer requires companion `limit` parameter

## 1.2.1

- Add `FieldRename` to `FieldSerializable`

## 1.2.0

- Apply standardized lints
- Upgrade minimum Dart to 2.18

## 1.1.2

- Support Dart 3
- Loosen dependency restrictions to major versions

## 1.1.1

- Add `subscribe` to `QueryAction`

## 1.1.0

- Add Dart lints
- Add `enumAsString`

## 1.0.0+1

- Null safety cleanup and refactor

## 1.0.0

- Null safety
- **BREAKING CHANGE**: because `required` is now a first-class Dart keyword, `required` in `WherePhrase`, `WhereCondition`, `And`, `Or`, and `Where` has been renamed to `isRequired`.
- Add optional method `Provider#exists`. Whether a model instance is present. `null` is returned when existence is unknown. The model instance is not hydrated in the function output; a `bool` variant (e.g. `List<bool>`, `Map<_Model, bool>`) should be returned.

## 0.0.6

- Add a `doesNotContain` enum to `Compare` for `Where` queries

## 0.0.5

- Rename `Query#params` to `Query#providerArgs`, reflecting the much narrower purpose of the member

## 0.0.4

- `FieldSerializable#defaultValue` changes from `dynamic` to `String`. As this is injected directly into the adapter, it does not need to be dynamic and should better reflect its purpose.

## 0.0.3+1

- Moves generator placeholders to `FieldSerializable` form `OfflineFirst`
- Removes query validation that ensures all Where conditions have a non-null value

## 0.0.3

- Add `And` and `Or` `Where` subclasses
- Removes Type argument from `Where`
- Adds semantic methods to `Where` such as `isExactly` and
- **BREAKING** Revise `Where` syntax. This removes the second positional argument in favor of using it in a semantic method.
- Adds `Where.exact` factory to preserve previous, short syntax
- Move query-related files to `src/query` and make them accessible from a barrel file in the lib root

## 0.0.2

- Fix linter hints
- Adds `initialize` method to `ModelRepository`. This is enforces a predictable, overridable method for sub classes
