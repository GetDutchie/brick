## Unreleased

* Fix a a JSON encode error in REST serialization. `.map` returns a `MappedListIterable` which `jsonEncode` cannot parse. It can parse `List<dynamic>`.
* Fix REST's iterable enum serialization
* #58 fixes sibling serialization when null
* Dart style: prefer collection literals
