import 'package:brick_sqlite/brick_sqlite.dart' show SqliteModel;

/// This model is constructed by data in SQLite. It hydrates from a REST endpoint.
///
/// Why isn't this in the `offline_first.dart` file in the SQLite package?
/// This is model required by the generator which cannot include Flutter as a dependency.
abstract class OfflineFirstModel extends SqliteModel {}
