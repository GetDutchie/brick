import 'migration_command.dart';

/// Drop index from DB if it exists
class DropIndex extends MigrationCommand {
  final String name;

  const DropIndex(this.name);

  @override
  String get statement => 'DROP INDEX IF EXISTS $name';

  @override
  String get forGenerator => "DropIndex('$name')";
}
