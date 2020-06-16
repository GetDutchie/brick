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
  ///
  /// Every joins table includes _brick to signify it is a generated table and
  /// the field and table name.
  /// This is intentional to avoid collisions as Brick manages the migrations, and generates
  /// the adapter class. Adapter files are only concerned with their own adapters; therefore
  /// a shared adapter class (i.e. a many-to-many) will never exist.
  /// The downside of this pattern is the inevitable data duplication for such many-to-many
  /// relationships and the inability to query relationships without declaring them on
  /// parent/child models.
  static String joinsTableName(String fieldName, {String localTableName}) {
    final alphabetized = ['_brick', fieldName, localTableName]..sort();
    return alphabetized.join('_');
  }
}
