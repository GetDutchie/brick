## Unreleased

* Remove unnecessary import in `brick.g.dart`

## 1.1.4

* Always use `whereType<T>` casts after awaiting `Future.wait()` in Rest deserializing adapters.
* Bump `brick_build`

## 1.1.3

* Bump `brick_sqlite_generators`

## 1.1.2

* Prefer constructor field type (including nullability) over field definition for type inference in adapter generation.
* **BREAKING CHANGE**: Remove support for nullable futures as the outer-most type (eg brick now reads `Future<String?>?` as `Future<String?>`, but `List<Future<String?>?>?` remains valid).
* Bump `brick_build`
* Bump `brick_rest_generators`

## 1.1.1

* Always cast when deserializing `OfflineFirstSerdes` from SQLite
* Always cast when deserializing `OfflineFirstSerdes` from REST
* Use null aware operators when deserializing `OfflineFirstSerdes` iterables from REST


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
