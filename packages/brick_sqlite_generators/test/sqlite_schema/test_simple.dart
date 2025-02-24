import 'package:brick_sqlite/brick_sqlite.dart';

const migrationOutput = '''
// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_1_up = [
  InsertTable('Simple'),
  InsertColumn('name', Column.varchar, onTable: 'Simple')
];

const List<MigrationCommand> _migration_1_down = [
  DropTable('Simple'),
  DropColumn('name', onTable: 'Simple')
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '1',
  up: _migration_1_up,
  down: _migration_1_down,
)
class Migration1 extends Migration {
  const Migration1()
    : super(
        version: 1,
        up: _migration_1_up,
        down: _migration_1_down,
      );
}
''';

const output = '''
// GENERATED CODE DO NOT EDIT
// This file should be version controlled
import 'package:brick_sqlite/db.dart';

/// All intelligently-generated migrations from all `@Migratable` classes on disk
final migrations = <Migration>{};

/// A consumable database structure including the latest generated migration.
final schema = Schema(
  0,
  generatorVersion: 1,
  tables: <SchemaTable>{
    SchemaTable(
      'Simple',
      columns: <SchemaColumn>{
        SchemaColumn(
          '_brick_id',
          Column.integer,
          autoincrement: true,
          nullable: false,
          isPrimaryKey: true,
        ),
        SchemaColumn('name', Column.varchar),
      },
      indices: <SchemaIndex>{},
    ),
  },
);
''';

/// [SqliteSerializable] **does not** produce code.
/// A `const` class is required from an non-relative import,
/// and [SqliteSerializable] was arbitrarily chosen for this test.
/// This will do nothing outside of this exact test suite.
@SqliteSerializable()
class Simple extends SqliteModel {
  final String? name;

  Simple({this.name});
}
