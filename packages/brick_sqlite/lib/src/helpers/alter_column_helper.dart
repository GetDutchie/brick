import 'package:brick_sqlite_abstract/db.dart';
import 'package:sqflite/sqflite.dart' show Database;

/// Workaround for SQLite commands that require altering the table instead of the column.
///
/// Supports [DropColumn], [RenameColumn], [InsertColumn]
class AlterColumnHelper {
  /// The command to restructure the table
  final MigrationCommand command;

  bool get isDrop => command is DropColumn;
  bool get isRename => command is RenameColumn;
  bool get isUniqueInsert => command is InsertColumn && (command as InsertColumn).unique;

  /// Declares if this command requires extra SQLite work to be migrated
  bool get requiresSchema => isDrop || isRename || isUniqueInsert;

  String get tableName {
    assert(requiresSchema);

    if (isDrop) {
      return (command as DropColumn).onTable;
    }

    if (isRename) {
      return (command as RenameColumn).onTable;
    }

    return (command as InsertColumn).onTable;
  }

  AlterColumnHelper(this.command);

  /// Get info about existing columns
  Future<List<Map<String, dynamic>>> tableInfo(Database db) async {
    return await db.rawQuery('PRAGMA table_info("$tableName");');
  }

  /// Create new table with updated column data
  List<Map<String, dynamic>> newColumns(List<Map<String, dynamic>> columns) {
    Map<String, dynamic> convertColumn(Map<String, dynamic> column) {
      final newColumn = Map<String, dynamic>.from(column);

      if (isDrop) {
        final oldColumnName = (command as DropColumn).name;
        if (column['name'] == oldColumnName) {
          return null;
        }
      }

      if (isRename) {
        final oldColumnName = (command as RenameColumn).oldName;
        final newColumnName = (command as RenameColumn).newName;
        if (column['name'] == oldColumnName) {
          newColumn['name'] = newColumnName;
        }
      }

      if (isUniqueInsert) {
        final name = (command as InsertColumn).name;
        if (column['name'] == name) {
          newColumn['unique'] = true;
        }
      }

      return newColumn;
    }

    return columns.map(convertColumn).where((c) => c != null).toList().cast<Map<String, dynamic>>();
  }

  /// Given new columns, create the SQLite statement
  String newColumnsExpression(List<Map<String, dynamic>> columns) {
    return columns.map((Map<String, dynamic> column) {
      final definition = [column['name'] as String, column['type'] as String];

      if (column['notnull'] == 1) {
        definition.add('NOT NULL');
      }

      if (column['dflt_value'] != null) {
        definition.add('DEFAULT ${column['dflt_value']}');
      }

      if (column['pk'] == 1) {
        definition.add('PRIMARY KEY');
      }

      if (column['unique'] == true) {
        definition.add('UNIQUE');
      }

      return definition.join(' ');
    }).join(', ');
  }

  /// Perform the necessary SQLite operation
  Future<void> execute(Database db) async {
    // Ensure table is aware of inserted column first
    if (isUniqueInsert) {
      await db.execute(command.statement);
    }

    final columns = await tableInfo(db);
    final _newColumns = newColumns(columns);
    final _newColumnsExpression = newColumnsExpression(_newColumns);
    final oldColumnNames = columns.map((c) => c['name']).join(', ');
    final newColumnNames = _newColumns.map((c) => c['name']).join(', ');
    final selectExpression = isDrop ? newColumnNames : oldColumnNames;

    await db.execute('PRAGMA foreign_keys = OFF');
    await db.execute('PRAGMA legacy_alter_table = ON');
    await db.transaction((txn) async {
      // Rename existing table
      await txn.execute('ALTER TABLE `$tableName` RENAME TO `temp_$tableName`');

      // Setup new table
      await txn.execute('CREATE TABLE `$tableName` ($_newColumnsExpression)');

      // Copy data
      await txn.execute(
          'INSERT INTO `$tableName`($newColumnNames) SELECT $selectExpression FROM `temp_$tableName`');

      // Drop old table
      await txn.execute('DROP TABLE `temp_$tableName`');
    });
    await db.execute('PRAGMA legacy_alter_table = OFF');
    await db.execute('PRAGMA foreign_keys = ON');
  }
}
