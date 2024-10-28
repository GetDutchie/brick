// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20241028154657_up = [
  InsertTable('Customer'),
  InsertTable('Pizza'),
  InsertColumn('id', Column.varchar, onTable: 'Customer', unique: true),
  InsertColumn('name', Column.varchar, onTable: 'Customer', nullable: false),
  InsertColumn('id', Column.varchar, onTable: 'Pizza', unique: true),
  InsertColumn('frozen', Column.boolean, onTable: 'Pizza'),
  CreateIndex(columns: ['id'], onTable: 'Customer', unique: true)
];

const List<MigrationCommand> _migration_20241028154657_down = [
  DropTable('Customer'),
  DropTable('Pizza'),
  DropColumn('id', onTable: 'Customer'),
  DropColumn('name', onTable: 'Customer'),
  DropColumn('id', onTable: 'Pizza'),
  DropColumn('frozen', onTable: 'Pizza'),
  DropIndex('index_Customer_on_id')
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20241028154657',
  up: _migration_20241028154657_up,
  down: _migration_20241028154657_down,
)
class Migration20241028154657 extends Migration {
  const Migration20241028154657()
    : super(
        version: 20241028154657,
        up: _migration_20241028154657_up,
        down: _migration_20241028154657_down,
      );
}
