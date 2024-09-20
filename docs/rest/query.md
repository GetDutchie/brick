# `Query` Configuration

## `providerArgs:`

| Name        | Type          | Description                                                                            |
| ----------- | ------------- | -------------------------------------------------------------------------------------- |
| `'request'` | `RestRequest` | Specifies configurable information about the request like HTTP method or top level key |

## `where:`

`RestProvider` does not support any `Query#where` arguments. These should be configured on a model-by-model base by the `RestSerializable#endpoint` argument.
