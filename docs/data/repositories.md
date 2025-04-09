# Repositories

A repository routes application data to and from one or many providers. Repositories should only hold repository-specific logic and not pass interpreted data to its providers (e.g. the repository does not transform a `Query` into a SQL statement for its SQLite provider).

Brick **does not synchronize data automatically between providers**. Learn about how [to synchronize and reconile data between multiple providers on Synchronization](data/synchronization.md).

## Integrate

To use a repository seamlessly with a state management system like BLoCs without passing around context, access the repository as a singleton:

```dart
import 'package:brick_core/core.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:my_app/brick/brick.g.dart';
import 'package:sqflite/sqflite.dart' show databaseFactory;

// brick/repository.dart
class MyRepository extends OfflineFirstWithRestRepository<RestModel> {
  MyRepository._({
    required String baseEndpoint,
  }) : super(
    migrations: migrations,
    restProvider: RestProvider(
      'http://0.0.0.0:3000',
      modelDictionary: restModelDictionary,
    ),
    sqliteProvider: SqliteProvider(
      'my_brick_db_name.sqlite',
      databaseFactory: databaseFactory,
      modelDictionary: sqliteModelDictionary,
    ),
    offlineQueueManager: RestRequestSqliteCacheManager(
      'brick_offline_queue.sqlite',
      databaseFactory: databaseFactory,
    ),
  );
  factory MyRepository() => _singleton!;

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
// brick/repository.dart
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

## Creating a Custom Repository

There are several principles for repositories that should be considered beyond its implementation of `ModelRepository`:

- [ ] The repository only fetches data from providers
- [ ] The repository cannot (de)serialize models with a provider
- [ ] The repository does not preserve model states
- [ ] Every method returns from the same provider
- [ ] `Query#action` is applied when it does not exist on a `query` from arguments

To generate code for a custom repository, please see [brick_build](https://github.com/GetDutchie/brick/tree/main/packages/brick_build#repository).

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
