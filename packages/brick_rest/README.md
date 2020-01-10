# REST Provider

Connecting [Brick](../../) with a RESTful API.

## Supported `Query` Configuration

### `params:`

* `'headers'` (`Map<String, String>`) set HTTP headers
* `'request'` (`String`) specifies HTTP method. Only available to `#upsert`. Defaults to `POST`
* `'topLevelKey'` (`String`) the payload is sent or received beneath a JSON key (For example, `{"user": {"id"...}}`)

### `where:`

`RestProvider` does not support any `Query#where` arguments. These should be configured on a model-by-model base by the `RestSerializable#endpoint` argument.

## Models

### `@Rest(endpoint:)`

Every REST API is built differently, and with a fair amount of technical debt. Brick provides flexibility for inconsistent endpoints within any system. Endpoints can also change based on the query. The model adapter will query `endpoint` for `upsert` or `get` or `delete`.

Since Dart requires annotations to be constants, functions cannot be used. This is a headache. Instead, the function must be stringified. The annotation only expects the function body: `query` will always be available, and `instance` will be available to methods handling an `instance` argument like `upsert` or `delete`. The function body must return a string.

```dart
@ConnectOfflineFirst(
  restConfig: RestSerializable(
    endpoint: '=> "/users";';
  )
)
class User extends OfflineFirstModel {}
```

When managing an instance, say in `delete`, the endpoint will have to be expanded:

```dart
@ConnectOfflineFirst(
  restConfig: RestSerializable(
    endpoint: r'''{
      if (query?.action == QueryAction.delete) return "/users/${instance.id}";

      return "/users";
    }''';
  )
)
class User extends OfflineFirstModel {}
```

:warning: If an endpoint's function returns `null`, it is skipped by the provider.

#### With Query#params

```dart
@ConnectOfflineFirst(
  restConfig: RestSerializable(
    endpoint: r'''{
      if (query?.action == QueryAction.delete) return "/users/${instance.id}";

      if (query?.action == QueryAction.get &&
          query?.params.isNotEmpty &&
          query?.params['limit'] != null) {
            return "/users?limit=${query.params['limit']}";
      }

      return "/users";
    }''';
  )
)
class User extends OfflineFirstModel {}
```

#### With Query#where

```dart
@ConnectOfflineFirst(
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
@ConnectOfflineFirst(
  restConfig: RestSerializable(
    endpoint: '=> EndpointHelpers.indexOrMemberEndpoint("users")';
  )
)
class User extends OfflineFirstModel {}

// hat.dart
// Brick has already discovered and imported endpoint_helpers.dart, so while it
// can be imported again in this file for consistency, it's not necessary
@ConnectOfflineFirst(
  restConfig: RestSerializable(
    endpoint: '=> EndpointHelpers.indexOrMemberEndpoint("hats")';
  )
)
class Hat extends OfflineFirstModel {}
```

### `@RestSerializable(fromKey:)` and `@RestSerializable(toKey:)`

Data will be nested beneath a top-level key in a JSON response. The key is determined by the following priority:

1) A `topLevelKey` in `Query#params` with a non-empty value
1) `fromKey` if invoked from `provider#get` or `toKey` if invoked from `provider#upsert`
1) The first discovered key. As a map is effectively an unordered list, relying on this fall through is not recommended.

`fromKey` and `toKey` are defined in the model's annotation:

```dart
@ConnectOfflineFirst(
  restConfig: RestSerializable(
    toKey: 'user',
    fromKey: 'users',
  )
)
class User extends OfflineFirstModel {}
```

:warning: If the response from REST **is not** a map, the full response is returned instead.

### `@RestSerializable(fieldRename:)`

Brick reduces the need to map REST keys to model field names by assuming a standard naming convention. For example:

```dart
RestSerializable(fieldRename: FieldRename.snake_case)
// on from rest (get)
 "last_name" => final String lastName
// on to rest (upsert)
final String lastName => "last_name"
```

## Fields

### `@Rest(enumAsString:)`

Brick by default assumes enums from a REST API will be delivered as integers matching the index in the Flutter app. However, if your API delivers strings instead, the field can be easily annotated without writing a custom generator.

Given the API:

```json
{ "user": { "hats": [ "bowler", "birthday" ] } }
```

Simply convert `hats` into a Dart enum:

```dart
enum Hat { baseball, bowler, birthday }

...

@Rest(enumAsString: true)
final List<Hat> hats;
```

### `@Rest(name:)`

REST keys can be renamed per field. This will override the default set by `RestSerializable#fieldRename`.

```dart
@Rest(
  name: "full_name"  // "full_name" is used in from and to requests to REST instead of "last_name"
)
final String lastName;
```

### `@Rest(ignoreFrom:)` and `@Rest(ignoreTo:)`

When true, the field will be ignored by the (de)serializing function in the adapter.

## Unsupported Field Types

The following are not serialized to REST. However, unsupported types can still be accessed in the model as non-final fields.

* Nested `List<>` e.g. `<List<List<int>>>`
* Many-to-many associations
