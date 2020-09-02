import '../migration_commands.dart';
import 'schema_base.dart';

class SchemaIndex extends BaseSchemaObject {
  final List<String> columns;

  String tableName;

  final bool unique;

  SchemaIndex({
    this.columns,
    this.tableName,
    this.unique,
  });

  @override
  String get forGenerator =>
      "SchemaIndex(columns: [${columns.map((c) => "'$c'").join(', ')}], unique: $unique)";

  @override
  MigrationCommand toCommand() => CreateIndex(columns: columns, onTable: tableName, unique: unique);

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
