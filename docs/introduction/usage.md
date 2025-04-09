# Usage

Create a model as the app's business logic:

```dart
// brick/models/user.dart
@ConnectOfflineFirstWithRest()
class User extends OfflineFirstWithRestModel {}
```

And generate (de)serializing code to fetch to and from multiple providers:

```bash
$ (flutter) pub run build_runner build
```

!> `build_runner` will only generate necessary adapters and mappings if you're using a build package (e.g. `brick_offline_first_with_supabase_build`).

## Fetching Data

A repository fetches and returns data across multiple providers. It's the single access point for data in your app:

```dart
class MyRepository extends OfflineFirstWithRestRepository {
  MyRepository();
}

final repository = MyRepository();

// Now the models can be queried:
final users = await repository.get<User>();
```

Behind the scenes, this repository could poll a memory cache, then SQLite, then a REST API. The repository intelligently determines how and when to use each of the providers to return the fastest, most reliable data.

```dart
// Queries can be general:
final query = Query(where: [Where('lastName').contains('Muster')]);
final users = await repository.get<User>(query: query);

// Or singular:
final query = Query.where('email', 'user@example.com', limit1: true);
final user = await repository.get<User>(query: query);
```

Queries can also receive **reactive updates**. The subscribed stream receives all models from its query whenever the local copy is updated (e.g. when the data is hydrated in another part of the app):

```dart
final users = repository.subscribe<User>().listen((users) {})
```

## Mutating Data

Once a model has been created, it's sent to the repository and back out to _each_ provider:

```dart
final user = User();
await repository.upsert<User>(user);
```

## Associating Data

Repositories can support associations and automatic (de)serialization of child models.

```dart
class Hat extends OfflineFirstWithRestModel {
  final String color;
  Hat({this.color});
}
class User extends OfflineFirstWithRestModel {
  // user has many hats
  final List<Hat> hats;
}

final query = Query.where('hats', Where('color').isExactly('brown'));
final usersWithBrownHats = repository.get<User>(query: query);
```

Brick natively [serializes primitives, associations, and more](packages/brick_offline_first/example/lib/brick/models/kitchen_sink.model.dart).

If it's still murky, [check out Learn](home.md#learn) for videos, tutorials, and examples that break down Brick.
