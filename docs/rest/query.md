# `Query` Configuration

## `providerArgs:`

| Name | Type | Description |
|---|---|---|
| `'request'` | `RestRequest` | Specifies configurable information about the request like HTTP method or top level key |
| `'supplementalTopLevelData'` | `Map<String, dynamic>` | this map is merged alongside the `topLevelKey` in the payload. For example, given `'supplementalTopLevelData': {'other_key': true}` `{"topLevelKey": ..., "other_key": true}`. It is **strongly recommended** to avoid using this property. Your data should be managed at the model level, not the query level. |

## `where:`

`RestProvider` does not support any `Query#where` arguments. These should be configured on a model-by-model base by the `RestSerializable#endpoint` argument.
