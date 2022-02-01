import 'package:brick_rest/rest.dart';

import 'package:brick_offline_first_abstract/annotations.dart';
import 'package:brick_offline_first_abstract/abstract.dart';

/// A child association
@ConnectOfflineFirstWithRest(
  restConfig: RestSerializable(
    endpoint: '=> /hats;',
  ),
)
class Hat extends OfflineFirstWithRestModel {
  final int? id;

  final String? color;

  Hat({
    this.id,
    this.color,
  });
}

/// A parent association
@ConnectOfflineFirstWithRest(
  restConfig: RestSerializable(
    endpoint: '=> /people;',
  ),
)
class Person extends OfflineFirstWithRestModel {
  /// given an API response of
  /// { "hat_id" : 1}
  /// this will automatically fetch or hydrate the association based on the unique lookup of
  /// Hat.id
  @OfflineFirst(where: {'id': "data['hat_id']"})

  /// for upsert and delete, the rest key must be defined
  @Rest(name: 'hat_id')
  final Hat? hat;

  Person({
    this.hat,
  });
}
