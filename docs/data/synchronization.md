# Synchronizing Between Multiple Sources

Repositories manage data between different providers, but keeping those providers in sync can be a challenge. While a repository manages different providers and consolidates requests to a single entrypoint, **Brick does not automatically sync changes between providers**. For example, while Client A may invoke `upsert<Pizza>(pepperoniPizza)` and notify REST, SQLite, and MemoryCache providers of a new `pepperoniPizza`, Client B will not receive this `pepperoniPizza` automatically. This synchronization is up to the implementation as remote providers vary in how they transmit data. Some examples of how to sync data:

* Set up a push notification system that notifies the client every time a change occurs in the API, triggering a resync to hydrate the results in the background
* Short poll the remote provider for new responses every x seconds and hydrate the results in the background
* Subscribe to a websockets channel and stream responses and hydrate the results in the background

It is strongly recommended to use a [string-based identifier for models created on the client](https://pub.dev/packages/uuid) and to index this value in the remote provider. Relying on a primary key generated within a remote table is not recommended, as instances created on the client can cause collisions.

## Reconciliation

Data will inevitably become out of sync between the local and remote providers. **Brick does not resolve these differences**. Your synchronization implementation should handle reconcilliation. Some examples of how to prioritize data:

### Single Source of Truth

Consider one provider the source of truth and **always** [overwrite data](https://github.com/GetDutchie/brick/blob/main/packages/brick_offline_first/lib/src/mixins/destructive_local_sync_from_remote_mixin.dart) from one provider to the other(s). While this is the simplest solution, do not ignore its perks: in a distributed system, a single source of truth is sensible architecture.

### Custom Hydrate

Persist updates based on specific field(s) between providers (looking to you, CS grads). The following is loose psuedo-code to illustrate clearly how an implementation *could* look.

```dart
abstract class BaseModel extends OfflineFirstModel {
  String get id;
}

class MyModel extends BaseModel {
  // This is our timestamp for when the record was updated.
  // This also expects other providers to deliver this model if a change has been reflected there.
  DateTime updatedAt;

  // A key to identify the record between all providers
  @Sqlite(unique: true)
  final String id;

  MyModel({this.id});

  // This hook exists for SqliteModels
  @override
  Future<void> beforeSave({provider, repository}) async => updatedAt = DateTime.now();
}

class MyRepository extends OfflineFirstRepository<BaseModel> {
  @override
  Future<List<_Model>> hydrate<_Model extends BaseModel>(
      {bool deserializeSqlite = true, query}) async {
    final remoteResults = await remoteProvider.get<_Model>(query: query);
    final localResults = await sqliteProvider.get<_Model>(query: query);
    // Sort by map to avoid expensive, repetitive .where`queries
    final localResultsById = localResults.fold({}, (acc, item) {
      acc[item.id] = item;
      return acc;
    });

    for (final remoteItem in remoteResults) {
      final localItem = localResultsById[remoteItem.id];
      // only persist the remote record if it has been modified after the local record
      // or if it's a new record from the remote provider
      if (localItem == null || localItem.updatedAt.isBefore(remoteItem.updatedAt)) {
        await sqliteProvider.upsert<_Model>(remoteItem);
        // store the result in other providers here, like memory cache, if desired
      }
    }

    // fetch the data again after it's been reconciled
    return sqliteProvider.get<_Model>(query: query);
  }
}
```

!> This example **does not** include deleting local records. As always, please review and appropriately adjust sample code to match your implementation before deploying to a production environment.
