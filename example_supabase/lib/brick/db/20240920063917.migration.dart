// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
// ignore_for_file: public_member_api_docs, constant_identifier_names

part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20240920063917_up = [
  InsertTable('Customer'),
  InsertTable('Pizza'),
  InsertColumn('id', Column.varchar, onTable: 'Customer', unique: true),
  InsertColumn('first_name', Column.varchar, onTable: 'Customer'),
  InsertColumn('last_name', Column.varchar, onTable: 'Customer'),
  InsertColumn('id', Column.varchar, onTable: 'Pizza', unique: true),
  InsertColumn('frozen', Column.boolean, onTable: 'Pizza'),
  InsertForeignKey(
    'Pizza',
    'Customer',
    foreignKeyColumn: 'customer_Customer_brick_id',
  ),
];

const List<MigrationCommand> _migration_20240920063917_down = [
  DropTable('Customer'),
  DropTable('Pizza'),
  DropColumn('id', onTable: 'Customer'),
  DropColumn('first_name', onTable: 'Customer'),
  DropColumn('last_name', onTable: 'Customer'),
  DropColumn('id', onTable: 'Pizza'),
  DropColumn('frozen', onTable: 'Pizza'),
  DropColumn('customer_Customer_brick_id', onTable: 'Pizza'),
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20240920063917',
  up: _migration_20240920063917_up,
  down: _migration_20240920063917_down,
)
class Migration20240920063917 extends Migration {
  const Migration20240920063917()
      : super(
          version: 20240920063917,
          up: _migration_20240920063917_up,
          down: _migration_20240920063917_down,
        );
}
