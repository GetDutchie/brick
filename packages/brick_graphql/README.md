# Brick GraphQL

Core logic for interfacing with a GraphQL server with Brick.
## How Brick Generates GraphQL Data

Because Brick interpolates with other providers, such as SQLite, there must be a single point of generation. This library elects to generate the code from Dart (instead of from a GraphQL generator like [Artemis](https://pub.dev/packages/artemis)) so that configuration for these providers can exist in the same source of truth.

## Supported `Query` Configuration

Since Dart is the source of truth, it may not map 1:1 to the GraphQL contract. Brick will intelligently guess what operation to use and send generated variables based on the Dart model. However, it can always be overriden with a `Query(providerArgs)`.

### `providerArgs:`

* `'variables'` (`Map<String, dynamic>`) use these variables instead of a generated TLD query value when composing a request
* `'document'` (`String`) apply this document query instead of one of the defaults

## Models

To reduce copypasta-ing the same GraphQL document and variables, defaults can be set on a per-model basis. Only the header is required.

### `@GraphqlSerializable(defaultDeleteOperation:)`

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

### `@GraphqlSerializable(defaultGetOperation:)`

Used for fetching all instances of a model **without** any arguments or variables.

```dart
@ConnectOfflineFirstWithGraphql(
  graphqlConfig: GraphqlSerializable(
    defaultGetOperation: r'''mutation GetUsers() {
      getUsers() {}
    }''',
  )
)
class User extends OfflineFirstModel {}
```

### `@GraphqlSerializable(defaultGetFilteredOperation:)`

Fetch instances of a model **with** an argument or variable.

```dart
@ConnectOfflineFirstWithGraphql(
  graphqlConfig: GraphqlSerializable(
    defaultGetFilteredOperation: r'''query GetFilteredUsers($input: UserFilter) {
      getFilteredUsers(filter: $input) {}
    }''',
  )
)
class User extends OfflineFirstModel {}
```

### `@GraphqlSerializable(defaultSubscriptionOperation:)`

Listen for all updates to all instances of the model

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
