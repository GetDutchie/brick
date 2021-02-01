# Models

`@ConnectOfflineFirstWithRest` decorates the model that can be serialized by one or more providers. Offline First does not have configuration at the class level and only extends configuration held by its providers:

```dart
@ConnectOfflineFirstWithRest(
  restConfig: RestSerializable(),
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

## FAQ

### Why can't I declare a model argument?

Due to [an open analyzer bug](https://github.com/dart-lang/sdk/issues/38309), a custom model cannot be passed to the repository as a type argument.
