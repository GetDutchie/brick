## Unreleased

* Generate `RuntimeGraphqlDefinitions#subfields` as `Map<String, Map<String, dynamic>>` to support nested properties of JSON-encoded fields.
* Apply `@OfflineFirst(where:)` params to GraphQL document configuration. Note that the current implementation ignores multiple `where` properties (`OfflineFirst(where: {'id': 'data["id"]', 'otherVar': 'data["otherVar"]'})`) and nested values (`OfflineFirst(where: {'id': 'data["subfield"]["id"]})`).

## 1.2.0+1

* Fix migration and model discovery

## 1.2.0

* Permit using `part` and `part of` files outside of models

## 1.1.1

* Loosen dependency restrictions to major versions

## 1.1.0

* Stable release

## 1.0.2

* Enforce `brick_build` version `2.0.0-rc.2`

## 1.0.1

* Support `brick_offline_first_with_graphql_abstract`
