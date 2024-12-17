// Heavily, heavily inspired by [Aqueduct](https://github.com/stablekernel/aqueduct/blob/master/aqueduct/lib/src/db/schema/schema_builder.dart)
// Unfortunately, some key differences such as inability to use mirrors and the sqlite vs postgres capabilities make DIY a more palatable option than retrofitting

import 'package:brick_sqlite/src/db/migration_commands/drop_table.dart';
import 'package:brick_sqlite/src/db/migration_commands/insert_table.dart';
import 'package:brick_sqlite/src/db/migration_commands/migration_command.dart';
import 'package:brick_sqlite/src/db/schema/schema_base.dart';
import 'package:brick_sqlite/src/db/schema/schema_column.dart';
import 'package:brick_sqlite/src/db/schema/schema_index.dart';

/// Describes a table object managed by SQLite
class SchemaTable extends BaseSchemaObject {
  ///
  final String name;

  ///
  Set<SchemaColumn> columns;

  ///
  Set<SchemaIndex> indices;

  /// Describes a table object managed by SQLite
  SchemaTable(
    this.name, {
    Set<SchemaColumn>? columns,
    Set<SchemaIndex>? indices,
  })  : columns = columns ?? <SchemaColumn>{},
        indices = indices ?? <SchemaIndex>{};

  @override
  String get forGenerator {
    final columnsStringified = columns.map((c) => c.forGenerator).join(',\n\t\t');
    final indicesStringified = indices.map((c) => c.forGenerator).join(',\n\t\t');
    final printedIndices = indices.isNotEmpty ? '\t\t$indicesStringified' : '';
    return '''SchemaTable(
\t'$name',
\tcolumns: <SchemaColumn>{
\t\t$columnsStringified
\t},
\tindices: <SchemaIndex>{
$printedIndices
\t}
)''';
  }

  @override
  MigrationCommand toCommand({bool shouldDrop = false}) =>
      shouldDrop ? DropTable(name) : InsertTable(name);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SchemaTable && name == other.name;

  @override
  int get hashCode => name.hashCode;
}
