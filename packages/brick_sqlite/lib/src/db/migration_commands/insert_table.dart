import 'package:brick_sqlite/src/db/migration_commands/drop_table.dart';
import 'package:brick_sqlite/src/db/migration_commands/migration_command.dart';

/// Insert table if it doesn't already exist
class InsertTable extends MigrationCommand {
  ///
  final String name;

  /// Insert table if it doesn't already exist
  const InsertTable(this.name);

  @override
  String get statement =>
      'CREATE TABLE IF NOT EXISTS `$name` (`$PRIMARY_KEY_COLUMN` INTEGER PRIMARY KEY AUTOINCREMENT)';

  @override
  String get forGenerator => "InsertTable('$name')";

  @override
  MigrationCommand get down => DropTable(name);

  /// Automatically aliased to [rowid](https://www.sqlite.org/lang_createtable.html#rowid).
  // ignore: constant_identifier_names
  static const PRIMARY_KEY_COLUMN = '_brick_id';

  /// Dart field name of the primary key, pulled from the [PRIMARY_KEY_COLUMN]
  // ignore: constant_identifier_names
  static const PRIMARY_KEY_FIELD = 'primaryKey';
}
