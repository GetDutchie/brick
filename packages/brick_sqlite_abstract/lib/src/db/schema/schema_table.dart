// Heavily, heavily inspired by [Aqueduct](https://github.com/stablekernel/aqueduct/blob/master/aqueduct/lib/src/db/schema/schema_builder.dart)
// Unfortunately, some key differences such as inability to use mirrors and the sqlite vs postgres capabilities make DIY a more palatable option than retrofitting

import '../migration_commands.dart' show DropTable, InsertTable;
import 'schema_column.dart';
import 'schema_base.dart';

/// Describes a table object managed by SQLite
class SchemaTable extends BaseSchemaObject {
  final String name;
  Set<SchemaColumn> columns;

  SchemaTable(
    this.name, {
    Set<SchemaColumn> columns,
  }) : columns = columns ?? Set<SchemaColumn>();

  get forGenerator {
    final columnsStringified = columns.map((c) => c.forGenerator).join(",\n\t\t");
    return """SchemaTable(
\t"$name",
\tcolumns: Set.from([
\t\t$columnsStringified
\t])
)""";
  }

  toCommand({bool shouldDrop = false}) => shouldDrop ? DropTable(name) : InsertTable(name);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SchemaTable && this?.name == other?.name;

  @override
  int get hashCode => name.hashCode;
}
