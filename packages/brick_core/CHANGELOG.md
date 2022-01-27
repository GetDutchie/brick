## Unreleased

* Add `subscribe` to `QueryAction`

## 1.1.0

* Add Dart lints
* Add `enumAsString`

## 1.0.0+1

* Null safety cleanup and refactor

## 1.0.0

* Null safety
* **BREAKING CHANGE**: because `required` is now a first-class Dart keyword, `required` in `WherePhrase`, `WhereCondition`, `And`, `Or`, and `Where` has been renamed to `isRequired`.
* Add optional method `Provider#exists`. Whether a model instance is present. `null` is returned when existence is unknown. The model instance is not hydrated in the function output; a `bool` variant (e.g. `List<bool>`, `Map<_Model, bool>`) should be returned.

## 0.0.6

* Add a `doesNotContain` enum to `Compare` for `Where` queries

## 0.0.5

* Rename `Query#params` to `Query#providerArgs`, reflecting the much narrower purpose of the member

## 0.0.4

* `FieldSerializable#defaultValue` changes from `dynamic` to `String`. As this is injected directly into the adapter, it does not need to be dynamic and should better reflect its purpose.

## 0.0.3+1

* Moves generator placeholders to `FieldSerializable` form `OfflineFirst`
* Removes query validation that ensures all Where conditions have a non-null value

## 0.0.3

* Add `And` and `Or` `Where` subclasses
* Removes Type argument from `Where`
* Adds semantic methods to `Where` such as `isExactly` and
* **BREAKING** Revise `Where` syntax. This removes the second positional argument in favor of using it in a semantic method.
* Adds `Where.exact` factory to preserve previous, short syntax
* Move query-related files to `src/query` and make them accessible from a barrel file in the lib root

## 0.0.2

* Fix linter hints
* Adds `initialize` method to `ModelRepository`. This is enforces a predictable, overridable method for sub classes
