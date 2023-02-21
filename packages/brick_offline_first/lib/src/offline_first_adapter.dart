import 'package:brick_offline_first/src/models/offline_first_model.dart';
import 'package:brick_offline_first/src/runtime_offline_first_definition.dart';
import 'package:brick_sqlite/brick_sqlite.dart' show SqliteAdapter;

/// This adapter fetches first from [SqliteProvider] then hydrates with from a remote provider..
abstract class OfflineFirstAdapter<_Model extends OfflineFirstModel> extends SqliteAdapter<_Model> {
  Map<String, RuntimeOfflineFirstDefinition> get fieldsToOfflineRuntimeDefinition => {};

  OfflineFirstAdapter();
}
