## Unreleased

* Add Dart Lints
* Update to use new `brick_build` API for `getAssociationMethod` and `repositoryHasBeenForceCast`

## 1.0.0+2

* Fix null safety for one-to-one REST serializing associations (#186)

## 1.0.0+1

* Remove `source_gen_test` and `glob` dependencies

## 1.0.0

* Null safety

## 0.0.1

* Fix a a JSON encode error. `.map` returns a `MappedListIterable` which `jsonEncode` cannot parse. It can parse `List<dynamic>`.
