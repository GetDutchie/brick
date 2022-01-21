![brick_offline_first_with_graphql_build workflow](https://github.com/GetDutchie/brick/actions/workflows/brick_offline_first_with_graphql_build.yaml/badge.svg)

# Brick Offline First with GraphQL Build

Code generator that provides (de)serializing functions for Brick adapters using GraphqlProvider and GraphqlProvider within the OfflineFirstWithRest domain. Classes annotated with `ConnectOfflineFirstWithGraphql` **and** extending the model `OfflineFirstWithGraphql` will be discovered.

## Setup

`dart:mirrors` will conflict with Flutter, so this package should be imported as a dev dependency and executed before an app's run time.

```yaml
dev_dependencies:
  brick_offline_first_with_graphql_build:
    git:
      url: git@github.com:GetDutchie/brick.get
      path: packages/brick_offline_first_with_graphql_build
```

Build your code:

```shell
cd my_app; (flutter) pub run build_runner build
```
