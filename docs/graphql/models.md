?> The GraphQL domain is currently in Alpha. APIs are subject to change.

# Model (Class) Configuration

### `@Graphql(default<METHOD>Operation:)`

Every GraphQL is built differently, and with a fair amount of technical debt. While documents and variables can be provided per request, default operations can be used to keep your code clean.

```dart
@ConnectOfflineFirstWithGraphql(
  graphqlConfig: GraphqlSerializable(
    defaultQueryOperation: r'''query GetUsers() {
      getUsers() {}
    }''',
  )
)
class User extends OfflineFirstModel {}
```

?> Only headers need to be supplied; nodes can be supplied to override default behavior of fetching all fields requested by the model. To use autopopulated nodes provided by the model (with respect to `@Graphql` configuration), use an empty node selection (e.g. `deleteUser(vars: $vars) {}`).

| Name | Description |
|---|---|
| `defaultDeleteOperation` | Used to remove a specific instance |
| `defaultQueryOperation` | Used for fetching all instances of a model **without** any arguments or variables |
| `defaultQueryFilteredOperation` | Fetch instances of a model **with** an argument or variable |
| `defaultSubscriptionOperation` | Listen for all updates to all instances of the model |
| `defaultSubscriptionFilteredOperation` | Fetch instances of a model(s) **with** an argument or variable |
| `defaultUpsertOperation` | Add or update an instance of the model. |

!> Documents provided within `Query(providerArgs:)` will override any declared default operations. See [the GraphQL query docs](query.md) for more information.

### `@GraphqlSerializable(fieldRename:)`

By default, Brick assumes the Dart field name is the same as the GraphQL node name (i.e. `final String lastName => 'lastName'`). However, this can be changed to rename all fields (this can be overriden with `@Graphql(name:)`). For example:

```dart
GraphqlSerializable(fieldRename: FieldRename.snake_case)
// on from graphql (get)
 "last_name" => final String lastName
// on to graphql (upsert)
final String lastName => "last_name"
```
