import 'drop_column.dart';
import 'insert_table.dart';
import 'migration_command.dart';

/// Create a foreign key column to reference another table
class InsertForeignKey extends MigrationCommand {
  final String localTableName;
  final String foreignTableName;

  /// Defaults to lowercase `${foreignTableName}_brick_id`
  final String foreignKeyColumn;

  /// When true, deletion of a row within this model's table will delete all
  /// referencing children records. Defaults `false`.
  final bool onDeleteCascade;

  const InsertForeignKey(
    this.localTableName,
    this.foreignTableName, {
    this.foreignKeyColumn,
    this.onDeleteCascade = false,
  });

  String get _foreignKeyColumn {
    if (foreignKeyColumn != null) {
      return foreignKeyColumn;
    }

    return foreignKeyColumnName(foreignTableName);
  }

  String get _cascadeStatement => onDeleteCascade ? ' ON DELETE CASCADE' : '';

  @override
  String get statement =>
      'ALTER TABLE `$localTableName` ADD COLUMN `$_foreignKeyColumn` INTEGER REFERENCES `$foreignTableName`(`${InsertTable.PRIMARY_KEY_COLUMN}`)$_cascadeStatement';

  @override
  String get forGenerator =>
      "InsertForeignKey('$localTableName', '$foreignTableName', foreignKeyColumn: '$_foreignKeyColumn', onDeleteCascade: $onDeleteCascade)";

  @override
  MigrationCommand get down => DropColumn(_foreignKeyColumn, onTable: localTableName);

  /// Generate a column that references another table.
  ///
  /// For example, if a `Person` has one `Hat`, the column generated on table `Person`
  /// would be `Hat_id`.
  ///
  /// If [prefix] is provided, it will be prepended to the normal convention with a `_`.
  static String foreignKeyColumnName(String foreignTableName, [String prefix]) {
    final defaultName = '$foreignTableName${InsertTable.PRIMARY_KEY_COLUMN}';
    if (prefix != null) {
      return '${prefix}_$defaultName';
    }

    return defaultName;
  }

  /// Compose the name for a joins table between two associations, for example
  /// `_brick_Hat_User`.
  static String joinsTableName(String localTableName, String foreignTableName) {
    final alphabetized = [localTableName, foreignTableName]..sort();
    alphabetized.insert(0, '_brick');
    return alphabetized.join('_');
  }
}
