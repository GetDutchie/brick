## Unreleased

* Loosen dependency restrictions to major versions
* Use Dart 2.15's `.byName` accessor for iterable enum values and remove `RestAdapter.enumValueFromName`

## 1.0.1

* If `.fromJson` is defined on a field's class, the field will be recognized in the adapter and `.fromJson` will be used when deserializing.
* If `#toJson` is defined on a field's class, the field will be recognized in the adapter and `#toJson` will be used when serializing.

## 1.0.0

* Separate `brick_json_generators` to its own package from `brick_rest_generators`
