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

## OfflineFirstSerdes

When storing raw data is more optimal than storing it as an association, an `OfflineFirstSerdes` can be used. For example, a child model has only a few properties but hosts a significant number of computed members and methods:

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

| Mixin | Description |
|---|---|
| [`DeleteAllMixin`](lib/mixins/delete_all_mixin.dart) | Adds methods `#deleteAll` and `#deleteAllExcept` |
| [`DestructiveLocalSyncFromRemoteMixin`](lib/mixins/destructive_local_sync_from_remote_mixin.dart) | Extends `get` requests to force resync the `remoteProvider` to the local providers (also covered by new method `#destructiveLocalSyncFromRemote`) |

### General Usage

```dart
import 'package:brick_offline_first/mixins.dart';
class MyRepository extends OfflineFirstRepository with DeleteAllMixin {}
```

## FAQ

### Why can't I declare a model argument?

Due to [an open analyzer bug](https://github.com/dart-lang/sdk/issues/38309), a custom model cannot be passed to the repository as a type argument.
