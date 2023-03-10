## Unreleased

## 3.0.0

Please follow the [v3 migration guide](https://github.com/GetDutchie/brick/issues/325) to easily upgrade.

* Remove instance-access `reattemptForStatusCodes`; this is passed directly to the cache manager
* Remove extraneous constructor argument `throwTunnerNotFoundExceptions` and rely on remote policy / the queue manager
* Remove `brick_sqlite_abstract`
* Remove `brick_offline_first_abstract`
* Remove `brick_offline_first_with_rest_abstract`; add annotation `ConnectOfflineFirstWithRest` and class `OfflineFirstWithRestModel` to this package
* **BREAKING CHANGE** Rename main export file to `brick_offline_first_with_rest.dart`: `FieldRename`, `Graphql` `GraphqlProvider`,  and `GraphqlSerializable` can all be imported from the `brick_rest` package
* Add `#subscribe` method to listen for SQLite updates

## 1.1.1

* Update default of offline queue from 0 seconds to 5 seconds

## 1.1.0

* Loosen dependency restrictions to major versions
* Import from `sqflite_common` instead of `sqflite` to avoid a Flutter dependency
* **BREAKING CHANGE** `OfflineFirstWithRestRepository#offlineQueueHttpClientRequestSqliteCacheManager` is now `OfflineFirstWithRestRepository#offlineQueueManager`
* **BREAKING_CHANGE** `offlineQueueManager` is required to create `BrickOfflineFirstWithRestRepository`. To migrate without recreating the queue database, pass RestRequestSqliteCacheManager('brick_offline_queue.sqlite', databaseFactory)

## 1.0.0

* Integrate new `OfflineFirstPolicy`s to the `RestOfflineQueueClient`

## 0.0.2

* Support new policies for skipping cache or requesting data. See [brick_offline_first's change notes](https://github.com/GetDutchie/brick/blob/main/packages/brick_offline_first/CHANGELOG.md) for how to migrate the breaking changes.

## 0.0.1

* **BREAKING CHANGE** `SqliteProvider` and `Query` are no longer exported `offline_first_with_rest.dart`. Please import from `package:brick_sqlite/db.dart` and `package:brick_core/query.dart` respectively.
* Create package from `brick_offline_first`
* Initial
