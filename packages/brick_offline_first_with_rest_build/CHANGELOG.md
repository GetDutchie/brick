## Unreleased

## 1.1.0

* Add Dart Lints
* Update to use new `brick_build` API for `getAssociationMethod` and `repositoryHasBeenForceCast`
* Fix Dart null safety complaints when accessing repository in a subsequent null or non null safe way after a force cast to non-null.

## 1.0.0+2

* Fix null safety for one-to-one REST serializing associations (#186)

## 1.0.0+1

* Remove `source_gen_test` and `glob` dependencies

## 1.0.0

* Null safety

## 0.0.1

* Fix a a JSON encode error. `.map` returns a `MappedListIterable` which `jsonEncode` cannot parse. It can parse `List<dynamic>`.
