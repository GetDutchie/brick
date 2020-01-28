## Unreleased

* Remove maximumRequests configuration for the OfflineFirstQueue. One request should be processed at a time in serial
* Optionally ignore Tunnel not found requests (these occur when connectivity exists but the queried endpoint is unreachable) when making repository requests
* Adds argument to repository to reattempt requests based on the status code from the response

## 0.0.5+1

* Bump dependencies

## 0.0.5

* Rename `Query#params` to `Query#providerArgs`, reflecting the much narrower purpose of the member

## 0.0.2

* Export REST annotations/classes from `OfflineFirstWithRestRepository` for convenient access
* Don't require `MemoryCacheProvider` in `OfflineFirstWithRestRepository` as it's not required for `OfflineFirstRepository`
* Fix linter hints
