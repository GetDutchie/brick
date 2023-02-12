# Model (Class) Configuration

### `@RestSerializable(requestTransformer:)`

?> `requestTransformer` was added in Brick 3. For upgrading to Brick v3 from v2, please see [the migration guide](https://github.com/GetDutchie/brick/blob/main/MIGRATING.md).

Every REST API is built differently, and with a fair amount of technical debt. Brick provides flexibility for inconsistent endpoints within any system. Endpoints can also change based on the query. The model adapter will query `endpoint` for `upsert` or `get` or `delete`.

Since Dart requires annotations to be constants, dynamic functions cannot be used. This is a headache. Instead, the a `const`antized [constructor tearoff](https://medium.com/dartlang/dart-2-15-7e7a598e508a) can be used. The transformers permit dynamically defining the request (method, top level key, url, etc.) at runtime based on query params or if a Dart instance is available (`upsert` and `delete` only)

```dart
class UserRequestTransformer extends RestRequestTransformer {
  final get = const RestRequest(url: '/users');
  const UserRequestTransformer(Query? query, RestModel? instance) : super(query, instance);
}

@ConnectOfflineFirstWithRest(
  restConfig: RestSerializable(
    requestTransformer: UserRequestTransformer.new;
  )
)
class User extends OfflineFirstModel {}
```

Different provider calls will use different transformer fields:

```dart
class UserRequestTransformer extends RestRequestTransformer {
  final get = const RestRequest(url: '/users');
  final delete = RestRequest(url: '/users/${instance.id}');

  const UserRequestTransformer(Query? query, Model? instance) : super(query, instance);
}

@ConnectOfflineFirstWithRest(
  restConfig: RestSerializable(
    requestTransformer: UserRequestTransformer.new,
  )
)
class User extends OfflineFirstModel {}
```

!> If an `RestRequestTransform`'s method field (`get`, `upsert`, `delete`) is `null` or it's `url` is `null`, the request is skipped by the provider.

#### With Query#providerArgs

```dart
class UserRequestTransformer extends RestRequestTransformer {
  RestRequest? get get {
    if (query?.providerArgs.isNotEmpty && query.providerArgs['limit'] != null) {
      return RestRequest(url: "/users?limit=${query.providerArgs['limit']}");
    }
    const RestRequest(url: '/users');
  }

  final delete = RestRequest(url: '/users/${instance.id}');

  const UserRequestTransformer(Query? query, RestModel? instance) : super(query, instance);
}

@ConnectOfflineFirstWithRest(
  restConfig: RestSerializable(
    requestTransformer: UserRequestTransformer.new,
  )
)
class User extends OfflineFirstModel {}
```

#### With Query#where

```dart
class UserRequestTransformer extends RestRequestTransformer {
  RestRequest? get get {
    if (query?.where != null) {
      final id = Where.firstByField('id', query.where)?.value;
      if (id != null) return RestRequest(url: "/users/$id");
    }
    const RestRequest(url: '/users');
  }

  final delete = RestRequest(url: '/users/${instance.id}');

  const UserRequestTransformer(Query? query, RestModel? instance) : super(query, instance);
}

@ConnectOfflineFirstWithRest(
  restConfig: RestSerializable(
    requestTransformer: UserRequestTransformer.new,
  )
)
class User extends OfflineFirstModel {}
```

?> For ease of illustration, the code is provided as if the transformer and model logic live in the same file. It's strongly recommended to include the request transformer logic in its own, colocated file (such as `user.model.request.dart`).

### `@RestRequest(topLevelKey:)`

Data will most often be nested beneath a top-level key in a JSON response. The key is determined by the following priority:

1) A `topLevelKey` in `Query#providerArgs` with a non-empty value
1) `topLevelKey` if defined in a `RestRequest`
1) The first discovered key. As a map is effectively an unordered list, relying on this fall through is not recommended.

```dart
class UserRequestTransformer extends RestRequestTransformer {
  final get = const RestRequest(url: '/users', topLevelKey: 'users');
  final upsert = const RestRequest(url: '/users', topLevelKey: 'user');
  const UserRequestTransformer(Query? query, RestModel? instance) : super(query, instance);
}

@ConnectOfflineFirstWithRest(
  requestTransformer: UserRequestTransformer.new
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
