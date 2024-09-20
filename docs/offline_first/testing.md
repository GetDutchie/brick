# Testing

## OfflineFirstWithRest

Responses can be stubbed to and from an `OfflineFirstWithRest` repository. For convenience, file data can be used to stub JSON responses from an API:

```dart
// test/models/api/user.json
{
  "user": { "name" : "Thomas" }
}

// test/models/user_test.dart
import 'package:brick_offline_first/testing.dart';
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

?> Variants in the endpoint must be explicitly declared. For example, `/user`, `/users`, `/users?by_first_name=Guy` are all different. When instantiating, specify all expected variants.

## OfflineFirstWithSupabase

See [Supabase Testing](https://getdutchie.github.io/brick/#/supabase/testing)
