![brick_offline_first workflow](https://github.com/GetDutchie/brick/actions/workflows/brick_offline_first.yaml/badge.svg)

# Brick Offline First

Offline First combines SQLite and a remote provider into one unified repository. And, optionally, a memory cache layer as the entry point. The remote provider could query Firebase or REST, hydrate the results to SQLite, and then deliver those SQLite results back to the app. In this way, the app functions identically when it's online or offline:

![OfflineFirst#get](https://user-images.githubusercontent.com/865897/72176226-cdd8ca00-3392-11ea-867d-42f5f4620153.jpg)

:bulb: You can change default behavior on a per-request basis using `policy:` (e.g. `get<Person>(policy: OfflineFirstUpsertPolicy.localOnly)`). This is available for `delete`, `get`, `getBatched`, and `upsert`.

## Fields

### `@OfflineFirst(where:)`

Using unique identifiers, `where:` can connect multiple providers. It is declared using a map between a local provider (key) and a remote provider (value). This is useful when a remote provider only includes unique identifiers (such as `"id": 1`) of associations, the OfflineFirstRepository can lookup that instance from another source and deserialize into a complete model.

:warning: This is a rare instance where the serializer property name is used instead of the field name, such as `last_name` instead of `lastName`.

For a concrete example, SQLite is the local data source and REST is the remote data source:

Given the API:

```javascript
{ "assoc": {
    // These don't have to map to SQLite columns.
    // They can also be String uuids that SQLite considers unique
    "id": 12345,
    "ids": [12345, 6789]
    }}
```

The association can be automatically mapped to SQLite (note the inclusion of `data`; this will always be "data" as it specifies the in-progress deserialization):

```dart
@OfflineFirst(where: {'id' : "data['assoc']['id']"})
final Assoc assoc;

@OfflineFirst(where: {'id' : "data['assoc']['ids']"})
final List<Assoc> assoc;
```

`@OfflineFirst(where:)` only applies to associations or iterable associations. If `@OfflineFirst(where:)` is not defined, the model will attempt to be instantiated by the REST key that maps to the field.

:warning: When `@OfflineFirst(where:)` is defined, the `@Rest|Graphql(toGenerator:)` generator will not feature the field **unless** a `toRest` custom generator is defined OR only one pair is defined in the map.

## `.fromJson` and `.toJson`

When storing raw data is more optimal than storing it as an association, use the factory `fromJson` or the method `toJson`:

```dart
import 'dart:convert';
class Weight {
  final int size;
  final String unit;

  Weight(this.size, this.unit);

  factory Weight.fromJson(Map<String, dynamic> data) {
    if (data == null || data.isEmpty) return null;

    final size = double.parse(data.keys.first.toString() ?? '0');
    return Weight(size, data.values.first);
  }

  Map<String, dynamic> toJson() => {'size': size, 'unit': unit};
}
```

:warning: `.fromJson` always expects a single, unnamed parameter and a type for that parameter. Multiple parameters and not declaring a type are both unsupported.

### Enums

[Dart's enhanced enums](https://medium.com/dartlang/dart-2-17-b216bfc80c5d) can also be used to do custom serdes work. In addition to `fromJson` and `toJson`, the enum can use the provider name:

```dart
enum Direction {
  up,
  down;

  factory Direction.fromRest(String direction) => direction == up.name ? up : down;

  int toSqlite() => Direction.values.indexOf(this);
}
```

:bulb: `from<ProviderName>` or `to<ProviderName>` will be prioritized over `fromJson` or `toJson` which are prioritized over the provider annotation's `enumAsString: true`.

## OfflineFirstSerdes

When `fromJson` and `toJson` are too heavy handed, provider-specific factories or provider-specific functions can be used via `OfflineFirstSerdes`. Instead of `toJson`, specify the provider (such as `toRest`). Instead of `fromJson`, specify the provider (such as `fromRest`).

```dart
import 'dart:convert';
class Weight extends OfflineFirstSerdes<Map<int, String>, String> {
  final int size;
  final String unit;

  Weight(this.size, this.unit);

  // A fromRest factory must be defined
  factory Weight.fromRest(Map<String, dynamic> data) {
    if (data == null || data.isEmpty) return null;

    final size = double.parse(data.keys.first.toString() ?? '0');
    return Weight(size, data.values.first);
  }

  // A fromSqlite factory must be defined
  factory Weight.fromSqlite(String data) => Weight.fromRest(jsonDecode(data));

  toRest() => {size: unit};
  toSqlite() => jsonEncode(toRest());
}
```

`OfflineFirstSerdes` should not be used when the managed data must be queried. Plainly, Brick does not support JSON searches.

## Mixins

Some regularly requested functionality doesn't exist in out-of-the-box Brick. This functionality does not exist in the core because it is dependent on remote data formatting outside the scope of Brick or it's non-essential. However, for convenience, these features are available in a mix-and-match support library. As this is not officially supported, please use caution determining if these mixins are applicable to your implementation.

| Mixin                                                                                             | Description                                                                                                                                       |
| ------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| [`DeleteAllMixin`](lib/mixins/delete_all_mixin.dart)                                              | Adds methods `#deleteAll` and `#deleteAllExcept`                                                                                                  |
| [`DestructiveLocalSyncFromRemoteMixin`](lib/mixins/destructive_local_sync_from_remote_mixin.dart) | Extends `get` requests to force resync the `remoteProvider` to the local providers (also covered by new method `#destructiveLocalSyncFromRemote`) |

### General Usage

```dart
import 'package:brick_offline_first/mixins.dart';

class MyRepository extends OfflineFirstRepository with DeleteAllMixin {}
```

## RequestSqliteCacheManager

All requests to the remote provider in the repository first pass through a queue that tracks unsuccessful requests in a SQLite database separate from the one that maintains application models. Should the application ever lose connectivity, the queue will resend all `upsert`ed requests that occurred while the app was offline. All requests are forwarded to an inner client.

The queue is automatically added to all `OfflineFirstWithGraphqlRepository`s and `OfflineFirstWithRestRepository`s. This means that a queue **should not be used as the `RestProvider`'s client or `GraphqlProvider`'s link**, however, the queue will use the remote provider's client as its inner client:

```dart
final client = RestOfflineQueueClient(
  restProvider.client, // or http.Client()
  "OfflineQueue",
);
```

![OfflineQueue logic flow](https://user-images.githubusercontent.com/865897/72175823-f44a3580-3391-11ea-8961-bbeccd74fe7b.jpg)

:warning: The queue ignores requests that are not `DELETE`, `PATCH`, `POST`, and `PUT` for REST. In GraphQL, `query` and `subscription` operations are ignored. Fetching requests are not worth tracking as the caller may have been disposed by the time the app regains connectivity.
