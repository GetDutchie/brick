import 'package:brick_core/core.dart';
import 'package:brick_sqlite/src/models/sqlite_model.dart';
import 'package:brick_sqlite/src/sqlite_adapter.dart';

/// Associates app models with their [SqliteAdapter]
class SqliteModelDictionary extends ModelDictionary<SqliteModel, SqliteAdapter<SqliteModel>> {
  const SqliteModelDictionary(Map<Type, SqliteAdapter<SqliteModel>> mappings) : super(mappings);
}
