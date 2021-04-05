import 'package:brick_offline_first/src/offline_first_adapter.dart';

import 'package:brick_rest/rest.dart' show RestProvider, RestAdapter;
import 'package:brick_offline_first_abstract/abstract.dart' show OfflineFirstWithRestModel;

import 'package:brick_sqlite/sqlite.dart';

/// This adapter fetches first from [SqliteProvider] then hydrates with [RestProvider].
abstract class OfflineFirstWithRestAdapter<_Model extends OfflineFirstWithRestModel>
    extends OfflineFirstAdapter<_Model> with RestAdapter<_Model> {
  OfflineFirstWithRestAdapter();
}
