![brick_offline_first_with_graphql workflow](https://github.com/GetDutchie/brick/actions/workflows/brick_offline_first_with_graphql.yaml/badge.svg)

`OfflineFirstWithGraphqlRepository` streamlines the GraphQL integration with an `OfflineFirstRepository`. A serial queue is included to track GraphQL mutations in a separate SQLite database, only removing requests when a response is returned from the host (i.e. the device has lost internet connectivity).

The `OfflineFirstWithGraphql` domain uses all the same configurations and annotations as `OfflineFirst`.

## GraphqlOfflineQueueLink

To cache outbound requests, apply `GraphqlOfflineQueueLink` in your GraphqlProvider:

```dart
GraphqlProvider(
  link: Link.from([
    GraphqlOfflineQueueLink(
      GraphqlRequestSqliteCacheManager('myAppRequestQueue.sqlite'),
      // Optionally specify callbacks for queue retries and errors
      onReattempt: onReattempt,
      onRequestException: onRequestException,
    ),
    HttpLink(endpoint)
  ]),
);
```

:warning: Be sure to place the queue above `HttpLink` or `WebSocketLink` or any other outbound `Link`s.

## Models

### ConnectOfflineFirstWithGraphql

`@ConnectOfflineFirstWithGraphql` decorates the model that can be serialized by GraphQL and SQLite. Offline First does not have configuration at the class level and only extends configuration held by its providers:

```dart
@ConnectOfflineFirstWithGraphql(
  graphqlConfig: GraphqlSerializable(),
  sqliteConfig: SqliteSerializable(),
)
class MyModel extends OfflineFirstModel {}
```

## Unsupported

### Field Types

- Any unsupported field types from `GraphqlProvider` or `SqliteProvider`
- Future iterables of future models (i.e. `Future<List<Future<Model>>>`.

### Configuration

- `@OfflineFirst(where:` only supports extremely simple renames. Multiple `where` keys (`OfflineFirst(where: {'id': 'data["id"]', 'otherVar': 'data["otherVar"]'})`) or nested properties (`OfflineFirst(where: {'id': 'data["subfield"]["id"]})`) will be ignored. Be sure to use `@Graphql(name:)` to rename the generated document field.
