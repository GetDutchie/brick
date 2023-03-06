import 'package:brick_offline_first_with_graphql/brick_offline_first_with_graphql.dart';
import 'package:brick_graphql/brick_graphql.dart';
import 'package:brick_sqlite/brick_sqlite.dart';

class PizzaOperationTransformer extends GraphqlQueryOperationTransformer<Pizza> {
  final get = const GraphqlOperation(
    document: r'''
      query GetPizzas {
        getPizzas {}
      }
    ''',
  );

  const PizzaOperationTransformer(super.query, super.instance);
}

@ConnectOfflineFirstWithGraphql(
  graphqlConfig: GraphqlSerializable<Pizza>(
    queryOperationTransformer: PizzaOperationTransformer.new,
  ),
)
class Pizza extends OfflineFirstWithGraphqlModel {
  /// Read more about `@Sqlite`: https://github.com/GetDutchie/brick/tree/main/packages/brick_sqlite#fields
  @Sqlite(unique: true)
  final int? id;

  /// Read more about `@Graphql`: https://github.com/GetDutchie/brick/tree/main/packages/brick_graphql#fields
  @Graphql(enumAsString: true)
  final List<Topping>? toppings;

  final bool? frozen;

  Pizza({
    this.id,
    this.toppings,
    this.frozen,
  });
}

enum Topping { olive, pepperoni }
