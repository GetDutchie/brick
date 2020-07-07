import 'package:brick_sqlite_abstract/src/db/migration_commands/drop_index.dart';
import 'package:meta/meta.dart';
import 'migration_command.dart';

/// Create an index on a table if it doesn't already exists
class CreateIndex extends MigrationCommand {
  final List<String> columns;

  final String onTable;

  final bool unique;

  const CreateIndex({
    @required this.onTable,
    @required this.columns,
    this.unique = false,
  });

  String get name => generateName(columns, onTable);

  @override
  String get statement {
    var statement = ['CREATE'];
    if (unique) statement.add('UNIQUE');

    final columnNames = columns.map((c) => '`$c`').join(', ');
    statement.add('INDEX IF NOT EXISTS $name on $onTable($columnNames)');
    return statement.join(' ');
  }

  @override
  String get forGenerator =>
      "CreateIndex(columns: [${columns.map((c) => "'$c'").join(', ')}], onTable: '$onTable', unique: $unique)";

  @override
  MigrationCommand get down => DropIndex(name);

  static String generateName(List<String> columns, String onTable) {
    final columnNames = columns.join('_');
    return ['index', onTable, 'on', columnNames].join('_');
  }
}
