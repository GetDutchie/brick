## Unreleased

## 1.0.0

* Null safety

## 0.0.1

* Fix a a JSON encode error. `.map` returns a `MappedListIterable` which `jsonEncode` cannot parse. It can parse `List<dynamic>`.
