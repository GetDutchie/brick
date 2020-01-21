import 'package:brick_offline_first/offline_first_with_rest.dart';
import 'package:pizza_shoppe/app/models/customer.dart';

@ConnectOfflineFirstWithRest(
  restConfig: RestSerializable(
    endpoint: r'''{
    if (query.action == QueryAction.upsert) {
      return "/pizzas";
    }

    if (query.action == QueryAction.get && query?.where != null) {
      final byId = Where.firstByField('id', query.where);
      // member endpoint
      if (byId.value != null) {
        return "/pizza/${byId.value}";
      }

      return "/pizzas";
    }

    return null;
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
