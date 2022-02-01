import 'package:brick_offline_first/offline_first.dart';

import 'package:brick_rest/rest.dart' show RestProvider, RestAdapter;
import 'package:brick_offline_first_with_rest_abstract/abstract.dart'
    show OfflineFirstWithRestModel;

/// This adapter fetches first from [SqliteProvider] then hydrates with [RestProvider].
abstract class OfflineFirstWithRestAdapter<_Model extends OfflineFirstWithRestModel>
    extends OfflineFirstAdapter<_Model> with RestAdapter<_Model> {
  OfflineFirstWithRestAdapter();
}
