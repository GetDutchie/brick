// Heavily, heavily inspired by [Aqueduct](https://github.com/stablekernel/aqueduct/blob/master/aqueduct/lib/src/db/schema/schema_builder.dart)
// Unfortunately, some key differences such as inability to use mirrors and the sqlite vs postgres capabilities make DIY a more palatable option than retrofitting
import 'package:brick_sqlite/src/db/column.dart';
import 'package:brick_sqlite/src/db/migration.dart';
import 'package:brick_sqlite/src/db/migration_commands/create_index.dart';
import 'package:brick_sqlite/src/db/migration_commands/drop_column.dart';
import 'package:brick_sqlite/src/db/migration_commands/drop_index.dart';
import 'package:brick_sqlite/src/db/migration_commands/drop_table.dart';
import 'package:brick_sqlite/src/db/migration_commands/insert_column.dart';
import 'package:brick_sqlite/src/db/migration_commands/insert_foreign_key.dart';
import 'package:brick_sqlite/src/db/migration_commands/insert_table.dart';
import 'package:brick_sqlite/src/db/migration_commands/migration_command.dart';
import 'package:brick_sqlite/src/db/migration_commands/rename_column.dart';
import 'package:brick_sqlite/src/db/migration_commands/rename_table.dart';
import 'package:brick_sqlite/src/db/migration_manager.dart';
import 'package:brick_sqlite/src/db/schema/schema_column.dart';
import 'package:brick_sqlite/src/db/schema/schema_index.dart';
import 'package:brick_sqlite/src/db/schema/schema_table.dart';
import 'package:meta/meta.dart' show visibleForTesting;

/// A definition of all the tables and columns in the SQLite database
class Schema {
  /// The last version successfully migrated to SQLite.
  /// This should be before or equal to [MigrationManager]'s `#version`.
  /// if [MigrationManager] is used.
  final int version;

  ///
  final Set<SchemaTable> tables;

  /// Version used to produce this scheme
  final int generatorVersion;

  /// A definition of all the tables and columns in the SQLite database
  Schema(this.version, {required this.tables, this.generatorVersion = GENERATOR_VERSION});

  /// Generator used to produce this schema; not intended for public use
  // ignore: constant_identifier_names
  static const GENERATOR_VERSION = 1;

  ///
  @visibleForTesting
  static List<MigrationCommand> expandMigrations(Set<Migration> migrations) {
    final sorted = migrations.toList()
      ..sort((a, b) {
        if (a.version == b.version) {
          return 0;
        }

        return a.version > b.version ? 1 : -1;
      });

    return sorted.map((m) => m.up).expand((c) => c).toList();
  }

  /// Create a schema from a set of migrations. If [version] is not provided,
  /// the highest migration version will be used
  factory Schema.fromMigrations(Set<Migration> migrations, [int? version]) {
    assert((version == null) || (version > -1), 'version must be greater than -1');
    version = version ?? MigrationManager.latestMigrationVersion(migrations);
    final commands = expandMigrations(migrations);
    final tables = commands.fold(<SchemaTable>{}, _commandToSchema);

    return Schema(
      version,
      tables: tables,
    );
  }

  /// A sub-function of [Schema.fromMigrations], convert a migration command into a `SchemaObject`.
  static Set<SchemaTable> _commandToSchema(Set<SchemaTable> tables, MigrationCommand command) {
    SchemaTable findTable(String tableName) => tables.firstWhere(
          (s) => s.name == tableName,
          orElse: () => throw StateError('Table $tableName must be inserted first'),
        );

    if (command is InsertTable) {
      tables.add(SchemaTable(command.name));

      final table = tables.firstWhere((s) => s.name == command.name);
      table.columns.add(
        SchemaColumn(
          InsertTable.PRIMARY_KEY_COLUMN,
          Column.integer,
          autoincrement: true,
          nullable: false,
          isPrimaryKey: true,
        ),
      );
    } else if (command is RenameTable) {
      final table = findTable(command.oldName);
      tables.add(SchemaTable(command.newName, columns: table.columns..toSet()));
      // ignore: cascade_invocations
      tables.remove(table);
    } else if (command is DropTable) {
      final table = findTable(command.name);
      tables.remove(table);
    } else if (command is InsertColumn) {
      final table = findTable(command.onTable);
      table.columns.add(
        SchemaColumn(
          command.name,
          command.definitionType,
          autoincrement: command.autoincrement,
          defaultValue: command.defaultValue,
          nullable: command.nullable,
          unique: command.unique,
        ),
      );
    } else if (command is RenameColumn) {
      final table = findTable(command.onTable);
      final column = table.columns.firstWhere(
        (s) => s.name == command.oldName,
        orElse: () => throw StateError('Column ${command.oldName} must be inserted first'),
      );
      final newColumn = column..name = command.newName;

      table.columns.add(newColumn);
      table.columns.remove(column);
    } else if (command is DropColumn) {
      final table = findTable(command.onTable);
      final column = table.columns.firstWhere(
        (s) => s.name == command.name,
        orElse: () => throw StateError('Column ${command.name} must be inserted first'),
      );
      table.columns.remove(column);
    } else if (command is InsertForeignKey) {
      final table = findTable(command.localTableName);
      table.columns.add(
        SchemaColumn(
          command.foreignKeyColumn,
          Column.integer,
          isForeignKey: true,
          foreignTableName: command.foreignTableName,
          onDeleteCascade: command.onDeleteCascade,
          onDeleteSetDefault: command.onDeleteSetDefault,
        ),
      );
    } else if (command is CreateIndex) {
      final table = findTable(command.onTable);
      final tableColumnNames = table.columns.map((c) => c.name);
      for (final c in command.columns) {
        if (!tableColumnNames.contains(c)) {
          throw StateError(
            '${command.onTable} does not contain column $c specified by CreateIndex',
          );
        }
      }
      table.indices.add(
        SchemaIndex(
          columns: command.columns,
          tableName: command.onTable,
          unique: command.unique,
        ),
      );
    } else if (command is DropIndex) {
      for (final table in tables) {
        for (final index in table.indices) {
          // ignore: unnecessary_statements
          index.tableName == table.name;
        }
      }
      final table = tables.firstWhere(
        (s) => s.indices
            .map((i) => CreateIndex.generateName(i.columns, i.tableName!))
            .contains(command.name),
        orElse: () => throw StateError('Index ${command.name} must be inserted first'),
      );
      table.indices.removeWhere((i) => i.name == command.name);
    } else {
      throw UnimplementedError('Cannot create Dart class for ${command.statement}');
    }

    return tables;
  }

  /// Output for generator
  String get forGenerator {
    final tableString = tables
        .map(
          (t) => t.forGenerator
              // Add indentation
              .replaceAll('\n\t', '\n\t\t\t')
              .replaceAll('\n)', '\n\t\t)'),
        )
        .join(',\n\t\t');

    return '''Schema(
\t$version,
\tgeneratorVersion: $generatorVersion,
\ttables: <SchemaTable>{
\t\t$tableString
\t}
)'''
        .replaceAll('\t', '  ');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Schema && version == other.version && tables == other.tables;

  @override
  int get hashCode => version.hashCode ^ tables.hashCode;
}
