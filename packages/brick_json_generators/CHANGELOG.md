## Unreleased

## 3.0.0

* Update minimum `analyzer` constraint to `5.0.0`
* Use Dart 2.15's `.byName` accessor for iterable enum values

## 1.1.1

* Respect enum `from<Provider>` constructors and `to<Provider>` methods

## 1.1.0

* Upgrade analyzer to version 4

## 1.0.3

* Do not auto assign values for nullable iterables when deserializing

## 1.0.2

* Loosen dependency restrictions to major versions
* Check for nullability before deserializing single associations

## 1.0.1

* If `.fromJson` is defined on a field's class, the field will be recognized in the adapter and `.fromJson` will be used when deserializing.
* If `#toJson` is defined on a field's class, the field will be recognized in the adapter and `#toJson` will be used when serializing.

## 1.0.0

* Separate `brick_json_generators` to its own package from `brick_rest_generators`
