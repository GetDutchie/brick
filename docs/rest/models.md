# Model (Class) Configuration

### `@Rest(endpoint:)`

Every REST API is built differently, and with a fair amount of technical debt. Brick provides flexibility for inconsistent endpoints within any system. Endpoints can also change based on the query. The model adapter will query `endpoint` for `upsert` or `get` or `delete`.

Since Dart requires annotations to be constants, functions cannot be used. This is a headache. Instead, the function must be stringified. The annotation only expects the function body: `query` will always be available, and `instance` will be available to methods handling an `instance` argument like `upsert` or `delete`. The function body must return a string.

```dart
@ConnectOfflineFirstWithRest(
  restConfig: RestSerializable(
    endpoint: '=> "/users";';
  )
)
class User extends OfflineFirstModel {}
```

When managing an instance, say in `delete`, the endpoint will have to be expanded:

```dart
@ConnectOfflineFirstWithRest(
  restConfig: RestSerializable(
    endpoint: r'''{
      if (query?.action == QueryAction.delete) return "/users/${instance.id}";

      return "/users";
    }''';
  )
)
class User extends OfflineFirstModel {}
```

!> If an endpoint's function returns `null`, it is skipped by the provider.

#### With Query#providerArgs

```dart
@ConnectOfflineFirstWithRest(
  restConfig: RestSerializable(
    endpoint: r'''{
      if (query?.action == QueryAction.delete) return "/users/${instance.id}";

      if (query?.action == QueryAction.get &&
          query?.providerArgs.isNotEmpty &&
          query?.providerArgs['limit'] != null) {
            return "/users?limit=${query.providerArgs['limit']}";
      }

      return "/users";
    }''';
  )
)
class User extends OfflineFirstModel {}
```

#### With Query#where

```dart
@ConnectOfflineFirstWithRest(
  restConfig: RestSerializable(
    endpoint: r'''{
      if (query?.action == QueryAction.delete) return "/users/${instance.id}";

      if (query?.action == QueryAction.get && query?.where != null) {
        final id = Where.firstByField('id', query.where)?.value;
        if (id != null) return "/users/$id";
      }

      return "/users";
    }''';
  )
)
class User extends OfflineFirstModel {}
```

#### DRY Endpoints

As this can become repetitive across models that share a similar interface with a remote provider, a helper class can be employed. Brick imports the same files that a model file imports into `brick.g.dart`, which in turn is shared across all adapters.

```dart
// Plainly:
import 'package:my_flutter_app/endpoint_helpers.dart';
...
class User extends OfflineFirstModel {}

// is accessible for
class UserAdapter ... {
  endpoint() {}
}
```

A complete example:

```dart
// endpoint_helpers.dart
class EndpointHelpers {
  static indexOrMemberEndpoint(String path) {
    if (query?.action == QueryAction.delete) return "/$path/${instance.id}";

    if (query?.action == QueryAction.get && query?.where != null) {
      final id = Where.firstByField('id', query.where)?.value;
      if (id != null) return "/$path/$id";
    }

    return "/$path";
  }
}

// user.dart
import 'package:my_flutter_app/endpoint_helpers.dart';
@ConnectOfflineFirstWithRest(
  restConfig: RestSerializable(
    endpoint: '=> EndpointHelpers.indexOrMemberEndpoint("users")';
  )
)
class User extends OfflineFirstModel {}

// hat.dart
// Brick has already discovered and imported endpoint_helpers.dart, so while it
// can be imported again in this file for consistency, it's not necessary
@ConnectOfflineFirstWithRest(
  restConfig: RestSerializable(
    endpoint: '=> EndpointHelpers.indexOrMemberEndpoint("hats")';
  )
)
class Hat extends OfflineFirstModel {}
```

### `@RestSerializable(fromKey:)` and `@RestSerializable(toKey:)`

Data will be nested beneath a top-level key in a JSON response. The key is determined by the following priority:

1) A `topLevelKey` in `Query#providerArgs` with a non-empty value
1) `fromKey` if invoked from `provider#get` or `toKey` if invoked from `provider#upsert`
1) The first discovered key. As a map is effectively an unordered list, relying on this fall through is not recommended.

`fromKey` and `toKey` are defined in the model's annotation:

```dart
@ConnectOfflineFirstWithRest(
  restConfig: RestSerializable(
    toKey: 'user',
    fromKey: 'users',
  )
)
class User extends OfflineFirstModel {}
```

!> If the response from REST **is not** a map, the full response is returned instead.

### `@RestSerializable(fieldRename:)`

Brick reduces the need to map REST keys to model field names by assuming a standard naming convention. For example:

```dart
RestSerializable(fieldRename: FieldRename.snake_case)
// on from rest (get)
 "last_name" => final String lastName
// on to rest (upsert)
final String lastName => "last_name"
```

## GZipping Requests

All requests to the API endpoint can be compressed with Dart's standard [GZip library](https://api.dart.dev/stable/2.10.4/dart-io/GZipCodec-class.html). All requests will (over)write the `Content-Encoding` header to `{'Content-Encoding': 'gzip'}`.

```dart
import 'package:brick_rest/gzip_http_client.dart';
final restProvider = RestProvider(client: GZipHttpClient(level: 9));
```

!> Your API must be able to accept and decode GZipped requests.
