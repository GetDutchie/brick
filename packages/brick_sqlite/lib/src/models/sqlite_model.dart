import 'package:brick_core/core.dart';
import 'package:brick_sqlite/src/sqlite_provider.dart';

/// The default value of the `primaryKey` field.
// ignore: constant_identifier_names
const int? NEW_RECORD_ID = null;

/// Models accessible to the [SqliteProvider].
///
/// Why isn't this in the SQLite package? It's required by `OfflineFirstModel`.
abstract mixin class SqliteModel implements Model {
  /// DO NOT modify this in the end implementation code. The Repository will update it accordingly.
  /// It is strongly recommended that this field only be used by Brick's internal queries and not
  /// in the end implementation.
  ///
  /// Maps to the `_brick_id` column.
  int? primaryKey = NEW_RECORD_ID;

  /// If `true`, this model has not yet been inserted into SQLite.
  bool get isNewRecord => primaryKey == NEW_RECORD_ID;

  /// Hook invoked before the model is successfully entered in the SQLite database.
  /// Useful to update or save associations.
  Future<void> beforeSave({Provider? provider, ModelRepository? repository}) async {}

  /// Hook invoked after the model is successfully entered in the SQLite database.
  /// Useful to update or save associations.
  Future<void> afterSave({Provider? provider, ModelRepository? repository}) async {}
}
