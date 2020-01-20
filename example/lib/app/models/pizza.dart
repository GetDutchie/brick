import 'package:brick_offline_first/offline_first_with_rest.dart';
import 'package:pizza_shoppe/app/models/customer.dart';

@ConnectOfflineFirstWithRest(
  restConfig: RestSerializable(
    endpoint: r'''{
    if (query.action == QueryAction.upsert) {
      return "/pizzas";
    }

    // member endpoint
    if (query.action == QueryAction.get && instance != null) {
      return "/pizza/${instance.id}";
    }

    return "/pizzas";
  }''',
  ),
)
class Pizza extends OfflineFirstWithRestModel {
  @Sqlite(unique: true)
  final int id;

  @Rest(enumAsString: true)
  final List<Topping> toppings;

  @OfflineFirst(where: {'id': "data['customer_id']"})
  final Customer customer;

  final bool frozen;

  Pizza({
    this.id,
    this.toppings,
    this.customer,
    this.frozen,
  });
}

enum Topping { olive, pepperoni }
