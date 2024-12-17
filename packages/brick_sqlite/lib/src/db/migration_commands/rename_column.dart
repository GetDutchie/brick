import 'package:brick_sqlite/src/db/migration_commands/migration_command.dart';

/// Renames an existing SQLite column in a table
class RenameColumn extends MigrationCommand {
  ///
  final String oldName;

  ///
  final String newName;

  ///
  final String onTable;

  /// Renames an existing SQLite column in a table
  const RenameColumn(
    this.oldName,
    this.newName, {
    required this.onTable,
  });

  /// This is intentionally null. The SqliteProvider handles renaming columns.
  @override
  String? get statement => null;

  @override
  String get forGenerator => "RenameColumn('$oldName', '$newName', onTable: '$onTable')";

  @override
  MigrationCommand get down => RenameColumn(newName, oldName, onTable: onTable);
}
