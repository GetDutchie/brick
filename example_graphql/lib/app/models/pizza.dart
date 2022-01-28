import 'package:brick_offline_first/offline_first_with_graphql.dart';
import 'package:brick_offline_first/offline_first_with_rest.dart';

@ConnectOfflineFirstWithGraphql(
  graphqlConfig: GraphqlSerializable(
    defaultGetOperation: r'''
      query GetPizzas {
        getPizzas {}
      }
    ''',
  ),
)
class Pizza extends OfflineFirstWithGraphqlModel {
  /// Read more about `@Sqlite`: https://github.com/GetDutchie/brick/tree/main/packages/brick_sqlite#fields
  @Sqlite(unique: true)
  final int? id;

  /// Read more about `@Graphql`: https://github.com/GetDutchie/brick/tree/main/packages/brick_graphql#fields
  @Rest(enumAsString: true)
  final List<Topping>? toppings;

  final bool? frozen;

  Pizza({
    this.id,
    this.toppings,
    this.frozen,
  });
}

enum Topping { olive, pepperoni }
