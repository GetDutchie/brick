import 'package:brick_sqlite/src/db/migration_commands/migration_command.dart';

/// Renames an existing SQLite table
class RenameTable extends MigrationCommand {
  ///
  final String oldName;

  ///
  final String newName;

  /// Renames an existing SQLite table
  const RenameTable(
    this.oldName,
    this.newName,
  );

  @override
  String get statement => 'ALTER TABLE `$oldName` RENAME TO `$newName`';

  @override
  String get forGenerator => "RenameTable('$oldName', '$newName')";

  @override
  MigrationCommand get down => RenameTable(newName, oldName);
}
