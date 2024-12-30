import 'package:brick_graphql/brick_graphql.dart' show GraphqlModel;
import 'package:brick_offline_first/brick_offline_first.dart';

/// GraphQL-enabled [OfflineFirstModel]
// ignore: prefer_mixin
abstract class OfflineFirstWithGraphqlModel extends OfflineFirstModel with GraphqlModel {}
