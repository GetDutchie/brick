// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20200616215211_up = [
  DropColumn('list_offline_first_model', onTable: 'KitchenSink'),
  DropColumn('set_offline_first_model', onTable: 'KitchenSink'),
  InsertTable('_brick_KitchenSink_list_offline_first_model'),
  InsertTable('_brick_KitchenSink_set_offline_first_model'),
  InsertForeignKey('_brick_KitchenSink_list_offline_first_model', 'KitchenSink',
      foreignKeyColumn: 'KitchenSink_brick_id', onDeleteCascade: true),
  InsertForeignKey('_brick_KitchenSink_list_offline_first_model', 'Mounty',
      foreignKeyColumn: 'Mounty_brick_id', onDeleteCascade: true),
  InsertForeignKey('_brick_KitchenSink_set_offline_first_model', 'KitchenSink',
      foreignKeyColumn: 'KitchenSink_brick_id', onDeleteCascade: true),
  InsertForeignKey('_brick_KitchenSink_set_offline_first_model', 'Mounty',
      foreignKeyColumn: 'Mounty_brick_id', onDeleteCascade: true),
];

const List<MigrationCommand> _migration_20200616215211_down = [
  DropTable('_brick_KitchenSink_list_offline_first_model'),
  DropTable('_brick_KitchenSink_set_offline_first_model'),
  DropColumn('KitchenSink_brick_id', onTable: '_brick_KitchenSink_list_offline_first_model'),
  DropColumn('Mounty_brick_id', onTable: '_brick_KitchenSink_list_offline_first_model'),
  DropColumn('KitchenSink_brick_id', onTable: '_brick_KitchenSink_set_offline_first_model'),
  DropColumn('Mounty_brick_id', onTable: '_brick_KitchenSink_set_offline_first_model'),
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20200616215211',
  up: _migration_20200616215211_up,
  down: _migration_20200616215211_down,
)
class Migration20200616215211 extends Migration {
  const Migration20200616215211()
      : super(
          version: 20200616215211,
          up: _migration_20200616215211_up,
          down: _migration_20200616215211_down,
        );
}
