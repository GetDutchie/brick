![brick_offline_first_with_rest workflow](https://github.com/GetDutchie/brick/actions/workflows/brick_offline_first_with_rest.yaml/badge.svg)

`OfflineFirstWithRestRepository` streamlines the REST integration with an `OfflineFirstRepository`. A serial queue is included to track REST requests in a separate SQLite database, only removing requests when a response is returned from the host (i.e. the device has lost internet connectivity). See `OfflineFirstWithRest#reattemptForStatusCodes`.

The `OfflineFirstWithRest` domain uses all the same configurations and annotations as `OfflineFirst`.

## Models

### ConnectOfflineFirstWithRest

`@ConnectOfflineFirstWithRest` decorates the model that can be serialized by one or more providers. Offline First does not have configuration at the class level and only extends configuration held by its providers:

```dart
@ConnectOfflineFirstWithRest(
  restConfig: RestSerializable(),
  sqliteConfig: SqliteSerializable(),
)
class MyModel extends OfflineFirstModel {}
```

## Generating Models from a REST Endpoint

A utility class is provided to make model generation from a JSON API a snap. Given an endpoint, the converter will infer the type of a field and scaffold a class. For example, the following would be saved to the `lib` directory of your project and run `$ dart lib/converter_script.dart`:

```dart
// lib/converter_script.dart
import 'package:brick_offline_first/rest_to_offline_first_converter.dart';

const BASE = "http://0.0.0.0:3000";
const endpoint = "$BASE/users";

final converter = RestToOfflineFirstConverter(endpoint: endpoint);

void main() {
  converter.saveToFile();
}

// => dart lib/converter_script.dart
```

After the model is generated, double check for `List<dynamic>` and `null` types. While the converter is smart, it's not smarter than you.

## Testing

Responses can be stubbed to and from an `OfflineFirstWithRest` repository. For convenience, file data can be used to stub JSON responses from an API:

```dart
// test/models/api/user.json
{
  "user": { "name" : "Thomas" }
}

// test/models/user_test.dart
import 'package:brick_sqlite/testing.dart';
import 'package:my_app/brick/repository.dart';

void main() {
  group("MySqliteProvider", () {
    late MyRepository repository;
    setUpAll(() async {
      repository = MyRepository(
        restProvider: RestProvider(
          client: StubOfflineFirstWithRest.fromFiles('http://0.0.0.0:3000', {
            'users': 'api/user.json'
          }).client,
        )
      );

      await repository.initialize()
    });
  });
}
```

By default, the same response is returned for both `upsert` and `get` methods, with the only variation being in status code. However, responses can be configured for different methods:

```dart
StubOfflineFirstWithRest(
  baseEndpoint: 'http://0.0.0.0:3000',
  responses: [
    StubOfflineFirstRestResponse.fromFile('users', 'api/user.json', StubHttpMethod.get),
    StubOfflineFirstRestResponse.fromFile('users', 'api/user-post.json', StubHttpMethod.post),
  ],
)
```

### Stubbing Without Files

While storing the responses in a file can be convenient and reduce code clutter, responses can be defined inline:

```dart
StubOfflineFirstWithRest(
  baseEndpoint: 'http://0.0.0.0:3000',
  responses: [
    StubOfflineFirstRestResponse('users', '{"name":"Bob"'),
    StubOfflineFirstRestResponse('users', '{"name":"Alice"'),
  ],
)
```

### Handling Endpoint Variations

Variants in the endpoint must be explicitly declared. For example, `/user`, `/users`, `/users?by_first_name=Guy` are all different. When instantiating, specify any expected variants:

```dart
StubOfflineFirstRestResponse<User>(
  endpoints: ["user", "users", "users?by_first_name=Guy"]
)
```

### Stubbing Multiple Models

Rarely will only one model need to be stubbed. All classes in an app can be stubbed efficiently using `StubOfflineFirstWithRest`:

```dart
setUpAll() async {
  final config = {
    User: ['user', 'users'],
    // Even individual member endpoints must be declared for association fetching
    // REST endpoints are manually configured, so the content may vary
    Hat: ['hat/1', 'hat/2', 'hats'],
  }
  final responses = config.entries.map((modelConfig) {
    return modelConfig.value.map((endpoint) {
      return StubOfflineFirstRestResponse.fromFile(
        'api/${modelConfig.key.toString().toLowerCase()}.json',
        endpoint: endpoint,
      );
    });
  }).expand((e) => e);
  final client = StubOfflineFirstWithRest(
    baseEndpoint: 'http://0.0.0.0:3000',
    responses: responses,
  ).client;
}
```

## Unsupported Field Types

- Any unsupported field types from `RestProvider`, or `SqliteProvider`
- Future iterables of future models (i.e. `Future<List<Future<Model>>>`.
