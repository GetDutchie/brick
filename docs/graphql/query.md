?> The GraphQL domain is currently in Alpha. APIs are subject to change.

# `Query` Configuration

## `providerArgs:`

| Name | Type | Description |
|---|---|---|
| `'document'` | `String` | apply this document as the query when sending to GraphQL. This will override any defaults set by `GraphqlSerializable` |
| `'variables'` | `Map<String, String>` | use these variables instead of a generated TLD query value when composing a request. By default, Brick will use the `toGraphql` output from the adapter |

## `where:`

Values supplied to `where:` are transformed into variables sent with queries and subscriptions. Variables autopopulated from `Query(where:)` are overriden by - not mixed with - `providerArgs: {'variables'}`.

```dart
Query(where: [
  Where('name').isExactly('Thomas')
])
// => {'name': 'Thomas'}
```

To extend a query with custom properties, use `GraphqlProvider#queryToVariables`:

```dart
final query = Query.where('name', 'Thomas');
final variables = {
  ...graphqlProvider.queryToVariables(query),
  'myCustomVariable': true,
};
```

!> Association values within `Where` **are not** converted to variables
