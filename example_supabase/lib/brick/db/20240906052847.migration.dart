// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20240906052847_up = [
  InsertTable('_brick_Customer_pizzas'),
  InsertTable('Customer'),
  InsertTable('Pizza'),
  InsertForeignKey(
    '_brick_Customer_pizzas',
    'Customer',
    foreignKeyColumn: 'l_Customer_brick_id',
    onDeleteCascade: true,
    onDeleteSetDefault: false,
  ),
  InsertForeignKey(
    '_brick_Customer_pizzas',
    'Pizza',
    foreignKeyColumn: 'f_Pizza_brick_id',
    onDeleteCascade: true,
    onDeleteSetDefault: false,
  ),
  InsertColumn('id', Column.integer, onTable: 'Customer', unique: true),
  InsertColumn('first_name', Column.varchar, onTable: 'Customer'),
  InsertColumn('last_name', Column.varchar, onTable: 'Customer'),
  InsertColumn('id', Column.integer, onTable: 'Pizza', unique: true),
  InsertColumn('toppings', Column.varchar, onTable: 'Pizza'),
  InsertColumn('frozen', Column.boolean, onTable: 'Pizza'),
  CreateIndex(
    columns: ['l_Customer_brick_id', 'f_Pizza_brick_id'],
    onTable: '_brick_Customer_pizzas',
    unique: true,
  ),
];

const List<MigrationCommand> _migration_20240906052847_down = [
  DropTable('_brick_Customer_pizzas'),
  DropTable('Customer'),
  DropTable('Pizza'),
  DropColumn('l_Customer_brick_id', onTable: '_brick_Customer_pizzas'),
  DropColumn('f_Pizza_brick_id', onTable: '_brick_Customer_pizzas'),
  DropColumn('id', onTable: 'Customer'),
  DropColumn('first_name', onTable: 'Customer'),
  DropColumn('last_name', onTable: 'Customer'),
  DropColumn('id', onTable: 'Pizza'),
  DropColumn('toppings', onTable: 'Pizza'),
  DropColumn('frozen', onTable: 'Pizza'),
  DropIndex('index__brick_Customer_pizzas_on_l_Customer_brick_id_f_Pizza_brick_id'),
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20240906052847',
  up: _migration_20240906052847_up,
  down: _migration_20240906052847_down,
)
class Migration20240906052847 extends Migration {
  const Migration20240906052847()
      : super(
          version: 20240906052847,
          up: _migration_20240906052847_up,
          down: _migration_20240906052847_down,
        );
}
