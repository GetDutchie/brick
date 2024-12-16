import 'package:brick_sqlite/src/db/migration_commands/drop_index.dart';
import 'package:brick_sqlite/src/db/migration_commands/migration_command.dart';

/// Create an index on a table if it doesn't already exists
class CreateIndex extends MigrationCommand {
  ///
  final List<String> columns;

  ///
  final String onTable;

  ///
  final bool unique;

  /// As a migration, this may fail if existing data is in conflict with the index.
  /// Before running this migration command, ensure that its table is either clean
  /// or does not contain data that conflicts with the columns specified by the index.
  const CreateIndex({
    required this.onTable,
    required this.columns,
    this.unique = false,
  });

  ///
  String get name => generateName(columns, onTable);

  @override
  String get statement {
    final statement = ['CREATE'];
    if (unique) statement.add('UNIQUE');

    final columnNames = columns.map((c) => '`$c`').join(', ');
    statement.add('INDEX IF NOT EXISTS $name on `$onTable`($columnNames)');
    return statement.join(' ');
  }

  @override
  String get forGenerator =>
      "CreateIndex(columns: [${columns.map((c) => "'$c'").join(', ')}], onTable: '$onTable', unique: $unique)";

  @override
  MigrationCommand get down => DropIndex(name);

  /// Combines columns and table name to create an index name
  static String generateName(List<String> columns, String onTable) {
    final columnNames = columns.join('_');
    return ['index', onTable, 'on', columnNames].join('_');
  }
}
