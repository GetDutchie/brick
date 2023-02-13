## Unreleased

## 3.0.0

* **BREAKING CHANGE** Rename `graphql.dart` to `brick_graphql.dart`

## 2.0.2

* Remove `operationName`. This isn't exactly what it appears to be.

## 2.0.1

* Include `operationName` when programmatically generating operations

## 2.0.0

* **BREAKING CHANGE** `GraphqlProvider#queryToVariables` has been moved to internal class `GraphqlRequest`
* Update minimum Dart to `2.15`

**BREAKING CHANGE**

All Graphql operations are now declared in a single class - `GraphqlQueryOperationTransformer`. A single  Migration guide:

1. Create a new class that extends `GraphqlQueryOperationTransformer`:
    ```dart
    class UserQueryOperationTransformer extends GraphqlQueryOperationTransformer {
      const UserQueryOperationTransformer(super.query, super.instance);
    }
    ```
1. This class has access to every request's `query`, and for `delete` and `upsert`, `instance`. Move all declared properties to within one of `get`, `delete`, `subscribe` or `upsert`. `defaultSubscriptionFilteredOperation` and `defaultSubscriptionOperation` are now `subscribe`. Additionally, `defaultQueryFilteredOperation` and `defaultQueryFilteredOperation` have been consolidated to `get` (example below)
    ```dart
    class UserQueryOperationTransformer extends GraphqlQueryOperationTransformer {
      GraphqlOperation get get {
        if (query.where != null) {
          return GraphqlOperation(document: r'''
            query FilteredUsers($name: String!) {
              usersByName(input: $input) {}
            }
          ''');
        }
        return GraphqlOperation(document: r'''
          query AllUsers {
            users {}
          }
        ''');
      }
    }
    ```
1. In complex cases where the entire model is not being transmitted, `variables` can also be supplied.
    ```dart
    class UserQueryOperationTransformer extends GraphqlQueryOperationTransformer {
      GraphqlOperation get upsert {
        if (query.where != null) {
          return GraphqlOperation(
            document: r'''
              mutation UpdateUserName($name: String!) {
                updateUserName(input: $input) {}
              }
            ''',
            variables: {'name': Where.firstByField('name', query.where)});
        }
        return null;
      }
    }
    ```
1. Use the class in `GraphqlSerializable` (this replaces all operation declarations):
    ```dart
    @GraphqlSerializable(
      queryOperationTransformer: UserQueryOperationTransformer.new
    )
    ```

## 1.3.1

* Only return `get` documents for `get` operations when constructing the GraphQL document

## 1.3.0

* Convert `@Graphql(subfields:)` to accept a `Map<String, Map<String, dynamic>>` to permit nested subfields from JSON-encoded field types.

## 1.2.0

* Handle edge case where GraphQL response is null and an empty iterable
* Use specified `@Graphql(name:)` when generating the document request

## 1.1.2

* Override `subfields` generation by supplying the necessary subfields with `@Graphql`

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
