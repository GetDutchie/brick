import 'package:brick_offline_first_abstract/abstract.dart';
import 'package:brick_graphql/graphql.dart' show GraphqlSerializable;
import 'package:brick_offline_first_with_graphql_abstract/annotations.dart';

@ConnectOfflineFirstWithGraphql(
  graphqlConfig: GraphqlSerializable(),
)
class GraphqlConfigEndpoint extends OfflineFirstModel {
  @OfflineFirst(where: {'otherField': "data['id']['value']"})
  final int someField;

  GraphqlConfigEndpoint(this.someField);
}
