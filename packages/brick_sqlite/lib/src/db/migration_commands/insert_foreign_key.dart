import 'package:brick_sqlite/src/db/migration_commands/drop_column.dart';
import 'package:brick_sqlite/src/db/migration_commands/insert_table.dart';
import 'package:brick_sqlite/src/db/migration_commands/migration_command.dart';

/// Create a foreign key column to reference another table
class InsertForeignKey extends MigrationCommand {
  /// Table where the foreign key is defined
  final String localTableName;

  /// Table referenced by the foreign key
  final String foreignTableName;

  /// Defaults to lowercase `${foreignTableName}_brick_id`
  final String foreignKeyColumn;

  /// When true, deletion of the referenced record by [foreignKeyColumn] on the [foreignTableName]
  /// this record. For example, if the foreign table is "departments" and the local table
  /// is "employees," whenever that department is deleted, "employee"
  /// will be deleted. Defaults `false`.
  final bool onDeleteCascade;

  /// When true, deletion of a parent will set this table's referencing column to the default,
  /// usually `NULL` unless otherwise declared. Defaults `false`.
  final bool onDeleteSetDefault;

  /// Create a foreign key column to reference another table
  const InsertForeignKey(
    this.localTableName,
    this.foreignTableName, {
    String? foreignKeyColumn,
    this.onDeleteCascade = false,
    this.onDeleteSetDefault = false,
  }) : // Do not change this default without changing `foreignKeyColumnName`;
        // it wasn't invoked because functions aren't `const`
        foreignKeyColumn = foreignKeyColumn ?? '$foreignTableName${InsertTable.PRIMARY_KEY_COLUMN}';

  String get _onDeleteStatement {
    if (onDeleteSetDefault) return ' ON DELETE SET DEFAULT';
    if (onDeleteCascade) return ' ON DELETE CASCADE';
    return '';
  }

  /// When the last foreign key column is created on a joins table, an index is created to ensure that duplicate
  /// entries are not inserted
  @override
  String get statement =>
      'ALTER TABLE `$localTableName` ADD COLUMN `$foreignKeyColumn` INTEGER REFERENCES `$foreignTableName`(`${InsertTable.PRIMARY_KEY_COLUMN}`)$_onDeleteStatement';

  @override
  String get forGenerator =>
      "InsertForeignKey('$localTableName', '$foreignTableName', foreignKeyColumn: '$foreignKeyColumn', onDeleteCascade: $onDeleteCascade, onDeleteSetDefault: $onDeleteSetDefault)";

  @override
  MigrationCommand get down => DropColumn(foreignKeyColumn, onTable: localTableName);

  /// Generate a column that references another table.
  ///
  /// For example, if a `Person` has one `Hat`, the column generated on table `Person`
  /// would be `Hat_id`.
  ///
  /// If [prefix] is provided, it will be prepended to the normal convention with a `_`.
  // Do not change this function without changing the default value in the constructor
  // for `foreignKeyColumn`; this function isn't `const` so it could not be recycled
  static String foreignKeyColumnName(String foreignTableName, [String? prefix]) {
    final defaultName = '$foreignTableName${InsertTable.PRIMARY_KEY_COLUMN}';
    if (prefix != null) {
      return '${prefix}_$defaultName';
    }

    return defaultName;
  }

  /// Compose the name for a joins table between two associations, for example
  ///
  /// Every joins table includes _brick to signify it is a generated table and
  /// the column and table name.
  /// This is intentional to avoid collisions as Brick manages the migrations, and generates
  /// the adapter class. Adapter files are only concerned with their own adapters; therefore
  /// a shared adapter class (i.e. a many-to-many) will never exist.
  /// The downside of this pattern is the inevitable data duplication for such many-to-many
  /// relationships and the inability to query relationships without declaring them on
  /// parent/child models.
  static String joinsTableName(String columnName, {required String localTableName}) =>
      ['_brick', localTableName, columnName].join('_');

  /// In the rare case of a many-to-many association of the same model, the columns must be prefixed.
  /// For example, `final List<Friend> friends` on class `Friend`.
  ///
  /// This and [joinsTableForeignColumnName] are created for the legibility and constraint of a
  /// single, universal method across packages. The prefix of `l` should not be changed without an
  /// available migration path.
  static String joinsTableLocalColumnName(String localTableName) =>
      foreignKeyColumnName(localTableName, 'l');

  /// In the rare case of a many-to-many association of the same model, the columns must be prefixed.
  /// For example, `final List<Friend> friends` on class `Friend`.
  ///
  /// This and [joinsTableLocalColumnName] are created for the legibility and constraint of a
  /// single, universal method across packages. The prefix of `l` should not be changed without an
  /// available migration path.
  static String joinsTableForeignColumnName(String foreignTableName) =>
      foreignKeyColumnName(foreignTableName, 'f');
}
