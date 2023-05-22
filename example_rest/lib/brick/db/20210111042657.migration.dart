// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20210111042657_up = [
  DropColumn('pizzas', onTable: 'Customer'),
  InsertTable('_brick_Customer_pizzas'),
  InsertForeignKey('_brick_Customer_pizzas', 'Customer',
      foreignKeyColumn: 'l_Customer_brick_id', onDeleteCascade: true, onDeleteSetDefault: false),
  InsertForeignKey('_brick_Customer_pizzas', 'Pizza',
      foreignKeyColumn: 'f_Pizza_brick_id', onDeleteCascade: true, onDeleteSetDefault: false),
  CreateIndex(
      columns: ['l_Customer_brick_id', 'f_Pizza_brick_id'],
      onTable: '_brick_Customer_pizzas',
      unique: true)
];

const List<MigrationCommand> _migration_20210111042657_down = [
  DropTable('_brick_Customer_pizzas'),
  DropColumn('l_Customer_brick_id', onTable: '_brick_Customer_pizzas'),
  DropColumn('f_Pizza_brick_id', onTable: '_brick_Customer_pizzas'),
  DropIndex('index__brick_Customer_pizzas_on_l_Customer_brick_id_f_Pizza_brick_id')
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20210111042657',
  up: _migration_20210111042657_up,
  down: _migration_20210111042657_down,
)
class Migration20210111042657 extends Migration {
  const Migration20210111042657()
      : super(
          version: 20210111042657,
          up: _migration_20210111042657_up,
          down: _migration_20210111042657_down,
        );
}
