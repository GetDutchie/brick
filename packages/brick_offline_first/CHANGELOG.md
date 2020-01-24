## Unreleased

## 0.0.5+1

* Bump dependencies

## 0.0.5

* Rename `Query#params` to `Query#providerArgs`, reflecting the much narrower purpose of the member

## 0.0.2

* Export REST annotations/classes from `OfflineFirstWithRestRepository` for convenient access
* Don't require `MemoryCacheProvider` in `OfflineFirstWithRestRepository` as it's not required for `OfflineFirstRepository`
* Fix linter hints
