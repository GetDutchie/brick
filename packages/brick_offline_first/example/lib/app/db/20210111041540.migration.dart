// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20210111041540_up = [
  DropColumn('KitchenSink_brick_id', onTable: '_brick_KitchenSink_list_offline_first_model'),
  DropColumn('Mounty_brick_id', onTable: '_brick_KitchenSink_list_offline_first_model'),
  DropColumn('KitchenSink_brick_id', onTable: '_brick_KitchenSink_set_offline_first_model'),
  DropColumn('Mounty_brick_id', onTable: '_brick_KitchenSink_set_offline_first_model'),
  DropColumn('Horse_brick_id', onTable: '_brick_Horse_mounties'),
  DropColumn('Mounty_brick_id', onTable: '_brick_Horse_mounties'),
  InsertForeignKey('_brick_Horse_mounties', 'Horse',
      foreignKeyColumn: 'l_Horse_brick_id', onDeleteCascade: true, onDeleteSetDefault: false),
  InsertForeignKey('_brick_Horse_mounties', 'Mounty',
      foreignKeyColumn: 'f_Mounty_brick_id', onDeleteCascade: true, onDeleteSetDefault: false),
  InsertForeignKey('_brick_KitchenSink_list_offline_first_model', 'KitchenSink',
      foreignKeyColumn: 'l_KitchenSink_brick_id', onDeleteCascade: true, onDeleteSetDefault: false),
  InsertForeignKey('_brick_KitchenSink_list_offline_first_model', 'Mounty',
      foreignKeyColumn: 'f_Mounty_brick_id', onDeleteCascade: true, onDeleteSetDefault: false),
  InsertForeignKey('_brick_KitchenSink_set_offline_first_model', 'KitchenSink',
      foreignKeyColumn: 'l_KitchenSink_brick_id', onDeleteCascade: true, onDeleteSetDefault: false),
  InsertForeignKey('_brick_KitchenSink_set_offline_first_model', 'Mounty',
      foreignKeyColumn: 'f_Mounty_brick_id', onDeleteCascade: true, onDeleteSetDefault: false),
  CreateIndex(
      columns: ['l_Horse_brick_id', 'f_Mounty_brick_id'],
      onTable: '_brick_Horse_mounties',
      unique: true),
  CreateIndex(
      columns: ['l_KitchenSink_brick_id', 'f_Mounty_brick_id'],
      onTable: '_brick_KitchenSink_list_offline_first_model',
      unique: true),
  CreateIndex(
      columns: ['l_KitchenSink_brick_id', 'f_Mounty_brick_id'],
      onTable: '_brick_KitchenSink_set_offline_first_model',
      unique: true),
];

const List<MigrationCommand> _migration_20210111041540_down = [
  DropColumn('l_Horse_brick_id', onTable: '_brick_Horse_mounties'),
  DropColumn('f_Mounty_brick_id', onTable: '_brick_Horse_mounties'),
  DropColumn('l_KitchenSink_brick_id', onTable: '_brick_KitchenSink_list_offline_first_model'),
  DropColumn('f_Mounty_brick_id', onTable: '_brick_KitchenSink_list_offline_first_model'),
  DropColumn('l_KitchenSink_brick_id', onTable: '_brick_KitchenSink_set_offline_first_model'),
  DropColumn('f_Mounty_brick_id', onTable: '_brick_KitchenSink_set_offline_first_model'),
  DropIndex('index__brick_Horse_mounties_on_l_Horse_brick_id_f_Mounty_brick_id'),
  DropIndex(
      'index__brick_KitchenSink_list_offline_first_model_on_l_KitchenSink_brick_id_f_Mounty_brick_id'),
  DropIndex(
      'index__brick_KitchenSink_set_offline_first_model_on_l_KitchenSink_brick_id_f_Mounty_brick_id'),
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20210111041540',
  up: _migration_20210111041540_up,
  down: _migration_20210111041540_down,
)
class Migration20210111041540 extends Migration {
  const Migration20210111041540()
      : super(
          version: 20210111041540,
          up: _migration_20210111041540_up,
          down: _migration_20210111041540_down,
        );
}
