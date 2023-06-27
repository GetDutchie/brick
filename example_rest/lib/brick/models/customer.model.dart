import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:pizza_shoppe/brick/models/customer.model.request.dart';
import 'package:pizza_shoppe/brick/models/pizza.model.dart';

@ConnectOfflineFirstWithRest(
  restConfig: RestSerializable(
    requestTransformer: CustomerRequestTransformer.new,
  ),
)
class Customer extends OfflineFirstWithRestModel {
  @Sqlite(unique: true)
  final int? id;

  final String? firstName;

  final String? lastName;

  @OfflineFirst(where: {'id': "data['pizza_ids']"})
  @Rest(name: 'pizza_ids')
  final List<Pizza>? pizzas;

  Customer({
    this.id,
    this.firstName,
    this.lastName,
    this.pizzas,
  });
}
