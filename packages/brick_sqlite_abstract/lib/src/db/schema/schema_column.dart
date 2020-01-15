// Heavily, heavily inspired by [Aqueduct](https://github.com/stablekernel/aqueduct/blob/master/aqueduct/lib/src/db/schema/schema_builder.dart)
// Unfortunately, some key differences such as inability to use mirrors and the sqlite vs postgres capabilities make DIY a more palatable option than retrofitting
import '../migration.dart' show Migration;
import '../migration_commands.dart';
import 'schema_base.dart';

/// Describes a column object managed by SQLite
/// This should not exist outside of a SchemaTable
class SchemaColumn extends BaseSchemaObject {
  @override
  String name;
  final Type type;
  final bool autoincrement;
  final dynamic defaultValue;
  final bool nullable;
  final bool isPrimaryKey;
  final bool isForeignKey;
  final String foreignTableName;
  final bool unique;

  String tableName;

  SchemaColumn(
    this.name,
    this.type, {
    bool autoincrement,
    this.defaultValue,
    bool nullable,
    this.isPrimaryKey = false,
    this.isForeignKey = false,
    this.foreignTableName,
    bool unique,
  })  : autoincrement = autoincrement ?? InsertColumn.defaults.autoincrement,
        nullable = nullable ?? InsertColumn.defaults.nullable,
        unique = unique ?? InsertColumn.defaults.unique,
        assert(Migration.fromDartPrimitive(type) != null, 'Type must serializable'),
        assert(!isPrimaryKey || type == int, 'Primary key must be an integer'),
        assert(!isForeignKey || (foreignTableName != null));

  @override
  String get forGenerator {
    final parts = ["'$name'", type];

    if (autoincrement != InsertColumn.defaults.autoincrement) {
      parts.add('autoincrement: $autoincrement');
    }

    if (defaultValue != null) {
      parts.add('defaultValue: $defaultValue');
    }

    if (nullable != InsertColumn.defaults.nullable) {
      parts.add('nullable: $nullable');
    }

    if (isPrimaryKey != false) {
      parts.add('isPrimaryKey: $isPrimaryKey');
    }

    if (isForeignKey != false) {
      parts.add('isForeignKey: $isForeignKey');
      parts.add("foreignTableName: '$foreignTableName'");
    }

    if (unique != InsertColumn.defaults.unique) {
      parts.add('unique: $unique');
    }

    return 'SchemaColumn(${parts.join(', ')})';
  }

  @override
  MigrationCommand toCommand({bool shouldDrop = false}) {
    if (shouldDrop) {
      return DropColumn(name, onTable: tableName);
    }

    if (isForeignKey) {
      return InsertForeignKey(tableName, foreignTableName, foreignKeyColumn: name);
    }

    return InsertColumn(
      name,
      Migration.fromDartPrimitive(type),
      onTable: tableName,
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
          name == other?.name &&
          type == other?.type &&
          // tableNames don't compare nicely since they're non-final
          (tableName ?? '').compareTo(other?.tableName ?? '') == 0 &&
          forGenerator == other?.forGenerator;

  @override
  int get hashCode => name.hashCode ^ type.hashCode ^ forGenerator.hashCode;
}
