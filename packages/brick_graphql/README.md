# Brick GraphQL

Core logic for interfacing with a GraphQL server with Brick.

## How Brick Generates GraphQL Data

Because Brick interpolates with other providers, such as SQLite, there must be a single point of generation. This library elects to generate the code from Dart (instead of from a GraphQL generator like [Artemis](https://pub.dev/packages/artemis)) so that configuration for these providers can exist in the same source of truth.

## Supported `Query` Configuration

Since Dart is the source of truth, it may not map 1:1 to the GraphQL contract. Brick will intelligently guess what operation to use and send generated variables based on the Dart model. However, it can always be overriden with a `Query(providerArgs)`.

### `providerArgs:`

- `'operation'` (`GraphqlOperation`) apply this operation instead of one of the defaults from `graphqlOperationTransformer`. The document subfields **will not** be populated by the model.
- `'context'` (`Map<String, ContextEntry>`) apply this as the context to the request instead of an empty object. Useful for subsequent consumers/`Link`s of the request. The key should be the runtime type of the `ContextEntry`.

#### `variablesNamespace`

Some GraphQL systems may utilize a single variable property for all operations. By default, Brick can wrap all variables of all requests within a top-level key:

```graphql
# GraphqlProvider(variablesNamespace: 'vars')

query MyOperation($vars: MyInputClass!) {
  myOperation(vars: $vars) {}
}
```

:bulb: `GraphqlProviderQuery#variables` will **never** be wrapped by `variablesNamespace`

## `where:`

Values supplied to `where:` are transformed into variables sent with queries and subscriptions. Variables autopopulated from `Query(where:)` are overriden by - not mixed with - `providerArgs: {'operation'}.variables`

```dart
Query(where: [
  Where('name').isExactly('Thomas')
])
// => {'name': 'Thomas'}
```

To extend a query with custom properties, use `GraphqlProvider#queryToVariables`:

```dart
final query = Query.where('name', 'Thomas');
final variables = {
  ...graphqlProvider.queryToVariables(query),
  'myCustomVariable': true,
};
```

:warning: Association values within `Where` **are not** converted to variables.

## `#toJson` and subfields

When a field's type's class has a `#toJson` method that returns a `Map`, subfields will be automatically populated on requests based on the `final` instance fields of that field's type.

```dart
class Hat {
  final String fabric;
  final int width;

  Hat({this.fabric, this.width});

  Map<String, dynamic> toJson() => {'fabric': fabric, 'width': width};
}

class Mounty {
  final Hat hat;
  final String horseName
  final String name;
}
```

Produces the following GraphQL document on `query` or `subscription`:

```graphql
query {
  myQueryName {
    hat {
      fabric
      width
    }
    horseName
    name
  }
}
```

## Models

To reduce copypasta-ing the same GraphQL document and variables, all operations can be set in a single place alongside the model configuration.

1. Create a new class that extends `GraphqlQueryOperationTransformer`:
   ```dart
   class UserQueryOperationTransformer extends GraphqlQueryOperationTransformer {}
   ```
1. This class has access to every request's `query`, and for `delete` and `upsert`, `instance`. You can use these properties to tell Brick which GraphQL operation to use.
   ```dart
   class UserQueryOperationTransformer extends GraphqlQueryOperationTransformer {
     GraphqlOperation get upsert {
       if (query.where != null) {
         return GraphqlOperation(document: r'''
           mutation UpdateUserName($name: String!) {
             updateUserName(input: $input) {}
           }
         ''');
       }
       return GraphqlOperation(document: r'''
         mutation CreateUser($input: UserInput!) {
           createUser(input: $input) {}
         }
       ''');
     }
   }
   ```
1. In complex cases where the entire model is not being transmitted, `variables` can also be supplied.
   ```dart
   class UserQueryOperationTransformer extends GraphqlQueryOperationTransformer {
     GraphqlOperation get upsert {
       if (query.where != null) {
         return GraphqlOperation(
           document: r'''
             mutation UpdateUserName($name: String!) {
               updateUserName(input: $input) {}
             }
           ''',
           variables: {'name': Where.firstByField('name', query.where)});
       }
       return null;
     }
   }
   ```
1. Use the class in `GraphqlSerializable`:
   ```dart
   @GraphqlSerializable(
     queryOperationTransformer: UserQueryOperationTransformer.new
   )
   ```

:bulb: Only headers need to be supplied; nodes can be supplied to override default behavior of fetching all fields requested by the model. To use autopopulated nodes provided by the model (with respect to `@Graphql` configuration), use an empty node selection (e.g. `deleteUser(vars: $vars) {}`).
