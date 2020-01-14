import 'insert_table.dart';
import 'migration_command.dart';

/// Drop table from DB if it exists
class DropTable extends MigrationCommand {
  final String name;

  const DropTable(this.name);

  @override
  String get statement => 'DROP TABLE IF EXISTS `$name`';

  @override
  String get forGenerator => "DropTable('$name')";

  @override
  MigrationCommand get down => InsertTable(name);
}
