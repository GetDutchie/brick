# Testing

Responses can be stubbed to and from an `OfflineFirstWithRest` repository. For convenience, file data can be used to stub JSON responses from an API:

```dart
// test/models/api/user.json
{
  "user": { "name" : "Thomas" }
}

// test/models/user_test.dart
import 'package:brick_sqlite/testing.dart';
import 'package:my_app/app/repository.dart';

void main() {
  group("MySqliteProvider", () {
    setUpAll(() async {

      await StubOfflineFirstWithRestModel<User>(
        filePath: "api/user.json",
        repository: MyRepository()
      ).initialize();
    });
  });
}
```

Currently the same response is returned for both `upsert` and `get` methods, with the only variation being in status code.

## Handling Endpoint Variations

As Mockito is rightfully strict in its stubbing, variants in the endpoint must be explicitly declared. For example, `/user`, `/users`, `/users?by_first_name=Guy` are all different. When instantiating, specify any expected variants:

```dart
StubOfflineFirstWithRestModel<User>(
  endpoints: ["user", "users", "users?by_first_name=Guy"]
)
```

## Stubbing Multiple Models

Rarely will only one model need to be stubbed. All classes in an app can be stubbed efficiently using `StubOfflineFirstWithRest`:

```dart
setUpAll() async {
  final config = {
    User: ["user", "users"],
    // Even individual member endpoints must be declared for association fetching
    // REST endpoints are manually configured, so the content may vary
    Hat: ["hat/1", "hat/2", "hats"],
  }
  final models = config.entries.map((modelConfig) {
    return StubOfflineFirstWithRest(
      filePath: "api/${modelConfig.key.toString().toLowerCase()}.json",
      model: modelConfig.key,
      endpoints: modelConfig.value,
    );
  });
  await StubOfflineFirstWithRest(
    modelStubs: models,
    repository: MyRepository(),
  ).initialize();
}
```

?> `MyRepository()`'s REST client is now a Mockito instance. `verify` and other interaction matchers can be called on `MyRepository().restProvider.client`.
