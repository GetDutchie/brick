## 4.0.1

- Fix never-completing Future on `#reset` (#552)

## 4.0.0

- **BREAKING CHANGE** Require `brick_core: >= 2.0.0` and remove support for `Query(providerArgs:)`; see [migration steps](https://github.com/GetDutchie/brick/issues/510)
- Dart minimum SDK is updated to `3.4.0`
- All dependency restrictions are updated to include the minimum released version.

## 3.4.0

- Upgrade `brick_core` to `1.3.0`
- Update analysis to modern lints
- Change `OfflineFirstRepository#exists` behavior: the check against memory cache will only return `true` if results have been found, otherwise it will continue to the SQLite provider
- Forward errors from `OfflineFirstRepository#subscribe` streams to their callers (@sonbs21 #484)

## 3.3.0

- Added `subscriptionByQuery` to `OfflineFirstRepository#notifySubscriptionsWithLocalData` to pass a custom map of `StreamControllers`
- Add `GetFirstMixin` for convenient retrieval of the first results of `OfflineFirstRepository#get`
- Close all controllers in `OfflineFirstRepository#subscriptions` and clear the map on `OfflineFirstRepository#reset`

## 3.2.1

- Add `OfflineFirstSerdes#toSupabase` abstract method

## 3.2.0

- Apply desired policy to all association fetches during `OfflineFirstRepository#get` requests. Fixes #371.
- Upgrade minimum Dart to 2.18

## 3.1.0

- Apply standardized lints
- Respect `awaitRemote` policy for `OfflineFirstRepository#get` - fixes a bug where an instance in memory cache would early-return before hitting remote despite the requested `await` or `alwaysHydrate` policy

## 3.0.3

- Support Dart 3

## 3.0.2

- Permit awaiting remote on first `get` in `OfflineFirstRepository#subscribe`. While the default for the `policy` argument of this method has changed, it was unapplied (`.localOnly` was used regardless).

## 3.0.1

- Resolve concurrent modification error when looping through subscriptions

## 3.0.0

- Remove `brick_sqlite_abstract`
- Remove `brick_offline_first_abstract`
- Add `OfflineFirstRepository#subscribe`. The query provided when invoked is stored on the repository. Whenever data is locally mutated with `storeRemoteResults` or `upsert` or `delete` that matches one of these stored queries, the stream receives the latest data for the query. It is strongly recommended to store the subscription after creating the stream and listening to it; cancelling the stream will close it and remove the stream to prevent memory leaks.
- Add `fieldsToOfflineFirstRuntimeDefinition` to `OfflineFirstAdapter`. This exposes `@OfflineFirst(where` configuration to repositories
- Add `applyToRemoteDeserialization` to `@OfflineFirst`. When `true` (the default and existing behavior), deserializing methods will query based on `where` configuration

## 2.1.2

- Set default of 5 seconds for `RequestSqliteCacheManager#processingInterval`

## 2.1.1

- Include type argument on `_upsertLocal` within `#upsert`

## 2.1.0

- Loosen dependency restrictions to major versions
- Remove Flutter dependency by upgrading `brick_sqlite`

## 2.0.0

- **BREAKING CHANGE** `requireRemote` has been removed from `get()` and `getBatched()`. Instead, use `policy: OfflineFirstGetPolicy.alwaysHydrate`
- **BREAKING CHANGE** `hydrateUnexisting` has been removed from `get()`. Instead, use `policy: OfflineFirstGetPolicy.awaitRemoteWhenNoneExist` (this is the default).
- **BREAKING CHANGE** `alwaysHydrate` has been removed from `get()`. Instead, use `policy: OfflineFirstGetPolicy.alwaysHydrate`.
- **BREAKING CHANGE** This package no longer includes the `OfflineFirstWithRest` domain. Please add `brick_offline_first_with_rest: any` to your `pubspec.yaml` and update package imports appropriately.
- Use forked `brick_offline_first_with_PROVIDER_abstract` packages
- **BREAKING CHANGE** `rest` properties have been removed from `OfflineFirstException`. Use `OfflineFirstWithRestException` instead from `brick_offline_first_with_rest`.
- Add `GraphqlOfflineRequestQueue` to support offline caching within the `GraphqlProvider`
- Add `applyPolicyToQuery` to `OfflineFirstRepository` to add the policy before requests are made to remote providers.
- Add `OfflineFirstDeletePolicy`, `OfflineFirstGetPolicy`, and `OfflineFirstUpsertPolicy` to override default behavior
- `delete` now supports requiring a successful remote with `OfflineFirstDeletePolicy.requireRemote`. If the app is offline, normally handled exceptions (`ClientException` and `SocketException`) are `rethrow`n. (#182)
- `upsert` now supports requiring a successful remote with `OfflineFirstUpsertPolicy.requireRemote`. If the app is offline, normally handled exceptions (`ClientException` and `SocketException`) are `rethrow`n.
- Rename `RequestSqliteCacheManager` to `RestRequestSqliteCacheManager`
- Rename `OfflineQueueHttpClient` to `RestOfflineQueueClient`
- Rename `OfflineRequestQueue` to `RestOfflineRequestQueue`

## 2.0.0-rc.4

- Add `applyPolicyToQuery` to `OfflineFirstRepository` to add the policy before requests are made to remote providers.

## 2.0.0-rc.3

- Add `OfflineFirstDeletePolicy`, `OfflineFirstGetPolicy`, and `OfflineFirstUpsertPolicy` to override default behavior
- `delete` now supports requiring a successful remote with `OfflineFirstDeletePolicy.requireRemote`. If the app is offline, normally handled exceptions (`ClientException` and `SocketException`) are `rethrow`n. (#182)
- `upsert` now supports requiring a successful remote with `OfflineFirstUpsertPolicy.requireRemote`. If the app is offline, normally handled exceptions (`ClientException` and `SocketException`) are `rethrow`n.
- **BREAKING CHANGE** `requireRemote` has been removed from `get()` and `getBatched()`. Instead, use `policy: OfflineFirstGetPolicy.alwaysHydrate`
- **BREAKING CHANGE** `hydrateUnexisting` has been removed from `get()`. Instead, use `policy: OfflineFirstGetPolicy.awaitRemoteWhenNoneExist` (this is the default).
- **BREAKING CHANGE** `alwaysHydrate` has been removed from `get()`. Instead, use `policy: OfflineFirstGetPolicy.alwaysHydrate`.

## 2.0.0-rc.2

- **BREAKING CHANGE** This package no longer includes the `OfflineFirstWithRest` domain. Please add `brick_offline_first_with_rest: any` to your `pubspec.yaml` and update package imports appropriately.
- Use forked `brick_offline_first_with_PROVIDER_abstract` packages
- **BREAKING CHANGE** `rest` properties have been removed from `OfflineFirstException`. Use `OfflineFirstWithRestException` instead from `brick_offline_first_with_rest`.

## 2.0.0-rc.1

- Add `GraphqlOfflineRequestQueue` to support offline caching within the `GraphqlProvider`
- Rename `RequestSqliteCacheManager` to `RestRequestSqliteCacheManager`
- Rename `OfflineQueueHttpClient` to `RestOfflineQueueClient`
- Rename `OfflineRequestQueue` to `RestOfflineRequestQueue`

## 1.1.0

- Carry `providerArgs` from query when using `getBatched` (#200)
- Add Flutter Lints

## 1.0.0

- Null safety
- Priority for the next job to process from the queue - when processing requests in serial - has changed from `'$HTTP_JOBS_CREATED_AT_COLUMN ASC, $HTTP_JOBS_ATTEMPTS_COLUMN DESC, $HTTP_JOBS_UPDATED_AT ASC'` to `'$HTTP_JOBS_CREATED_AT_COLUMN ASC'`; this uses the job column introduced in 0.0.7 (26 May 2020) and will not affect any implementations using 0.0.7 or higher.
- `RequestSqliteCache` no longer queries cached requests based on headers; requests are rediscovered based on their encoding, URL, request method, and body. Rehydrated (reattempted) requests will be hydrated with headers from the original request.
- **BREAKING CHANGE** Field types in models `Set<Future<OfflineFirstModel>>`, `List<Future<OfflineFirstModel>>`, and `Future<OfflineFirstModel>` are no longer supported. Instead, use `Set<OfflineFirstModel>`, `List<OfflineFirstModel>`, and `OfflineFirstModel` (the adapters will `await` each).
- **BREAKING CHANGE** `StubOfflineFirstWithRest` is functionally changed. SQLiteFFI has satisfied much of the original stubbing required for this class, and http's testing.dart library is sufficient to not require Mockito. Therefore, `verify` calls will no longer be effective in testing on the client. Instead, pass `StubOfflineFirstWithRest.client` to your `RestProvider#client` with the response values. `StubOfflineFirstWithRestModel` has been removed. Please review [Offline First Testing](https://engineering.dutchie.com/brick/#/offline_first/testing) for implementation examples.
- Do not reprocess queue requests during a single attempt. Server response times may be greater than the reattempt timer; in these situations, requests should remain locked.
- Introduce mutex around processing in the `OfflineRequestQueue`. This will avoid simultaneous DB writes on different isolates\* while a previous operation is still performing.

\*Or sub routines? Microtasks? It's unclear how Timer moves its work to the background or how to force it to remain in the original "thread."

## 0.1.2

- Add [`mixins.dart`](README.md#mixins) for non essential but still regularly requested features that depend on a specific format of remote data or are useful variations of existing features. `DeleteAllMixin` and `DestructiveLocalSyncFromRemoteMixin` are the first two such mixins.
- Expose `RequestSqliteCache#findRequestInDatabase` for subclass methods. (#111)

## 0.1.1

- Gracefully handle `SocketException` errors when the application is offline
- Call `exists` in `OfflineFirstRepository#get` after the memory provider has already been queried. This method can query the SqliteProvider which is an unnecessary database call when the model exists in the memory provider.
- RequestSqliteCacheManager: access SQLite db safely to [avoid race conditions](https://github.com/tekartik/sqflite/blob/master/sqflite/doc/opening_db.md#prevent-database-locked-issue)
- RequestSqliteCacheManager: refactor database path. This does not change the database's existing path as the use of `getDatabasesPath()` in the implementation was duplicating [default functionality](https://github.com/tekartik/sqflite/tree/master/sqflite#opening-a-database)

## 0.1.0

- **BREAKING CHANGE** One-to-many and many-to-many SQLite associations are no longer stored as JSON-encoded strings (i.e. `[1, 2, 3]` in a varchar column). Join tables are now generated by Brick. To convert existing data, please refer to the [brick_sqlite CHANGELOG notes](https://github.com/GetDutchie/brick/blob/main/packages/brick_sqlite/CHANGELOG.md#010). If you do not care about existing migration and have not widely distributed your app, simply delete all existing migrations, delete all existing app installs, and run `flutter pub run build_runner build` in your project root.
- Fixes undefined method when calling `hydrate` offline. The remote provider would return null, and SQLite/memory cache would not adequately store results. Instead, when a null response is returned from the remote provider, subsequent provider updates are skipped.
- Adds a configurable option to throw on status codes that are normally swallowed in `OfflineFirstWithRest#upsert` (such as 404, 50x).

## 0.0.7

- Add `reattemptForStatusCode` for `OfflineFirstWithRestRepository#upsert` requests. When the response matches a reattempt code, an exception is not thrown and the instance is returned instead.
- Add `501` to `OfflineQueueHttpClient#reattemptForStatusCode` defaults
- Insert a `created_at` column for the OfflineRequestQueue.
- Fix a bug where an HTTP request would be immediately duplicated. In some race conditions, the interval timer would immediately recreate the request after it was inserted and before the HTTP response was received.
- Bump sqflite to 1.3.0
- **BREAKING CHANGE** Remove StubSqlite from StubOfflineFirst. SQLite should be migrated by the repository and data upserted as it would be within the app. `StubOfflineFirst` is now only concerned with REST responses.
- **BREAKING CHANGE** Remove interval from `OfflineRequestQueue` in favor of declaring it once on `RequestSqliteCacheManager`. To migrate, pass a custom `RequestSqliteCacheManager` with the interval time to the `OfflineFirstWithRestRepository` constructor.
- **BREAKING CHANGE** `StubOfflineFirstWithRest` must be invoked synchronously (in order to run migrations). When setting up stub in testing, call `await StubOfflineFirstWithRest(...).initialize()` or, in a cleaner syntax, `final stub = StubOfflineFirstWithRest(...); await stub.initialize()`. `initialize` will no longer be automatically invoked.

## 0.0.6

- Remove maximumRequests configuration for the OfflineFirstQueue. One request should be processed at a time in serial
- Optionally ignore Tunnel not found requests (these occur when connectivity exists but the queried endpoint is unreachable) when making repository requests
- Adds argument to repository to reattempt requests based on the status code from the response
- `OfflineRequestQueue#process` became a protected method
- Added `RequestSqliteCacheManager` to interact with the queue. This new class receives most static methods from `RequestSqliteCache`.
- Added `OfflineRequestQueue#requestManager` to access queue via a `RequestSqliteCacheManager` instance.
- Renamed `RequestSqliteCache.unprocessedRequests` to `RequestSqliteCacheManager.prepareNextRequestToProcess` as the expected query only returns one locked row at a time.
- `RequestSqliteCacheManager.prepareNextRequestToProcess` locks _all_ unprocessed rows, not just the first one
- Add ability to toggle `serialProcessing` for `OfflineRequestQueue`
- Private member `OfflineFirstWithRestRepository#offlineRequestQueue` is now protected
- Remove `isConnected` member from `OfflineFirstRepository` and associated Connectivity code. The connection should not matter to the subclass as it, or a supporting class, should track outbound requests.

## 0.0.5+1

- Bump dependencies

## 0.0.5

- Rename `Query#params` to `Query#providerArgs`, reflecting the much narrower purpose of the member

## 0.0.2

- Export REST annotations/classes from `OfflineFirstWithRestRepository` for convenient access
- Don't require `MemoryCacheProvider` in `OfflineFirstWithRestRepository` as it's not required for `OfflineFirstRepository`
- Fix linter hints
