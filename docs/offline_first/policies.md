# Offline First Policies

Repository methods can be invoked with policies to prioritize data sources. For example, a request may need to skip the offline queue or the response must come from a remote source. It is strongly encouraged to use a policy (e.g. `Repository().get<User>(policy: .requireRemote))`) instead of directly accessing a provider (e.g. `Repository().restPovider.get<User>()`).

## OfflineFirstDeletePolicy

### `optimisticLocal` (default)

Delete local results before waiting for the remote provider to respond.

### `requireRemote`

Delete local results after remote responds; local results are not deleted if remote responds with any exception.

## OfflineFirstGetPolicy

### `alwaysHydrate`

Ensures data is fetched from the remote provider(s) at each invocation. This hydration is unawaited and is not guaranteed to complete before results are returned. This can be expensive to perform for some queries; see [`awaitRemoteWhenNoneExist`](#awaitremotewhennoneexist) for a more performant option or [`awaitRemote`](#awaitremote) to await the hydration before returning results.

### `awaitRemote`

Ensures results must be updated from the remote proivder(s) before returning if the app is online. An empty array will be returned if the app is offline.

### `awaitRemoteWhenNoneExist` (default)

Retrieves from the remote provider(s) if the query returns no results from the local provider(s).

### `localOnly`

Do not request from the remote provider(s).

## OfflineFirstUpsertPolicy

### `optimisticLocal` (default)

Save results to local before waiting for the remote provider to respond.

### `requireRemote`

Save results to local after remote responds; local results are not saved if remote responds with any exception.
