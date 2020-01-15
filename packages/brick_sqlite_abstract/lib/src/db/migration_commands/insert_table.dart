import 'drop_table.dart';
import 'migration_command.dart';

/// Insert table if it doesn't already exist
class InsertTable extends MigrationCommand {
  final String name;

  const InsertTable(this.name);

  @override
  String get statement =>
      'CREATE TABLE IF NOT EXISTS `$name` (`$PRIMARY_KEY_COLUMN` INTEGER PRIMARY KEY AUTOINCREMENT)';

  @override
  String get forGenerator => "InsertTable('$name')";

  @override
  MigrationCommand get down => DropTable(name);

  /// Automatically aliased to [rowid](https://www.sqlite.org/lang_createtable.html#rowid).
  static const PRIMARY_KEY_COLUMN = '_brick_id';
  static const PRIMARY_KEY_FIELD = 'primaryKey';
}
