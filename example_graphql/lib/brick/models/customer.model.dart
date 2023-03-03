import 'package:brick_core/core.dart';
import 'package:brick_offline_first_with_graphql/brick_offline_first_with_graphql.dart';
import 'package:brick_graphql/brick_graphql.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:pizza_shoppe/brick/models/pizza.model.dart';

class CustomerOperationTransformer extends GraphqlQueryOperationTransformer {
  final get = const GraphqlOperation(
    document: r'''
      query GetPizzas {
        getPizzas {}
      }
    ''',
  );

  const CustomerOperationTransformer(Query? query, Model? instance) : super(query, instance);
}

@ConnectOfflineFirstWithGraphql(
  graphqlConfig: GraphqlSerializable(
    queryOperationTransformer: CustomerOperationTransformer.new,
  ),
)
class Customer extends OfflineFirstWithGraphqlModel {
  @Sqlite(unique: true)
  final int? id;

  final String? firstName;

  final String? lastName;

  final List<Pizza>? pizzas;

  Customer({
    this.id,
    this.firstName,
    this.lastName,
    this.pizzas,
  });
}
