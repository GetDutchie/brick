import 'package:brick_graphql/brick_graphql.dart' show GraphqlAdapter, GraphqlProvider;
import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:brick_offline_first_with_graphql/src/models/offline_first_with_graphql_model.dart';
import 'package:brick_sqlite/brick_sqlite.dart';

export 'package:brick_graphql/src/runtime_graphql_definition.dart';

/// This adapter fetches first from [SqliteProvider] then hydrates with [GraphqlProvider].
abstract class OfflineFirstWithGraphqlAdapter<_Model extends OfflineFirstWithGraphqlModel>
    extends OfflineFirstAdapter<_Model> with GraphqlAdapter<_Model> {
  /// This adapter fetches first from [SqliteProvider] then hydrates with [GraphqlProvider].
  OfflineFirstWithGraphqlAdapter();
}
