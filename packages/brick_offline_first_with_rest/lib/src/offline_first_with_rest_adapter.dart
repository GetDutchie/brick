import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:brick_offline_first_with_rest/src/models/offline_first_with_rest_model.dart';

import 'package:brick_rest/brick_rest.dart' show RestProvider, RestAdapter;

/// This adapter fetches first from [SqliteProvider] then hydrates with [RestProvider].
abstract class OfflineFirstWithRestAdapter<_Model extends OfflineFirstWithRestModel>
    extends OfflineFirstAdapter<_Model> with RestAdapter<_Model> {
  OfflineFirstWithRestAdapter();
}
