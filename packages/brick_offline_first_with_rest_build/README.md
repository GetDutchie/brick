# Brick Offline First with Rest Build

Code generator that provides (de)serializing functions for Brick adapters using RestProvider and SqliteProvider within the OfflineFirstWithRest domain. Classes annotated with `ConnectOfflineFirstWithRest` **and** extending the model `OfflineFirstWithRest` will be discovered.

## Setup

`dart:mirrors` will conflict with Flutter, so this package should be imported as a dev dependency and executed before an app's run time.

```yaml
dev_dependencies:
  brick_offline_first_with_rest_build:
    git:
      url: git@github.com:greenbits/brick.get
      path: packages/brick_offline_first_with_rest_build
```

Build your code:

```shell
cd my_app; (flutter) pub run build_runner build
```
