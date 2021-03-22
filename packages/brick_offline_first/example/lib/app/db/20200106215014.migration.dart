// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20200106215014_up = [
  InsertTable('Mounty'),
  InsertColumn('name', Column.varchar, onTable: 'Mounty'),
  InsertColumn('email', Column.varchar, onTable: 'Mounty'),
  InsertColumn('hat', Column.varchar, onTable: 'Mounty')
];

const List<MigrationCommand> _migration_20200106215014_down = [
  DropTable('Mounty'),
  DropColumn('name', onTable: 'Mounty'),
  DropColumn('email', onTable: 'Mounty'),
  DropColumn('hat', onTable: 'Mounty')
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20200106215014',
  up: _migration_20200106215014_up,
  down: _migration_20200106215014_down,
)
class Migration20200106215014 extends Migration {
  const Migration20200106215014()
      : super(
          version: 20200106215014,
          up: _migration_20200106215014_up,
          down: _migration_20200106215014_down,
        );
}
