import 'migration_command.dart';
import 'insert_table.dart';

/// Drop table from DB if it exists
class DropTable extends MigrationCommand {
  final String name;

  const DropTable(this.name);

  String get statement => 'DROP TABLE IF EXISTS `$name`';

  String get forGenerator => 'DropTable("$name")';

  get down => InsertTable(name);
}
