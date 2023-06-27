import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:pizza_shoppe/brick/models/pizza.model.request.dart';

@ConnectOfflineFirstWithRest(
  restConfig: RestSerializable(
    requestTransformer: PizzaRequestTransformer.new,
  ),
)
class Pizza extends OfflineFirstWithRestModel {
  /// Read more about `@Sqlite`: https://github.com/GetDutchie/brick/tree/main/packages/brick_sqlite#fields
  @Sqlite(unique: true)
  final int id;

  /// Read more about `@Rest`: https://github.com/GetDutchie/brick/tree/main/packages/brick_rest#fields
  @Rest(enumAsString: true)
  final List<Topping> toppings;

  final bool frozen;

  Pizza({
    required this.id,
    required this.toppings,
    required this.frozen,
  });
}

enum Topping { olive, pepperoni }
