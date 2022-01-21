import 'package:brick_offline_first/offline_first_with_rest.dart';

@ConnectOfflineFirstWithRest(
  restConfig: RestSerializable(
    endpoint: r'''{
    if (query?.action == QueryAction.upsert) {
      return "/pizzas";
    }

    if (query?.action == QueryAction.get && query?.where != null) {
      final byId = Where.firstByField('id', query!.where);
      // member endpoint
      if (byId?.value != null) {
        return "/pizza/${byId!.value}";
      }
    }

    if (query?.action == QueryAction.get) {
      return "/pizzas";
    }

    return null;
  }''',
  ),
)
class Pizza extends OfflineFirstWithRestModel {
  /// Read more about `@Sqlite`: https://github.com/GetDutchie/brick/tree/main/packages/brick_sqlite#fields
  @Sqlite(unique: true)
  final int? id;

  /// Read more about `@Rest`: https://github.com/GetDutchie/brick/tree/main/packages/brick_rest#fields
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
