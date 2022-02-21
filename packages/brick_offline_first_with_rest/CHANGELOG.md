## Unreleased

* Import from `sqflite_common` instead of `sqflite` to avoid a Flutter dependency

## 1.0.0

* Integrate new `OfflineFirstPolicy`s to the `RestOfflineQueueClient`

## 0.0.2

* Support new policies for skipping cache or requesting data. See [brick_offline_first's change notes](https://github.com/GetDutchie/brick/blob/main/packages/brick_offline_first/CHANGELOG.md) for how to migrate the breaking changes.

## 0.0.1

* **BREAKING CHANGE** `SqliteProvider` and `Query` are no longer exported `offline_first_with_rest.dart`. Please import from `package:brick_sqlite/sqlite.dart` and `package:brick_core/query.dart` respectively.
* Create package from `brick_offline_first`
* Initial
