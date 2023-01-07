import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:brick_graphql/graphql.dart' show GraphqlSerializable;
import 'package:brick_offline_first_with_graphql/brick_offline_first_with_graphql.dart';

@ConnectOfflineFirstWithGraphql(
  graphqlConfig: GraphqlSerializable(),
)
class GraphqlConfigEndpoint extends OfflineFirstModel {
  @OfflineFirst(where: {'otherField': "data['value']", 'id': "data['id']"})
  final int someField;

  GraphqlConfigEndpoint(this.someField);
}
