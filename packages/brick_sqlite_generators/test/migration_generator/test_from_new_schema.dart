import 'package:brick_sqlite/db.dart';

const version = 1;

const up = [
  InsertTable('User'),
  InsertColumn('address', Column.varchar, onTable: 'User'),
];

const down = [
  DropColumn('address', onTable: 'User'),
];

@Migratable(version: '$version', up: up, down: down)
class Migration1 extends Migration {
  const Migration1() : super(version: version, up: up, down: down);
}

final schema = Schema(
  2,
  tables: <SchemaTable>{
    SchemaTable(
      'User',
      columns: <SchemaColumn>{
        SchemaColumn(
          '_brick_id',
          Column.integer,
          autoincrement: true,
          nullable: false,
          isPrimaryKey: true,
        ),
        SchemaColumn('address', Column.varchar),
        SchemaColumn('email', Column.varchar),
      },
    ),
  },
);

const output = '''
// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_2_up = [
  InsertColumn('email', Column.varchar, onTable: 'User')
];

const List<MigrationCommand> _migration_2_down = [
  DropColumn('email', onTable: 'User')
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '2',
  up: _migration_2_up,
  down: _migration_2_down,
)
class Migration2 extends Migration {
  const Migration2()
    : super(
        version: 2,
        up: _migration_2_up,
        down: _migration_2_down,
      );
}
''';
