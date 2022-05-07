# Brick GraphQL

Core logic for interfacing with a GraphQL server with Brick.

## How Brick Generates GraphQL Data

Because Brick interpolates with other providers, such as SQLite, there must be a single point of generation. This library elects to generate the code from Dart (instead of from a GraphQL generator like [Artemis](https://pub.dev/packages/artemis)) so that configuration for these providers can exist in the same source of truth.

## Supported `Query` Configuration

Since Dart is the source of truth, it may not map 1:1 to the GraphQL contract. Brick will intelligently guess what operation to use and send generated variables based on the Dart model. However, it can always be overriden with a `Query(providerArgs)`.

### `providerArgs:`

* `'document'` (`String`) apply this document query instead of one of the defaults. The document subfields **will not** be populated by the model.
* `'variables'` (`Map<String, dynamic>`) use these variables instead of a generated TLD query value when composing a request. By default, Brick will use the `toGraphql` output from the adapter
* `'context'` (`Map<String, ContextEntry>`) apply this as the context to the request instead of an empty object. Useful for subsequent consumers/`Link`s of the request. The key should be the runtime type of the `ContextEntry`.

## `where:`

Values supplied to `where:` are transformed into variables sent with queries and subscriptions. Variables autopopulated from `Query(where:)` are overriden by - not mixed with - `providerArgs: {'variables'}`

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

:warning: Association values within `Where` **are not** converted to variables.

## `#toJson` and subfields

When a field's type's class has a `#toJson` method that returns a `Map`, subfields will be automatically populated on requests based on the `final` instance fields of that field's type.

```dart
class Hat {
  final String fabric;
  final int width;

  Hat({this.fabric, this.width});

  Map<String, dynamic> toJson() => {'fabric': fabric, 'width': width};
}

class Mounty {
  final Hat hat;
  final String horseName
  final String name;
}
```

Produces the following GraphQL document on `query` or `subscription`:

```graphql
query {
  myQueryName {
    hat {
      fabric
      width
    }
    horseName
    name
  }
}
```

## Models

To reduce copypasta-ing the same GraphQL document and variables, defaults can be set on a per-model basis. Only the header is required.

:bulb: Only headers need to be supplied; nodes can be supplied to override default behavior of fetching all fields requested by the model. To use autopopulated nodes provided by the model (with respect to `@Graphql` configuration), use an empty node selection (e.g. `deleteUser(vars: $vars) {}`).

### `@GraphqlSerializable(defaultDeleteOperation:)`

Used to remove a specific instance.

```dart
@ConnectOfflineFirstWithGraphql(
  graphqlConfig: GraphqlSerializable(
    defaultDeleteOperation: r'''mutation DeleteUser($input: DeleteUserInput!) {
      deleteUser(input: $input) {}
    }''',
  )
)
class User extends OfflineFirstModel {}
```

### `@GraphqlSerializable(defaultQueryOperation:)`

Used for fetching all instances of a model **without** any arguments or variables.

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

### `@GraphqlSerializable(defaultQueryFilteredOperation:)`

Fetch instances of a model **with** an argument or variable.

```dart
@ConnectOfflineFirstWithGraphql(
  graphqlConfig: GraphqlSerializable(
    defaultQueryFilteredOperation: r'''query GetFilteredUsers($input: UserFilterInput) {
      getFilteredUsers(input: $input) {}
    }''',
  )
)
class User extends OfflineFirstModel {}
```

### `@GraphqlSerializable(defaultSubscriptionOperation:)`

Listen for all updates to all instances of the model.

```dart
@ConnectOfflineFirstWithGraphql(
  graphqlConfig: GraphqlSerializable(
    defaultSubscriptionOperation: r'''subscription SubscribeToUsers() {
      getUsers() {}
    }''',
  )
)
class User extends OfflineFirstModel {}
```

### `@GraphqlSerializable(defaultSubscriptionFilteredOperation:)`

Fetch instances of a model(s) **with** an argument or variable.

```dart
@ConnectOfflineFirstWithGraphql(
  graphqlConfig: GraphqlSerializable(
    defaultSubscriptionFilteredOperation: r'''subscription SubscribeToUser($input: UserModel) {
      getUser(input: $input) {}
    }''',
  )
)
class User extends OfflineFirstModel {}
```

### `@GraphqlSerializable(defaultUpsertOperation:)`

Add or update an instance of the model.

```dart
@ConnectOfflineFirstWithGraphql(
  graphqlConfig: GraphqlSerializable(
    defaultUpsertOperation: r'''mutation UpsertUser($input: UserModel) {
      upsertUser(input: $input) {}
    }''',
  )
)
class User extends OfflineFirstModel {}
```

:warning: Nodes can be supplied for all operations but they will be ignored.
