# Migrating Between Major Versions

In preparation for Brick 4, `Query` is migrating away from loosely-defined arguments in favor of standardized fields that can be easily deprecated and discovered by analysis.

**`providerArgs` will be supported until Brick 4 is officially released**.

It is still recommended you migrate to the new `Query` for new features and long-term support.

## Improvements

- `Query#orderBy` will support association ordering and multiple values
- `Query` is constructed with `const`
- `Query#offset` no longer requires companion `limit` parameter
- `brick_sqlite` and `brick_supabase` support association ordering. For example, `Query(orderBy: [OrderBy.desc('assoc', associationField: 'name')])` on `DemoModel` will produce the following SQL statement:
  ```sql
  'SELECT DISTINCT `DemoModel`.* FROM `DemoModel` ORDER BY `DemoModelAssoc`.name DESC'
  ```
- `brick_supabase` supports advanced limiting. For example, `Query(limitBy: [LimitBy(1, evaluatedField: 'assoc'))` is the equivalent of `.limit(1, referencedTable: 'demo_model')`

## Universal Deprecations

| Old                                 | New               | Notes                                                                                                                                                                                                                                                                                                                                                           |
| ----------------------------------- | ----------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `Query(providerArgs: {'limit':})`   | `Query(limit:)`   | `limit` and `limitBy` may be used together, however, `limitBy` will only limit `evaluatedField:` associations                                                                                                                                                                                                                                                   |
| `Query(providerArgs: {'offset':})`  | `Query(offset:)`  |                                                                                                                                                                                                                                                                                                                                                                 |
| `Query(providerArgs: {'orderBy':})` | `Query(orderBy:)` | `orderBy` is now defined by a class that permits multiple commands. For example, `'orderBy': 'name ASC'` becomes `[OrderBy('name', ascending: true)]`. First-class Brick providers (SQLite and Supabase) also support association-based querying by declaring a `associationField:`. This `associationField` is optional in Supabase but required for `SQLite`. |

## Package-specific deprecations

### brick_graphql

| Old                                   | New                                                       | Notes |
| ------------------------------------- | --------------------------------------------------------- | ----- |
| `Query(providerArgs: {'context':})`   | `Query(forProviders: [GraphqlProviderQuery(context:)])`   |
| `Query(providerArgs: {'operation':})` | `Query(forProviders: [GraphqlProviderQuery(operation:)])` |

### brick_rest

| Old                                 | New                                                  | Notes |
| ----------------------------------- | ---------------------------------------------------- | ----- |
| `Query(providerArgs: {'request':})` | `Query(forProviders: [RestProviderQuery(request:)])` |       |

### brick_sqlite

| Old                                 | New                                                    | Notes |
| ----------------------------------- | ------------------------------------------------------ | ----- |
| `Query(providerArgs: {'collate':})` | `Query(forProviders: [SqliteProviderQuery(collate:)])` |
| `Query(providerArgs: {'having':})`  | `Query(forProviders: [SqliteProviderQuery(having:)])`  |
| `Query(providerArgs: {'groupBy':})` | `Query(forProviders: [SqliteProviderQuery(groupBy:)])` |

### brick_supabase

| Old                                                | New | Notes                                 |
| -------------------------------------------------- | --- | ------------------------------------- |
| `Query(providerArgs: {'limitReferencedTable':})`   |     | Removed in favor of `Query(limitBy:)` |
| `Query(providerArgs: {'orderByReferencedTable':})` |     | Removed in favor of `Query(orderBy:)` |

## Migrating from Brick 2 to Brick 3

Brick 3 removes the abstract packages since Sqflite has abstracted its Flutter dependency to [a "common" API](https://pub.dev/packages/sqflite_common).

`brick_offline_first_with_graphql_abstract`, `brick_offline_first_with_rest_abstract`, `brick_sqlite_abstract`, and `brick_offline_first_abstract` will remain on pub.dev since [publishing is forever](https://dart.dev/tools/pub/publishing#publishing-is-forever). While this change is internal, parent packages no longer export the contents of child packages. Some adjustments may need to be made.

### Breaking Changes

- Primary package files are renamed in line with `pub.dev` standards.
  ```shell
  for FILE in $(find "lib" -type f -name "*.dart"); do
    sed -i '' 's/package:brick_offline_first\/offline_first.dart/package:brick_offline_first\/brick_offline_first.dart/g' $FILE
    sed -i '' 's/package:brick_offline_first_with_rest\/offline_first_with_rest.dart/package:brick_offline_first_with_rest\/brick_offline_first_with_rest.dart/g' $FILE
    sed -i '' 's/package:brick_offline_first_with_graphql\/offline_first_with_graphql.dart/package:brick_offline_first_with_graphql\/brick_offline_first_with_graphql.dart/g' $FILE
    sed -i '' 's/package:brick_rest\/rest.dart/package:brick_rest\/brick_rest.dart/g' $FILE
    sed -i '' 's/package:brick_sqlite\/sqlite.dart/package:brick_sqlite\/brick_sqlite.dart/g' $FILE
    sed -i '' 's/package:brick_graphql\/graphql.dart/package:brick_graphql\/brick_graphql.dart/g' $FILE
  done
  ```
  - `brick_offline_first/offline_first.dart` is now `brick_offline_first/brick_offline_first.dart`
  - `brick_offline_first_with_rest/offline_first_with_rest.dart` is now `brick_offline_first_with_rest/brick_offline_first_with_rest.dart`
  - `brick_offline_first_with_graphql/brick_offline_first_with_graphql.dart` is now `brick_offline_first_with_graphql/brick_offline_first_with_graphql.dart`
  - `brick_graphql/graphql.dart` is now `brick_rest/brick_graphql.dart`
  - `brick_rest/rest.dart` is now `brick_rest/brick_rest.dart`
  - `brick_sqlite/sqlite.dart` is now `brick_sqlite/brick_sqlite.dart`
- `brick_sqlite_abstract/db.dart` is now `brick_sqlite/db.dart`. `brick_sqlite_abstract/sqlite_model.dart` and `brick_sqlite_abstract/annotations.dart` are now exported by `brick_sqlite/brick_sqlite.dart`
  ```shell
  for FILE in $(find "lib" -type f -name "*.dart"); do
    sed -i '' 's/package:brick_sqlite_abstract\/annotations.dart/package:brick_sqlite\/brick_sqlite.dart/g' $FILE
    sed -i '' 's/package:brick_sqlite_abstract\/sqlite_model.dart/package:brick_sqlite\/brick_sqlite.dart/g' $FILE
    sed -i '' 's/package:brick_sqlite_abstract\/db.dart/package:brick_sqlite\/db.dart/g' $FILE
  done
  ```
- `RestAdapter.firstWhereOrNull` and `GraphqlAdapter.firstWhereOrNull` have been removed. Instead `import 'package:collection/collection.dart';` and use the bundled `Iterable` extension `.firstWhereOrNull`
- `RestAdapter.enumValuesByName` and `GraphqlAdapter.enumValuesByName` have been removed. Instead use Dart 2.15's built-in `<enum>.values.byName`
- The minimum Dart version has been increased to 2.18
- `providerArgs` in Brick Rest have changed: `'topLevelKey'` and `'headers'` and `'supplementalTopLevelData'` have been removed (use `'request'`) and `'request'` now accepts a `RestRequest` instead of the HTTP method string.
- `providerArgs` in Brick Graphql have changed: `'document'` and `'variables'` have been removed. Instead, use `'operation'`.
- `analyzer` is now `>= 5`

### Brick Offline First with Graphql

- `FieldRename`, `Graphql` `GraphqlProvider`, and `GraphqlSerializable` are no longer exported by `offline_first_with_graphql.dart`. Instead, import these file from `package:brick_graphql/brick_graphql.dart`

### Brick Offline First with Rest

- `FieldRename`, `Rest`, `RestProvider`, and `RestSerializable` are no longer exported by `offline_first_with_rest.dart`. Instead, import these file from `package:brick_rest/brick_rest.dart`
- `OfflineFirstWithRestRepository#reattemptForStatusCodes` has been removed from instance-level access. The constructor argument forwards to the `RestOfflineQueueClient`, where it can be accessed if needed.
- `OfflineFirstWithRestRepository#throwTunnerNotFoundExceptions` has been removed. This value was duplicated from `offlineQueueManager`; the queue manager is where the property exclusively lives now.

#### Improvements

- Listen for SQLite changes via `OfflineFirstWithRestRepository#subscribe`

### Brick Graphql

This breaking change migration is less automatable. The script below is a best attempt and should be manually confirmed after running.

```shell
for FILE in $(find "lib" -type f -name "*.dart"); do
  # `sed` regex capture may work for you; it didn't on Mac for me
  # sed -i '' "s/\'document\': (.*)/\'operation\': GraphqlOperation\(document: \1\) \/\/ TODO verify migration to GraphqlOperation /g" $FILE
  perl -0777 -i -pe "s/'document': (.*)/'operation': GraphqlOperation\(document: \1\) \/\/ TODO verify migration to GraphqlOperation /igs" $FILE
  # sed -i '' "s/\'variables\': (.*)/\'operation\': GraphqlOperation\(variables: \1\) \/\/ TODO verify migration to GraphqlOperation /g" $FILE
  perl -0777 -i -pe "s/'variables': (.*)/'operation': GraphqlOperation\(variables: \1\) \/\/ TODO verify migration to GraphqlOperation /igs" $FILE
done
```

#### `providerArgs['document']`

This has been consolidated to `'operation'`. For example: `providerArgs: { 'operation': GraphqlOperation(document: r'''mutation UpdateUser(id: ....)''')}`.

#### `providerArgs['variables']`

This has been consolidated to `'operation'`. For example: `providerArgs: { 'operation': GraphqlOperation(variables: {'id': '1'}) }`.

### Brick Rest

This breaking change migration is less automatable. The script below is a best attempt and should be manually confirmed after running.

```shell
for FILE in $(find "lib" -type f -name "*.dart"); do
  # `sed` regex capture may work for you; it didn't on Mac for me
  # sed -i '' "s/\'request\': (.*)/\'request\': RestRequest\(method: \1\) \/\/ TODO verify migration to RestRequest /g" $FILE
  perl -0777 -i -pe "s/'request': (.*)/'request': RestRequest\(method: \1\) \/\/ TODO verify migration to RestRequest /igs" $FILE
  # sed -i '' "s/\'headers\': (.*)/\'request\': RestRequest\(headers: \1\) \/\/ TODO verify migration to RestRequest /g" $FILE
  perl -0777 -i -pe "s/'headers': (.*)/'request': RestRequest\(headers: \1\) \/\/ TODO verify migration to RestRequest /igs" $FILE
  # sed -i '' "s/\'topLevelKey\': (.*)/\'request\': RestRequest\(topLevelKey: \1\) \/\/ TODO verify migration to RestRequest /g" $FILE
  perl -0777 -i -pe "s/'topLevelKey': (.*)/'request': RestRequest\(topLevelKey: \1\) \/\/ TODO verify migration to RestRequest /igs" $FILE
  # sed -i '' "s/\'supplementalTopLevelData\': (.*)/\'request\': RestRequest\(supplementalTopLevelData: \1\) \/\/ TODO verify migration to RestRequest /g" $FILE
  perl -0777 -i -pe "s/'supplementalTopLevelData': (.*)/'request': RestRequest\(supplementalTopLevelData: \1\) \/\/ TODO verify migration to RestRequest /igs" $FILE
done
```

#### `providerArgs['request']`

This key now accepts a `RestRequest` class instead of an HTTP method name.

#### `providerArgs['headers']`

This has been consolidated to `'request'`. For example: `providerArgs: { 'request': RestRequest(headers: {'Authorization': 'Bearer'})}`.

#### `providerArgs['topLevelKey']`

This has been consolidated to `'request'`. For example: `providerArgs: { 'request': RestRequest(topLevelKey: 'myKey' )}`.

#### `providerArgs['supplementalTopLevelData']`

This has been consolidated to `'request'`. For example: `providerArgs: { 'request': RestRequest(supplementalTopLevelData: {'myKey': {'myData': 1}}) }`.

#### `RestSerializable(requestTransformer:)`

- `RestSerializable`'s `fromKey` and `toKey` have been consolidated to `RestRequest(topLevelKey:)`
- `RestSerializable(endpoint:)` has been replaced in this release by `RestSerializable(requestTransformer:)`. It will be painful to upgrade though with good reason.

1. Strongly-typed classes. `endpoint` was a string, which removed analysis in IDEs, permitting errors to escape during runtime. With endpoints as classes, `Query` and `instance` objects will receive type hinting.
1. Fine control over REST requests. Define on a request-level basis what key to pull from or push to. Declare specific HTTP methods like `PATCH` in a class that manages request instead of in distributed `providerArgs`.
1. Future-proof development. Enhancing REST's configuration will be on a class object instead of in untyped string keys on `providerArgs`. The REST interface is consolidated to this subclass.

Since all APIs are different, and `endpoint` used stringified code, the migration cannot be scripted for all users. Instead, examples are provided below to illustrate how to refactor from Brick 2's `endpoint` to Brick 3's `requestTransformer`. Some examples:

```dart
// BEFORE
@ConnectOfflineFirstWithRest(
  restConfig: RestSerializable(
    endpoint: '"/users";'
    fromKey: 'users',
  )
)

// AFTER
class UserRequestTransformer extends RestRequestTransformer {
  final get = const RestRequest(url: '/users', topLevelKey: 'users');
  const UserRequestTransformer(Query? query, RestModel? instance) : super(query, instance);
}
@ConnectOfflineFirstWithRest(
  restConfig: RestSerializable(
    requestTransformer: UserRequestTransformer.new,
  )
)
```

Some cases are more complex:

```dart
// BEFORE
@ConnectOfflineFirstWithRest(
  restConfig: RestSerializable(
    endpoint: r'''{
      if (query?.action == QueryAction.delete) return "/users/${instance.id}";

      if (query?.action == QueryAction.get &&
          query?.providerArgs.isNotEmpty &&
          query?.providerArgs['limit'] != null) {
            return "/users?limit=${query.providerArgs['limit']}";
      }

      return "/users";
    }''';
  )
)

// AFTER
class UserRequestTransformer extends RestRequestTransformer {
  RestRequest? get get {
    if (query?.providerArgs.isNotEmpty && query.providerArgs['limit'] != null) {
      return RestRequest(url: "/users?limit=${query.providerArgs['limit']}");
    }
    const RestRequest(url: '/users');
  }

  final delete = RestRequest(url: '/users/${instance.id}');

  const UserRequestTransformer(Query? query, RestModel? instance) : super(query, instance);
}

@ConnectOfflineFirstWithRest(
  restConfig: RestSerializable(
    requestTransformer: UserRequestTransformer.new,
  )
)
```

:bulb: For ease of illustration, the code is provided as if the transformer and model logic live in the same file. It's strongly recommended to include the request transformer logic in its own, colocated file (such as `user.model.request.dart`).

## Migrating from Brick 1 to Brick 2

Brick 2 focuses on Brick problems encountered at scale. While the primary refactor was the abstraction of domain-specific code from generalized domains, this major release also includes a new GraphQL domain, resolution of community pain points, and a few neat tricks.

### Breaking Changes

- Brick no longer expects `lib/app`; it now expects `lib/brick`.
  ```shell
  mv -r lib/app lib/brick
  ```
- Models are no longer discovered in `lib/app/models`; they are now discovered via `*.model.dart`. They can live in any directory within `lib` and have any prefix. (#38)
  ```shell
  for FILENAME in lib/brick/models/*; do mv $FILENAME "${FILENAME/dart/model.dart}"; done
  ```
- `brick_offline_first` is now, fundamentally, `brick_offline_first_with_rest`. `brick_offline_first` now serves as an abstract bedrock for offline domains.
  ```shell
  sed -i '' 's/brick_offline_first:/brick_offline_first_with_rest:/g' pubspec.yaml
  for FILE in $(find "lib" -type f -name "*.dart"); do sed -i '' 's/package:brick_offline_first/package:brick_offline_first_with_rest/g' $FILE; done
  ```
- `brick_offline_first_abstract` is now `brick_offline_first_with_rest_abstract`
  ```shell
  sed -i '' 's/brick_offline_first_abstract:/brick_offline_first_with_rest_abstract:/g' pubspec.yaml
  for FILE in $(find "lib" -type f -name "*.dart"); do sed -i '' 's/package:brick_offline_first_abstract/package:brick_offline_first_with_rest_abstract/g' $FILE; done
  ```
- `rest` properties have been removed from `OfflineFirstException`. Use `OfflineFirstWithRestException` instead from `brick_offline_first_with_rest`.
- `OfflineFirstRepository#get(requireRemote:` and `OfflineFirstRepository#getBatched(requireRemote:` has been removed. Instead, use `policy: OfflineFirstGetPolicy.alwaysHydrate`
- `OfflineFirstRepository#get(hydrateUnexisting:` has been removed. Instead, use `policy: OfflineFirstGetPolicy.awaitRemoteWhenNoneExist` (this is the default).
- `OfflineFirstRepository#get(alwaysHydrate:` has been removed. Instead, use `policy: OfflineFirstGetPolicy.alwaysHydrate`.

### Fun Changes

- Utilize `OfflineFirstDeletePolicy`, `OfflineFirstGetPolicy`, and `OfflineFirstUpsertPolicy` to override default behavior. Specific policies will throw an exception when the remote responds with an error (and throw that error) or skip the queue. Existing default behavior is maintained.
- `OfflineFirstRepository#delete` now supports requiring a successful remote with `OfflineFirstDeletePolicy.requireRemote`. If the app is offline, normally handled exceptions (`ClientException` and `SocketException`) are `rethrow`n. (#182)
- `OfflineFirstRepository#upsert` now supports requiring a successful remote with `OfflineFirstUpsertPolicy.requireRemote`. If the app is offline, normally handled exceptions (`ClientException` and `SocketException`) are `rethrow`n.

### New Packages

- [`brick_graphql`](../packages/brick_graphql). The `GraphqlProvider` interfaces with a GraphQL backend. It uses [gql's Link system](https://github.com/gql-dart/gql/tree/master/links) to integrate with other community-supported functionality. That, and all your variables are autogenerated on every request.
- [`brick_graphql_generators`](../packages/brick_graphql_generators). The perfect companion to `brick_graphql`, this thin layer around `brick_rest_generators` battle-tested core compiles adapters for the GraphQL domain.
- [`brick_json_generators`](../packages/brick_json_generators). The experienced core separated from `brick_rest_generators` permits more code reuse and package creation for JSON-serving remote providers.
- [`brick_offline_first_build`](../packages/brick_offline_first_build). Abstracted from the experienced core of `brick_offline_first_with_rest_build`, these helper generators and utils simplify adding offline capabilites to a domain.
- [`brick_offline_first_with_graphql`](../packages/brick_offline_first_with_graphql). Utilize the GraphQL provider with SQLite and Memory cache. This is a near mirror of `brick_offline_first_with_rest`, save for a few exceptions. First, the OfflineQueueLink must be inserted in the appropriate position in [your client's Link chain](../packages/brick_offline_first_with_graphql#GraphqlOfflineQueueLink). Second, `OfflineFirstWithGraphqlRepository#subscribe` permits streaming updates, including notifications after local providers are updated.
- [`brick_offline_first_with_graphql_abstract`](../packages/brick_offline_first_with_graphql_abstract). Annotations for the GraphQL domain without including Flutter.
- [`brick_offline_first_with_graphql_build`](../packages/brick_offline_first_with_graphql_build). The culmination of `brick_graphql_generators` and `brick_offline_first_build`.

## Migrating to Brick 1 (Null Safety)

### Breaking Changes

- Because `required` is now a reserved Dart keyword, `required` in `WherePhrase`, `WhereCondition`, `And`, `Or`, and `Where` has been renamed to `isRequired`.
- Field types in models `Set<Future<OfflineFirstModel>>`, `List<Future<OfflineFirstModel>>`, and `Future<OfflineFirstModel>` are no longer supported. Instead, use `Set<OfflineFirstModel>`, `List<OfflineFirstModel>`, and `OfflineFirstModel` (the adapters will `await` each).
- `StubOfflineFirstWithRest` is functionally changed. SQLiteFFI has satisfied much of the original stubbing required for this class, and http's testing.dart library is sufficient to not require Mockito. Therefore, `verify` calls will no longer be effective in testing on the client. Instead, pass `StubOfflineFirstWithRest.client` to your `RestProvider#client` with the response values. `StubOfflineFirstWithRestModel` has been removed. Please review [Offline First Testing](https://greenbits.github.io/brick/#/offline_first/testing) for implementation examples.

### Improvements

- `brick_offline_first`: Priority for the next job to process from the queue - when processing requests in serial - has changed from `'$HTTP_JOBS_CREATED_AT_COLUMN ASC, $HTTP_JOBS_ATTEMPTS_COLUMN DESC, $HTTP_JOBS_UPDATED_AT ASC'` to `'$HTTP_JOBS_CREATED_AT_COLUMN ASC'`; this uses the job column introduced in 0.0.7 (26 May 2020) and will not affect any implementations using 0.0.7 or higher.
- `brick_offline_first`: `RequestSqliteCache` no longer queries cached requests based on headers; requests are rediscovered based on their encoding, URL, request method, and body. Rehydrated (reattempted) requests will be hydrated with headers from the original request.
- Every package is null safe. There is one outstanding dependency - `build_config` - that needs to be migrated, so the generators are not technically "null safe". However, these are dev dependencies and `build_config` isn't imported into Dart code, so upgrading it will be changing numbers.
