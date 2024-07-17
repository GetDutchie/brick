// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20240714103011_up = [
  InsertTable('Customer'),
  InsertColumn('id', Column.varchar, onTable: 'Customer', unique: true),
  InsertColumn('first_name', Column.varchar, onTable: 'Customer'),
  InsertColumn('last_name', Column.varchar, onTable: 'Customer'),
  InsertColumn('created_at', Column.datetime, onTable: 'Customer'),
];

const List<MigrationCommand> _migration_20240714103011_down = [
  DropTable('Customer'),
  DropColumn('id', onTable: 'Customer'),
  DropColumn('first_name', onTable: 'Customer'),
  DropColumn('last_name', onTable: 'Customer'),
  DropColumn('created_at', onTable: 'Customer'),
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20240714103011',
  up: _migration_20240714103011_up,
  down: _migration_20240714103011_down,
)
class Migration20240714103011 extends Migration {
  const Migration20240714103011()
      : super(
          version: 20240714103011,
          up: _migration_20240714103011_up,
          down: _migration_20240714103011_down,
        );
}
