import 'package:brick_offline_first/offline_first_with_graphql.dart';
import 'package:brick_offline_first/offline_first_with_rest.dart';
import 'package:pizza_shoppe/app/models/pizza.dart';

@ConnectOfflineFirstWithGraphql(
  graphqlConfig: GraphqlSerializable(
    defaultGetOperation: r'''
      query GetCustomers {
        getCustomers {}
      }
    ''',
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
