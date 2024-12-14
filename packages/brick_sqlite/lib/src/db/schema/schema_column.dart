// Heavily, heavily inspired by [Aqueduct](https://github.com/stablekernel/aqueduct/blob/master/aqueduct/lib/src/db/schema/schema_builder.dart)
// Unfortunately, some key differences such as inability to use mirrors and the sqlite vs postgres capabilities make DIY a more palatable option than retrofitting
import 'package:brick_sqlite/src/db/column.dart';
import 'package:brick_sqlite/src/db/migration_commands/drop_column.dart';
import 'package:brick_sqlite/src/db/migration_commands/insert_column.dart';
import 'package:brick_sqlite/src/db/migration_commands/insert_foreign_key.dart';
import 'package:brick_sqlite/src/db/migration_commands/migration_command.dart';
import 'package:brick_sqlite/src/db/schema/schema_base.dart';

/// Describes a column object managed by SQLite
/// This should not exist outside of a SchemaTable
class SchemaColumn extends BaseSchemaObject {
  ///
  String name;

  /// If this column has an autoincrement value
  final bool autoincrement;

  ///
  final Column columnType;

  ///
  final dynamic defaultValue;

  ///
  final bool nullable;

  ///
  final bool isPrimaryKey;

  ///
  final bool isForeignKey;

  ///
  final String? foreignTableName;

  /// Remove row when a referenced foreign key is deleted
  final bool onDeleteCascade;

  /// Update column's value to default when a referenced foreign key is deleted
  final bool onDeleteSetDefault;

  /// If this column's value is unique within the table
  final bool unique;

  ///
  String? tableName;

  /// Describes a column object managed by SQLite
  /// This should not exist outside of a SchemaTable
  SchemaColumn(
    this.name,
    this.columnType, {
    bool? autoincrement,
    this.defaultValue,
    this.isPrimaryKey = false,
    this.isForeignKey = false,
    this.foreignTableName,
    bool? nullable,
    this.onDeleteCascade = false,
    this.onDeleteSetDefault = false,
    bool? unique,
  })  : autoincrement = autoincrement ?? InsertColumn.defaults.autoincrement,
        nullable = nullable ?? InsertColumn.defaults.nullable,
        unique = unique ?? InsertColumn.defaults.unique,
        assert(!isPrimaryKey || columnType == Column.integer, 'Primary key must be an integer'),
        assert(
          !isForeignKey || (foreignTableName != null),
          'Foreign key must have a foreign table name',
        );

  @override
  String get forGenerator {
    final parts = ["'$name'", columnType];

    if (autoincrement != InsertColumn.defaults.autoincrement) {
      parts.add('autoincrement: $autoincrement');
    }

    if (defaultValue != null) {
      parts.add('defaultValue: $defaultValue');
    }

    if (nullable != InsertColumn.defaults.nullable) {
      parts.add('nullable: $nullable');
    }

    if (isPrimaryKey) {
      parts.add('isPrimaryKey: $isPrimaryKey');
    }

    if (isForeignKey) {
      parts.addAll([
        'isForeignKey: $isForeignKey',
        "foreignTableName: '$foreignTableName'",
        'onDeleteCascade: $onDeleteCascade',
        'onDeleteSetDefault: $onDeleteSetDefault',
      ]);
    }

    if (unique != InsertColumn.defaults.unique) {
      parts.add('unique: $unique');
    }

    return 'SchemaColumn(${parts.join(', ')})';
  }

  @override
  MigrationCommand toCommand({bool shouldDrop = false}) {
    if (shouldDrop) {
      return DropColumn(name, onTable: tableName!);
    }

    if (isForeignKey) {
      return InsertForeignKey(
        tableName!,
        foreignTableName!,
        foreignKeyColumn: name,
        onDeleteCascade: onDeleteCascade,
        onDeleteSetDefault: onDeleteSetDefault,
      );
    }

    return InsertColumn(
      name,
      columnType,
      onTable: tableName!,
      defaultValue: defaultValue,
      autoincrement: autoincrement,
      nullable: nullable,
      unique: unique,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SchemaColumn &&
          name == other.name &&
          columnType == other.columnType &&
          // tableNames don't compare nicely since they're non-final
          (tableName ?? '').compareTo(other.tableName ?? '') == 0 &&
          forGenerator == other.forGenerator;

  @override
  int get hashCode => name.hashCode ^ columnType.hashCode ^ forGenerator.hashCode;
}
