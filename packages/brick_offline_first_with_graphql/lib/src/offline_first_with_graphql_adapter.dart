import 'package:brick_offline_first/src/offline_first_adapter.dart';

import 'package:brick_graphql/graphql.dart' show GraphqlProvider, GraphqlAdapter;
import 'package:brick_offline_first_abstract/abstract.dart' show OfflineFirstWithGraphqlModel;

import 'package:brick_sqlite/sqlite.dart';

export 'package:brick_graphql/src/runtime_graphql_definition.dart';

/// This adapter fetches first from [SqliteProvider] then hydrates with [GraphqlProvider].
abstract class OfflineFirstWithGraphqlAdapter<_Model extends OfflineFirstWithGraphqlModel>
    extends OfflineFirstAdapter<_Model> with GraphqlAdapter<_Model> {
  OfflineFirstWithGraphqlAdapter();
}
