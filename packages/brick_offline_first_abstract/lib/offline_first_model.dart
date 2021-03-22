import 'package:brick_core/core.dart';
import 'package:brick_rest/rest.dart' show RestModel;
import 'package:brick_sqlite_abstract/sqlite_model.dart';

/// This model is constructed by data in SQLite. It hydrates from a REST endpoint.
///
/// Why isn't this in the `offline_first.dart` file in the SQLite package?
/// This is model required by the generator which cannot include Flutter as a dependency.
abstract class OfflineFirstModel extends SqliteModel {}

abstract class OfflineFirstWithRestModel extends OfflineFirstModel with RestModel {}

class Impl extends OfflineFirstWithRestModel {}

class Repo extends ModelRepository<OfflineFirstWithRestModel> {
  delete<_Model extends OfflineFirstWithRestModel>(instance, {Query? query}) => null;
  get<_Model extends OfflineFirstWithRestModel>({Query? query}) => null;
  upsert<_Model extends OfflineFirstWithRestModel>(instance, {Query? query}) => null;
}

final i = Impl();
final t = i as RestModel;
