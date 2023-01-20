import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:pizza_shoppe/brick/models/pizza.model.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:brick_core/query.dart';

class CustomerRequestTransformer extends RestRequestTransformer {
  // A production code base would not forward to another operation
  // but for testing this is convenient
  @override
  RestRequest get delete => get;

  @override
  RestRequest get get {
    final url = () {
    if (query?.action == QueryAction.upsert) {
      return "/customers";
    }

    if (query?.action == QueryAction.get && query?.where != null) {
      final byId = Where.firstByField('id', query?.where);
      // member endpoint
      if (byId?.value != null) {
        return "/customer/${byId!.value}";
      }
    }

    if (query?.action == QueryAction.get) {
      return "/customers";
    }

    return null;
    }();
    return RestRequest(url: url);
  }

  // A production code base would not forward to another operation
  // but for testing this is convenient
  @override
  RestRequest get upsert => get;

  const CustomerRequestTransformer(Query? query, RestModel? instance) : super(query, instance);
}

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
