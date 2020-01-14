import 'package:meta/meta.dart';
import 'migration_command.dart';

/// SQLite doesn't have a catch-all drop column command. On migrate, the provider can search for
/// columns prefixed by `_should_drop` and generate a statement that includes the schema of
/// the full table to be `ALTER`ed.
class DropColumn extends MigrationCommand {
  final String name;
  final String onTable;

  const DropColumn(
    this.name, {
    @required this.onTable,
  });

  /// SQLite does not support dropping individual columns. Instead, this command
  /// must be handled during migration when access to the table schema is available.
  @override
  String get statement => null;

  @override
  String get forGenerator => "DropColumn('$name', onTable: '$onTable')";
}
