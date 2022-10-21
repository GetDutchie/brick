# Model (Class) Configuration

Every GraphQL is built differently, and with a fair amount of technical debt. While documents and variables can be provided per request, operations should be declared alongside your model definition to keep your code clean.

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

?> Only headers need to be supplied; nodes can be supplied to override default behavior of fetching all fields requested by the model. To use autopopulated nodes provided by the model (with respect to `@Graphql` configuration), use an empty node selection (e.g. `deleteUser(vars: $vars) {}`).

!> Documents provided within `Query(providerArgs:)` will override any declared default operations. See [the GraphQL query docs](query.md) for more information.

### `@GraphqlSerializable(fieldRename:)`

By default, Brick assumes the Dart field name is the same as the GraphQL node name (i.e. `final String lastName => 'lastName'`). However, this can be changed to rename all fields (this can be overriden with `@Graphql(name:)`). For example:

```dart
GraphqlSerializable(fieldRename: FieldRename.snake_case)
// on from graphql (get)
 "last_name" => final String lastName
// on to graphql (upsert)
final String lastName => "last_name"
```
