import 'package:brick_graphql/graphql.dart';

import 'package:brick_offline_first_with_graphql_abstract/annotations.dart';
import 'package:brick_offline_first_with_graphql_abstract/abstract.dart';

/// A child association
@ConnectOfflineFirstWithGraphql()
class Hat extends OfflineFirstWithGraphqlModel {
  final int? id;

  final String? color;

  Hat({
    this.id,
    this.color,
  });
}

/// A parent association
@ConnectOfflineFirstWithGraphql()
class Person extends OfflineFirstWithGraphqlModel {
  /// given an API response of
  /// { "hat_id" : 1}
  /// this will automatically fetch or hydrate the association based on the unique lookup of
  /// Hat.id
  @OfflineFirst(where: {'id': "data['hat_id']"})

  /// for upsert and delete, the graphql key must be defined
  @Graphql(name: 'hat_id')
  final Hat? hat;

  Person({
    this.hat,
  });
}
