import 'package:brick_core/core.dart';
import 'package:brick_sqlite/src/sqlite/sqlite_adapter.dart';
import 'package:brick_sqlite_abstract/sqlite_model.dart';
export 'package:brick_sqlite_abstract/sqlite_model.dart';

/// Associates app models with their [SqliteAdapter]
class SqliteModelDictionary extends ModelDictionary<SqliteModel, SqliteAdapter<SqliteModel>> {
  const SqliteModelDictionary(Map<Type, SqliteAdapter<SqliteModel>> mappings) : super(mappings);
}
