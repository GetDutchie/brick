import 'package:brick_sqlite/src/db/migration.dart';
import 'package:brick_sqlite/src/db/migration_commands/drop_column.dart';
import 'package:brick_sqlite/src/db/migration_commands/drop_table.dart';
import 'package:brick_sqlite/src/db/migration_commands/migration_command.dart';
import 'package:brick_sqlite/src/db/schema/schema.dart';
import 'package:brick_sqlite/src/db/schema/schema_column.dart';
import 'package:brick_sqlite/src/db/schema/schema_index.dart';
import 'package:brick_sqlite/src/db/schema/schema_table.dart';
import 'package:collection/collection.dart';

/// Compares two schemas to produce migrations that conver the difference
class SchemaDifference {
  ///
  final Schema oldSchema;

  ///
  final Schema newSchema;

  /// Compares two schemas to produce migrations that conver the difference
  SchemaDifference(this.oldSchema, this.newSchema)
      : assert(
          oldSchema.version < newSchema.version,
          'Old schema is a newer version than the new schema',
        );

  ///
  Set<SchemaTable> get droppedTables => oldSchema.tables.difference(newSchema.tables);

  ///
  Set<SchemaTable> get insertedTables => newSchema.tables.difference(oldSchema.tables);

  ///
  Set<SchemaIndex> get droppedIndices => _compareIndices(oldSchema, newSchema);

  ///
  Set<SchemaIndex> get createdIndices => _compareIndices(newSchema, oldSchema);

  ///
  Set<SchemaColumn> get droppedColumns => _compareColumns(oldSchema, newSchema);

  ///
  Set<SchemaColumn> get insertedColumns => _compareColumns(newSchema, oldSchema);

  /// If there is a significant difference between both schemas
  bool get hasDifference =>
      droppedTables.isNotEmpty ||
      insertedTables.isNotEmpty ||
      droppedIndices.isNotEmpty ||
      createdIndices.isNotEmpty ||
      droppedColumns.isNotEmpty ||
      insertedColumns.isNotEmpty;

  /// Generates migration commands from the schemas' differences
  List<MigrationCommand> toMigrationCommands() {
    final removedTables =
        droppedTables.map((item) => item.toCommand(shouldDrop: true)).cast<DropTable>();

    // TODOdetect if dropped column is a foreign key joins association AND WRITE TEST

    // Only drop column if the table isn't being dropped too
    final removedColumns = droppedColumns
        .where((item) => !removedTables.any((command) => command.name == item.tableName))
        .map((c) => c.toCommand(shouldDrop: true))
        .cast<DropColumn>();

    final addedColumns = insertedColumns.where((c) => !c.isPrimaryKey).toSet();
    final added = [insertedTables, addedColumns]
        .map(
          (generatedSet) => generatedSet.map((item) => item.toCommand()),
        )
        .expand((s) => s)
        .cast<MigrationCommand>();

    final addedIndices = createdIndices.map((c) => c.toCommand());
    final removedIndices = droppedIndices.map((c) => c.toCommand());

    return [removedTables, removedColumns, added, addedIndices, removedIndices]
        .expand((l) => l)
        .toList();
  }

  /// Output to be used when building `up` statements in a [Migration]
  String get forGenerator {
    final stringified = toMigrationCommands().map((c) => c.forGenerator).join(',\n');
    return '[\n$stringified\n]';
  }

  Set<SchemaColumn> _compareColumns(Schema from, Schema to) {
    Set<SchemaColumn> differenceFromTable(SchemaTable fromTable) {
      final toColumns =
          to.tables.firstWhereOrNull((t) => t.name == fromTable.name)?.columns ?? <SchemaColumn>{};

      final fromColumns = <SchemaColumn>{}..addAll(fromTable.columns);

      // Primary keys are added on [InsertTable]
      // ignore: cascade_invocations
      fromColumns.removeWhere((c) => c.isPrimaryKey);
      toColumns.removeWhere((c) => c.isPrimaryKey);

      // From and to tables should have identical names via `lookup`
      for (final c in fromColumns) {
        c.tableName = fromTable.name;
      }
      for (final c in toColumns) {
        c.tableName = fromTable.name;
      }
      return fromColumns.difference(toColumns);
    }

    return from.tables.map(differenceFromTable).expand((t) => t).toSet();
  }

  Set<SchemaIndex> _compareIndices(Schema from, Schema to) {
    Set<SchemaIndex> differenceFromTable(SchemaTable fromTable) {
      final toIndices =
          to.tables.firstWhereOrNull((t) => t.name == fromTable.name)?.indices ?? <SchemaIndex>{};

      final fromIndices = <SchemaIndex>{}..addAll(fromTable.indices);

      // From and to tables should have identical names via `lookup`
      for (final c in fromIndices) {
        c.tableName = fromTable.name;
      }
      for (final c in toIndices) {
        c.tableName = fromTable.name;
      }
      return fromIndices.difference(toIndices);
    }

    return from.tables.map(differenceFromTable).expand((t) => t).toSet();
  }
}
