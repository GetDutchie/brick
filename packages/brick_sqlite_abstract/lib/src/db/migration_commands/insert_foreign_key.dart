import 'migration_command.dart';
import 'insert_table.dart';
import 'drop_column.dart';

/// Create a foreign key column to reference another table
class InsertForeignKey extends MigrationCommand {
  final String localTableName;
  final String foreignTableName;

  /// Defaults to lowercase `${foreignTableName}_brick_id`
  final String foreignKeyColumn;

  const InsertForeignKey(
    this.localTableName,
    this.foreignTableName, {
    this.foreignKeyColumn,
  });

  String get _foreignKeyColumn {
    if (foreignKeyColumn != null) {
      return foreignKeyColumn;
    }

    return foreignKeyColumnName(foreignTableName);
  }

  String get statement =>
      'ALTER TABLE `$localTableName` ADD COLUMN `$_foreignKeyColumn` INTEGER REFERENCES `$foreignTableName`(`${InsertTable.PRIMARY_KEY_COLUMN}`)';

  String get forGenerator =>
      'InsertForeignKey("$localTableName", "$foreignTableName", foreignKeyColumn: "$_foreignKeyColumn")';

  get down => DropColumn(_foreignKeyColumn, onTable: localTableName);

  /// Generate a column that references another table.
  ///
  /// For example, if a `Person` has one `Hat`, the column generated on table `Person`
  /// would be `Hat_id`.
  ///
  /// If [prefix] is provided, it will be prepended to the normal convention with a `_`.
  static String foreignKeyColumnName(String foreignTableName, [String prefix]) {
    final defaultName = "$foreignTableName${InsertTable.PRIMARY_KEY_COLUMN}";
    if (prefix != null) {
      return "${prefix}_$defaultName";
    }

    return defaultName;
  }
}
