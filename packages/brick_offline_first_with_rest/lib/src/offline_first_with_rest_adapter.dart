import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:brick_offline_first_with_rest/src/models/offline_first_with_rest_model.dart';
import 'package:brick_rest/brick_rest.dart' show RestAdapter, RestProvider;
import 'package:brick_sqlite/brick_sqlite.dart';

/// This adapter holds logic necessary to work with [SqliteProvider] and [RestProvider].
abstract class OfflineFirstWithRestAdapter<_Model extends OfflineFirstWithRestModel>
    extends OfflineFirstAdapter<_Model> with RestAdapter<_Model> {
  /// This adapter holds logic necessary to work with [SqliteProvider] and [RestProvider].
  OfflineFirstWithRestAdapter();
}
