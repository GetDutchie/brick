import '../migration_commands.dart';
import '../schema.dart';
import 'schema_column.dart';
import 'schema_table.dart';

/// Compares two schemas to produce migrations that conver the difference
class SchemaDifference {
  final Schema oldSchema;
  final Schema newSchema;

  SchemaDifference(this.oldSchema, this.newSchema) : assert(oldSchema.version < newSchema.version);

  Set<SchemaTable> get droppedTables => oldSchema.tables.difference(newSchema.tables);

  Set<SchemaTable> get insertedTables => newSchema.tables.difference(oldSchema.tables);

  Set<SchemaColumn> get droppedColumns => _compareColumns(oldSchema, newSchema);

  Set<SchemaColumn> get insertedColumns => _compareColumns(newSchema, oldSchema);

  bool get hasDifference =>
      droppedTables.isNotEmpty ||
      insertedTables.isNotEmpty ||
      droppedColumns.isNotEmpty ||
      insertedColumns.isNotEmpty;

  /// Generates migration commands from the schemas' differences
  List<MigrationCommand> toMigrationCommands() {
    final removedTables = droppedTables.map((item) {
      return item.toCommand(shouldDrop: true);
    }).cast<DropTable>();

    // TODO detect if dropped column is a foreign key joins association AND WRITE TEST

    // Only drop column if the table isn't being dropped too
    final removedColumns = droppedColumns
        .where((item) {
          return !removedTables.any((command) => command.name == item.tableName);
        })
        .map((c) => c.toCommand(shouldDrop: true))
        .cast<DropColumn>();

    final addedColumns = insertedColumns.where((c) => !c.isPrimaryKey).toSet();
    final added = [insertedTables, addedColumns]
        .map((generatedSet) {
          return generatedSet.map((item) {
            return item.toCommand();
          });
        })
        .expand((s) => s)
        .cast<MigrationCommand>();

    return [removedTables, removedColumns, added]
        .expand((l) => l)
        .toList()
        .cast<MigrationCommand>();
  }

  /// Output to be used when building `up` statements in a [Migration]
  String get forGenerator {
    final stringified = toMigrationCommands().map((c) => c.forGenerator).join(',\n');
    return '[\n$stringified\n]';
  }

  Set<SchemaColumn> _compareColumns(Schema from, Schema to) {
    Set<SchemaColumn> differenceFromTable(SchemaTable fromTable) {
      final toColumns =
          to.tables.firstWhere((t) => t.name == fromTable.name, orElse: () => null)?.columns ??
              <SchemaColumn>{};

      final fromColumns = <SchemaColumn>{}..addAll(fromTable.columns);

      // Primary keys are added on [InsertTable]
      fromColumns.removeWhere((c) => c.isPrimaryKey);
      toColumns.removeWhere((c) => c.isPrimaryKey);

      // From and to tables should have identical names via `lookup`
      fromColumns.forEach((c) => c.tableName = fromTable.name);
      toColumns.forEach((c) => c.tableName = fromTable.name);
      return fromColumns.difference(toColumns);
    }

    return from.tables.map(differenceFromTable).expand((t) => t).toSet();
  }
}
