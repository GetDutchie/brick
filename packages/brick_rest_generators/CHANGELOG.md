## Unreleased

## 1.0.2

* Prefer constructor field type (including nullability) over field definition for type inference in adapter generation.
* Bump `brick_build`

## 1.0.1

* Add Dart Lints
* Bump `brick_build`
* Always cast from list when deserializing siblings

## 1.0.0+4

* Fix deserialize and serialize `enumAsString` for non-nullable types (#183)

## 1.0.0+3

* Fix pubspec dependencies

## 1.0.0+2

* Fix nullable analyzer errors around DateTime and enum (de)serialization and association serialization

## 1.0.0+1

* Remove `source_gen_test` dependency

## 1.0.0

* Null safety

## 0.0.1

* Fix a a JSON encode error in REST serialization. `.map` returns a `MappedListIterable` which `jsonEncode` cannot parse. It can parse `List<dynamic>`.
* Fix REST's iterable enum serialization
* #58 fixes sibling serialization when null
* Dart style: prefer collection literals
