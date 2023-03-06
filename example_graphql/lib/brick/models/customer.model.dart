import 'package:brick_offline_first_with_graphql/brick_offline_first_with_graphql.dart';
import 'package:brick_graphql/brick_graphql.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:pizza_shoppe/brick/models/pizza.model.dart';

class CustomerOperationTransformer extends GraphqlQueryOperationTransformer<Customer> {
  final get = const GraphqlOperation(
    document: r'''
      query GetCustomers {
        getCustomers {}
      }
    ''',
  );

  const CustomerOperationTransformer(super.query, super.instance);
}

@ConnectOfflineFirstWithGraphql(
  graphqlConfig: GraphqlSerializable<Customer>(
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
