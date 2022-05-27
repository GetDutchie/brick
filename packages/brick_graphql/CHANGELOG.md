## Unreleased

## 1.1.1

* Loosen `gql`, `gql_exec`, and `gql_link` restriction

## 1.1.0

* If a document is declared without subfields, do not overwrite this definition with subfields from the model.
* Add `variablesNamespace` to wrap all variables from all requests. Variables passed from `providerArgs` will not be wrapped within the namespace.

## 1.0.3

* Return `null` if no GraphQL document can be inferred in `ModelFieldsDocumentTransformer` instead of throwing an `ArgumentError`. This mirrors behavior in `brick_rest`.

## 1.0.2

* Add `subfields` to `RuntimeGraphqlDefinition`; support `subfields` in `ModelFieldsDocumentTransformer`
* When a field's type declares a `toJson` method that returns a map, subfields will be automatically populated on fetch requests based on the `final` instance fields of that field's type.

# 1.0.1

* Loosen dependency restrictions to major versions
* Expose `RuntimeGraphqlDefinition`

## 1.0.0

* Stable release

## 0.0.1+4

* Supply `context` as `<String, ContextEntry>` instead of type do to [a limitation in JSON serialization](https://stackoverflow.com/a/70538460)

## 0.0.1+3

* Support supplying `context` in `Query#providerArgs`

## 0.0.1+2

* Rename `fieldsToRuntimeDefinition` to `fieldsToGraphqlRuntimeDefinition`

## 0.0.1+1

* Return `List<_Model>` when invoking `subscribe`

## 0.0.1

Alpha release
