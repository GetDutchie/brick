import 'package:meta/meta.dart';
import 'migration_command.dart';

/// Drop table from DB if it exists
class CreateIndex extends MigrationCommand {
  final List<String> columns;

  final String onTable;

  final bool unique;

  const CreateIndex({
    @required this.onTable,
    @required this.columns,
    this.unique = false,
  });

  String get name {
    final columnNames = columns.join('_');
    return '${columnNames}_index';
  }

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
}
