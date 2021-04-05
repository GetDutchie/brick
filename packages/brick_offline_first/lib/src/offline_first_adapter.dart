import 'package:brick_offline_first_abstract/abstract.dart';

import 'package:brick_sqlite/sqlite.dart';

/// This adapter fetches first from [SqliteProvider] then hydrates with from a remote provider..
abstract class OfflineFirstAdapter<_Model extends OfflineFirstModel> extends SqliteAdapter<_Model> {
  OfflineFirstAdapter();
}
