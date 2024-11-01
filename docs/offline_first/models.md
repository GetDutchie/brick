# Models

## ConnectOfflineFirstWithRest

`@ConnectOfflineFirstWithRest` decorates the model that can be serialized by one or more providers. Offline First does not have configuration at the class level and only extends configuration held by its providers:

```dart
@ConnectOfflineFirstWithRest(
  restConfig: RestSerializable(),
  sqliteConfig: SqliteSerializable(),
)
class MyModel extends OfflineFirstModel {}
```

## ConnectOfflineFirstWithGraphql

`@ConnectOfflineFirstWithGraphql` decorates the model that can be serialized by GraphQL and SQLite. Offline First does not have configuration at the class level and only extends configuration held by its providers:

```dart
@ConnectOfflineFirstWithGraphql(
  graphqlConfig: GraphqlSerializable(),
  sqliteConfig: SqliteSerializable(),
)
class MyModel extends OfflineFirstModel {}
```

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

!> `.fromJson` always expects a single, unnamed parameter and a type for that parameter. Multiple parameters and not declaring a type are both unsupported.

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

?> `from<ProviderName>` or `to<ProviderName>` will be prioritized over `fromJson` or `toJson` which are prioritized over the provider annotation's `enumAsString: true`.

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
