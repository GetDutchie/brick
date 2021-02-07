# Repositories

A repository routes application data to and from one or many providers. Repositories should only hold repository-specific logic and not pass interpreted data to its providers (e.g. the repository does not transform a `Query` into a SQL statement for its SQLite provider).

## Integrate

To use a repository seamlessly with a state management system like BLoCs without passing around context, access the repository as a singleton:

```dart
import 'package:brick_core/core.dart';
import 'package:brick_rest/rest.dart';
import 'package:my_app/app/brick.g.dart' show restModelDictionary;

// app/repository.dart
class MyRepository extends SingleProviderRepository<RestModel> {
  MyRepository._({
    String baseEndpoint,
  }) : super(
    RestProvider(baseEndpoint, modelDictionary: restModelDictionary),
  );
  factory MyRepository() => _singleton;

  static MyRepository create(String baseEnpoint) {
    _singleton = MyRepository._(
      baseEndpoint: baseEndpoint,
    );
  }
}
```

However, the singleton is not required (such as via an `InheritedWidget`). Multiple repositories can also manage different data streams. Each repository should have only one type of a provider (e.g. a repository cannot have two `RestProvider`s but it can have a `RestProvider`, a `SqliteProvider`, and a `MemoryCacheProvider`).

Once the app is initialized, it is recommended to immediately run `#initialize`. Repositories will execute setup functions (e.g. running SQL migrations) exactly once within this method:

```dart
// configure and initialize at the application's entrypoint
class BootScreenState extends State<BootScreen> {
  ...
  initState() {
    super.initState();
    // initialize only needs to be run once:
    MyRepository.create("https://api.com");
    MyRepository().initialize();
  }
}
```

## Access

End-implementation uses (e.g. a Flutter application) should `extend` an abstract repository and pass arguments to `super`. If custom methods need to be added, they can be written in the application-specific repository and not the abstract one. Application-specific `brick.g.dart` are also imported:

```dart
// app/repository.dart
import 'brick.g.dart' show migrations, restModelDictionary;
class MyRepository extends OfflineFirstRepository {
  MyRepository({
    String baseEndpoint,
  }) : super(
    migrations: migrations,
    restProvider: RestProvider(baseEndpoint, modelDictionary: restModelDictionary),
  );
}
```

## Syncing Changes Between Providers

While a repository manages different providers and consolidates requests to a single entrypoint, **Brick does not automatically sync changes between providers**. For example, while Client A may invoke `upsert<Pizza>(pepperoniPizza)` and notify REST, SQLite, and MemoryCache providers of a new `pepperoniPizza`, Client B will not receive this `pepperoniPizza` automatically. This synchronization is up to the implementation as remote providers vary in how they transmit data. Some examples of how to sync data:

* Set up a push notification system that notifies the client every time a change occurs in the API, triggering a resync to hydrate the results in the background
* Short poll the remote provider for new responses every x seconds and hydrate the results in the background
* Subscribe to a websockets channel and stream responses and hydrate the results in the background

It is strongly recommended to use a [string-based identifier for models created on the client](https://pub.dev/packages/uuid) and to index this value in the remote provider. Relying on a primary key generated within a remote table is not recommended, as instances created on the client can cause collisions.

### Reconciliation

Data will inevitably become out of sync between the local and remote providers. **Brick does not natively resolve these differences**. Your synchronization implementation should handle reconcilliation. Some examples of how to prioritize data:

* Consider one provider the source of truth and **always** [overwrite data](https://github.com/greenbits/brick/blob/master/packages/brick_offline_first/lib/src/mixins/destructive_local_sync_from_remote_mixin.dart) from one provider to the other(s). While this is the simplest solution, do not ignore its perks: in a distributed system, a single source of truth is sensible architecture.
* Persist updates based on specific field(s) between providers (I'm sure there's a term for this; looking to you, CS grads). The following is loose, psuedo code to illustrate clearly how an implementation *could* look. It should not be copy/pasted line-for-line.
    ```dart
    class MyModel extends OfflineFirstModel {
      // This is our timestamp for when the record was updated.
      // This also expects other providers to deliver this model if a change has been reflected there.
      DateTime updatedAt;

      // A key to identify the record between all providers
      @Sqlite(unique: true)
      final String id;

      // This hook exists for SqliteModels
      @override
      Future<void> beforeSave({provider, repository}) async => updatedAt = DateTime.now();
    }

    class MyRepository extends OfflineFirstRepository {
      @override
      Future<List<_Model>> hydrate<_Model>({Query query}) async {
        final remoteResults = await remoteProvider.get<_Model>(query: query);
        final localResults = await sqliteProvider.get<_Model>(query: query);

        for (final remoteItem in remoteResults) {
          final localItem = localResults.firstWhere((i) => i.id == remoteItem.id, orElse: () => null);
          // only persist the remote record if it has been modified after the local record
          // or if it's a new record from the remote provider
          if (localItem == null || localItem.updatedAt.isBefore(remoteItem.updatedAt)) {
            await sqliteProvider.upsert(remoteItem);
            // store the result in other providers here, like memory cache, if desired
          }
        }

        // fetch the data again after it's been reconciled
        return sqliteProvider.get<_Model>(query: query);
      }
    }
    ```

## Creating a Custom Repository

There are several principles for repositories that should be considered beyond its implementation of `ModelRepository`:

* [ ] The repository only fetches data from providers
* [ ] The repository cannot (de)serialize models with a provider
* [ ] The repository does not preserve model states
* [ ] Every method returns from the same provider
* [ ] `Query#action` is applied when it does not exist on a `query` from arguments

To generate code for a custom repository, please see [brick_build](https://github.com/greenbits/brick/tree/master/packages/brick_build#repository).

### Methods

While repositories share method names with providers, they are distinct from providers in that they are synthesizers:

```dart
class MyRestAndMemoryRepository implements ModelRepository {
  get<_Model>({Query query}) async {
    // check one provider for data
    if (memoryProvider.has(query)) return memoryProvider.get<_Model>(query: query);

    // fetch data from another provider
    final restResults = await restProvider.get<_Model>(query: query);

    // ensure that the data is accessible across all providers
    restResults.forEach((r) => memoryProvider.upsert<_Model>(r));

    // now that the data is inserted, we're confident in a refetch from the provider
    // without checking for existence
    return memoryProvider.get<_Model>(query: query);
  }
}
```

!> When juggling multiple providers, consistently resolve with data from the same provider across all methods. When in doubt, prioritize data from a local provider:

```dart
// BAD:
get() {
  ...
  return sqliteProvider.get();
}
upsert() {
  ...
  return memoryProvider.upsert();
}

// GOOD:
get() {
  ...
  return sqliteProvider.get();
}
upsert() {
  ...
  return sqliteProvider.upsert();
}
```

Repositories should be the _only_ class that can call a provider method. This enforces a consistent data stream throughout an application.

#### Applying `Query#action`

Before passing a query to a provider method, it is recommended for the repository to apply an action to a query if it doesn't otherwise exist. For example, while `RestProvider#upsert` accepts both new and updated instances, its invoking repository has separate methods for `update` and `insert`:

```dart
class MyRepository {
  insert<_Model>(_Model instance, {Query query}) {
    query = (query ?? Query()).copyWith(action: QueryAction.insert);
    await restProvider.upsert<_Model>(instance, query: query);
  }

  update(_Model instance, {Query query}) {
    query = (query ?? Query()).copyWith(action: QueryAction.update);
    await restProvider.upsert<_Model>(instance, query: query);
  }
}

class RestProvider {
  upsert<_Model>(_Model instance, {Query query}) {
    final headers = {};
    if (query.action.update) headers['method'] = "PUT";
    if (query.action.insert) headers['method'] = "POST";
  }
}
```

## FAQ

### How can I (de)serialize a model with a repository?

Repositories do not have model dictionaries because they do not interpret sources. Providers are the only classes with access to adapters.
