import 'package:brick_offline_first_with_graphql/offline_first_with_graphql.dart';
import 'package:brick_offline_first_with_graphql_abstract/annotations.dart';
import 'package:pizza_shoppe/brick/models/pizza.model.dart';

@ConnectOfflineFirstWithGraphql(
  graphqlConfig: GraphqlSerializable(
    defaultQueryOperation: r'''
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
