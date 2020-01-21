## Unreleased

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
