## Unreleased

## 1.4.0

* Update default of offline queue from 0 seconds to 5 seconds
* Notify SQLite subscribers when a remote update has occurred.

## 1.3.0

* Upgrade to support `brick_graphql` v2

## 1.2.0

* Do not invoke `remoteProvider.subscribe` if no subscription query exists.
* Ensure `query` is never non-null in the `subscriptions` mapping of the repository. If `query` is `null`, `controller` is assigned to the Model type and subscriptions cannot be regenerated after cancelling all listeners.
* Expand dependency restriction to include `brick_graphql` v2

## 1.1.2

* Loosen `gql`, `gql_exec`, and `gql_link` restriction

## 1.1.1

* Loosen `brick_graphql`, `brick_offline_first_with_graphql_abstract`, and `brick_offline_first_abstract` restriction

## 1.1.0

* Use public release versions of `brick_offline_first` and `brick_sqlite`
* When opening a new `OfflineFirstWithGraphqlRepository#subscribe`, add one event of existing local data to the stream
* Notify subscribers of an empty payload after deleting

## 1.0.0

* Add `subscribe` for streaming updates of all models
* Do not use `GraphqlOfflineQueueLink` automatically in Offline First Repository

## 0.0.1

Initial
