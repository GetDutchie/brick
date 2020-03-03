## Unreleased

* Remove maximumRequests configuration for the OfflineFirstQueue. One request should be processed at a time in serial
* Optionally ignore Tunnel not found requests (these occur when connectivity exists but the queried endpoint is unreachable) when making repository requests
* Adds argument to repository to reattempt requests based on the status code from the response
* `OfflineRequestQueue#process` became a protected method
* Added `RequestSqliteCacheManager` to interact with the queue. This new class receives most static methods from `RequestSqliteCache`.
* Added `OfflineRequestQueue#requestManager` to access queue via a `RequestSqliteCacheManager` instance.
* Renamed `RequestSqliteCache.unprocessedRequests` to `RequestSqliteCacheManager.prepareNextRequestToProcess` as the expected query only returns one locked row at a time.
* `RequestSqliteCacheManager.prepareNextRequestToProcess` locks _all_ unprocessed rows, not just the first one
* Add ability to toggle `serialProcessing` for `OfflineRequestQueue`
* Private member `OfflineFirstWithRestRepository#offlineRequestQueue` is now protected
* Remove `isConnected` member from `OfflineFirstRepository` and associated Connectivity code. The connection should not matter to the subclass as it, or a supporting class, should track outbound requests.

## 0.0.5+1

* Bump dependencies

## 0.0.5

* Rename `Query#params` to `Query#providerArgs`, reflecting the much narrower purpose of the member

## 0.0.2

* Export REST annotations/classes from `OfflineFirstWithRestRepository` for convenient access
* Don't require `MemoryCacheProvider` in `OfflineFirstWithRestRepository` as it's not required for `OfflineFirstRepository`
* Fix linter hints
