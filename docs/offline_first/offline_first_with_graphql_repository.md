?> The GraphQL domain is currently in Alpha. APIs are subject to change.

# Offline First With GraphQL Repository

`OfflineFirstWithGraphqlRepository` streamlines the GraphQL integration with an `OfflineFirstRepository`. A serial queue is included to track GraphQL mutations in a separate SQLite database, only removing requests when a response is returned from the host (i.e. the device has lost internet connectivity).

The `OfflineFirstWithGraphql` domain uses all the same configurations and annotations as `OfflineFirst`.
