import 'package:brick_offline_first/brick_offline_first.dart' show OfflineFirstModel;
import 'package:brick_rest/brick_rest.dart';

/// An offline-first enabled model for use with the [RestProvider]
abstract mixin class OfflineFirstWithRestModel extends OfflineFirstModel with RestModel {}
