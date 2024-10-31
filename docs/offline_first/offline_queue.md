## RequestSqliteCacheManager

All requests to the remote provider in the repository first pass through a queue that tracks unsuccessful requests in a SQLite database separate from the one that maintains application models. Should the application ever lose connectivity, the queue will resend all `upsert`ed requests that occurred while the app was offline. All requests are forwarded to an inner client.

The queue is automatically added to all `OfflineFirstWithGraphqlRepository`s and `OfflineFirstWithRestRepository`s. This means that a queue **should not be used as the `RestProvider`'s client or `GraphqlProvider`'s link**, however, the queue will use the remote provider's client as its inner client:

```dart
final client = RestOfflineQueueClient(
  restProvider.client, // or http.Client()
  "OfflineQueue",
);
final link = GraphqlOfflineQueueLink(
  graphqlProvider.link, // or HttpLink()
  "OfflineQueue",
);
```

![OfflineQueue logic flow](https://user-images.githubusercontent.com/865897/72175823-f44a3580-3391-11ea-8961-bbeccd74fe7b.jpg)

!> The queue ignores requests that are not `DELETE`, `PATCH`, `POST`, and `PUT` for REST. In GraphQL, `query` and `subscription` operations are ignored. Fetching requests are not worth tracking as the caller may have been disposed by the time the app regains connectivity.

## Queue Processing Callbacks

For tracking the status of queued requests, the `GraphqlOfflineQueueLink` and `RestOfflineQueueClient` constructors accept callback functions which are triggered for specific events:

- `onRequestException`: Invoked when a request encounters an exception during execution (e.g. a `SocketException`). The function receives both the request and an object containing the thrown exception.
- `onReattempt`: Invoked when a request will be retried. For REST, this is when the response has a status code listed in the `reattemptForStatusCodes` list.

These callbacks provide practical ways to detect the state of the queue (e.g. if the client is offline, the queue is being processed, or the queue is blocked during serial processing). For more, refer to the [discussion on this topic](https://github.com/GetDutchie/brick/issues/393).
