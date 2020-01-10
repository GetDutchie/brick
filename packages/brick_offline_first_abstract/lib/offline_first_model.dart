import 'package:brick_rest/rest.dart' show RestModel;
import 'package:brick_sqlite_abstract/sqlite_model.dart';

/// This model is constructed by data in SQLite. It hydrates from a REST endpoint.
///
/// Why isn't this in the `offline_first.dart` file in the SQLite package?
/// This is model required by the generator which cannot include Flutter as a dependency.
abstract class OfflineFirstModel with SqliteModel {}

abstract class OfflineFirstWithRestModel extends OfflineFirstModel with RestModel {}
