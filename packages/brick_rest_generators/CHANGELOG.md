## Unreleased

* Fix a a JSON encode error in REST serialization. `.map` returns a `MappedListIterable` which `jsonEncode` cannot parse. It can parse `List<dynamic>`.
