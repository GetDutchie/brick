import 'package:brick_core/core.dart';
import 'package:brick_rest/brick_rest.dart';

class PizzaRequestTransformer extends RestRequestTransformer {
  RestRequest? get get {
    if (query?.where != null) {
      final byId = Where.firstByField('id', query!.where);
      // member endpoint
      if (byId?.value != null) {
        return RestRequest(url: '/pizza/${byId!.value}');
      }
    }

    return RestRequest(url: '/pizzas');
  }

  final upsert = const RestRequest(url: '/pizzas');

  const PizzaRequestTransformer(super.query, super.instance);
}
