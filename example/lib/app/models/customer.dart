import 'package:brick_offline_first/offline_first_with_rest.dart';
import 'package:pizza_shoppe/app/models/pizza.dart';

@ConnectOfflineFirstWithRest(
  restConfig: RestSerializable(
    endpoint: r'''{
    if (query.action == QueryAction.upsert) {
      return "/customers";
    }

    // member endpoint
    if (query.action == QueryAction.get && instance != null) {
      return "/customer/${instance.id}";
    }

    return "/customers";
  }''',
  ),
)
class Customer extends OfflineFirstWithRestModel {
  @Sqlite(unique: true)
  final int id;

  final String firstName;

  final String lastName;

  @OfflineFirst(where: {'id': "data['pizza_ids']"})
  final List<Pizza> pizzas;

  Customer({
    this.id,
    this.firstName,
    this.lastName,
    this.pizzas,
  });
}
