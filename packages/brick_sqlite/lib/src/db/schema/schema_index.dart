import 'package:brick_sqlite/src/db/migration_commands/create_index.dart';
import 'package:brick_sqlite/src/db/migration_commands/migration_command.dart';
import 'package:brick_sqlite/src/db/schema/schema_base.dart';

/// A definition for the schema of an index
class SchemaIndex extends BaseSchemaObject {
  ///
  String? name;

  ///
  final List<String> columns;

  ///
  String? tableName;

  ///
  final bool unique;

  /// A definition for the schema of an index
  SchemaIndex({
    required this.columns,
    this.tableName,
    required this.unique,
  });

  @override
  String get forGenerator =>
      "SchemaIndex(columns: [${columns.map((c) => "'$c'").join(', ')}], unique: $unique)";

  @override
  MigrationCommand toCommand() =>
      CreateIndex(columns: columns, onTable: tableName!, unique: unique);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SchemaIndex &&
          name == other.name &&
          // tableNames don't compare nicely since they're non-final
          (tableName ?? '').compareTo(other.tableName ?? '') == 0 &&
          forGenerator == other.forGenerator;

  @override
  int get hashCode => name.hashCode ^ forGenerator.hashCode;
}
