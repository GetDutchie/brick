import 'package:meta/meta.dart';
import 'migration_command.dart';

/// Renames an existing SQLite column in a table
class RenameColumn extends MigrationCommand {
  final String oldName;
  final String newName;
  final String onTable;

  const RenameColumn(
    this.oldName,
    this.newName, {
    @required this.onTable,
  });

  /// This is intentionally null. The SqliteProvider handles renaming columns.
  String get statement => null;

  String get forGenerator => 'RenameColumn("$oldName", "$newName", onTable: "$onTable")';

  get down => RenameColumn(newName, oldName, onTable: onTable);
}
