import 'migration_command.dart';

/// Renames an existing SQLite table
class RenameTable extends MigrationCommand {
  final String oldName;
  final String newName;

  const RenameTable(
    this.oldName,
    this.newName,
  );

  String get statement => 'ALTER TABLE `$oldName` RENAME TO `$newName`';

  String get forGenerator => 'RenameTable("$oldName", "$newName")';

  get down => RenameTable(newName, oldName);
}
