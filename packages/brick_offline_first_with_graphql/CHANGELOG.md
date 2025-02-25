## 4.0.0

- **BREAKING CHANGE** `Query(providerArgs:)` is no longer supported. See #510 for migration steps.
- Dart minimum SDK is updated to `3.4.0`
- All dependency restrictions are updated to include the minimum released version.

## 3.3.0

- Allow a generic type argument for `OfflineFirstWithGraphqlRepository`
- Update analysis to modern lints
- Upgrade `brick_core` to `1.3.0`

## 3.2.0

- Add optional `onRequestException` callback function to `GraphqlOfflineQueueLink`
- Add optional `onReattempt` callback function to `RestOfflineQueueClient`

## 3.1.1

- Loosen constraints for `gql`, `gql_exec`, and `gql_link`

## 3.1.0

- Upgrade minimum Dart to 2.18

## 3.0.1

- Support Dart 3

## 3.0.0

Please follow the [v3 migration guide](https://github.com/GetDutchie/brick/issues/325) to easily upgrade.

- Remove `brick_sqlite_abstract`
- Remove `brick_offline_first_abstract`
- Remove `brick_offline_first_with_graphql_abstract`; add annotation `ConnectOfflineFirstWithGraphql` and class `OfflineFirstWithGraphqlModel` to this package
- **BREAKING CHANGE** Rename main export file to `brick_offline_first_with_graphql.dart`; remove forwarded exports from other packages: `FieldRename`, `Graphql` `GraphqlProvider`, and `GraphqlSerializable` can all be imported from the `brick_graphql` package
- Migrate code and tests for `OfflineFirstWithGraphqlRepository#subscribe` to `OfflineFirstRepository#subscribe`

## 1.4.0

- Update default of offline queue from 0 seconds to 5 seconds
- Notify SQLite subscribers when a remote update has occurred.

## 1.3.0

- Upgrade to support `brick_graphql` v2

## 1.2.0

- Do not invoke `remoteProvider.subscribe` if no subscription query exists.
- Ensure `query` is never non-null in the `subscriptions` mapping of the repository. If `query` is `null`, `controller` is assigned to the Model type and subscriptions cannot be regenerated after cancelling all listeners.
- Expand dependency restriction to include `brick_graphql` v2

## 1.1.2

- Loosen `gql`, `gql_exec`, and `gql_link` restriction

## 1.1.1

- Loosen `brick_graphql`, `brick_offline_first_with_graphql_abstract`, and `brick_offline_first_abstract` restriction

## 1.1.0

- Use public release versions of `brick_offline_first` and `brick_sqlite`
- When opening a new `OfflineFirstWithGraphqlRepository#subscribe`, add one event of existing local data to the stream
- Notify subscribers of an empty payload after deleting

## 1.0.0

- Add `subscribe` for streaming updates of all models
- Do not use `GraphqlOfflineQueueLink` automatically in Offline First Repository

## 0.0.1

Initial
