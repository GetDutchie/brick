// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20240824214217_up = [
  InsertTable('_brick_KitchenSink_list_offline_first_model'),
  InsertTable('_brick_KitchenSink_set_offline_first_model'),
  InsertTable('_brick_KitchenSink_list_offline_first_serdes'),
  InsertTable('_brick_KitchenSink_set_offline_first_serdes'),
  InsertTable('KitchenSink'),
  InsertTable('Mounty'),
  InsertTable('_brick_Horse_mounties'),
  InsertTable('Horse'),
  InsertForeignKey(
    '_brick_KitchenSink_list_offline_first_model',
    'KitchenSink',
    foreignKeyColumn: 'l_KitchenSink_brick_id',
    onDeleteCascade: true,
    onDeleteSetDefault: false,
  ),
  InsertForeignKey(
    '_brick_KitchenSink_list_offline_first_model',
    'Mounty',
    foreignKeyColumn: 'f_Mounty_brick_id',
    onDeleteCascade: true,
    onDeleteSetDefault: false,
  ),
  InsertForeignKey(
    '_brick_KitchenSink_set_offline_first_model',
    'KitchenSink',
    foreignKeyColumn: 'l_KitchenSink_brick_id',
    onDeleteCascade: true,
    onDeleteSetDefault: false,
  ),
  InsertForeignKey(
    '_brick_KitchenSink_set_offline_first_model',
    'Mounty',
    foreignKeyColumn: 'f_Mounty_brick_id',
    onDeleteCascade: true,
    onDeleteSetDefault: false,
  ),
  InsertForeignKey(
    '_brick_KitchenSink_list_offline_first_serdes',
    'KitchenSink',
    foreignKeyColumn: 'l_KitchenSink_brick_id',
    onDeleteCascade: true,
    onDeleteSetDefault: false,
  ),
  InsertForeignKey(
    '_brick_KitchenSink_list_offline_first_serdes',
    'Hat',
    foreignKeyColumn: 'f_Hat_brick_id',
    onDeleteCascade: true,
    onDeleteSetDefault: false,
  ),
  InsertForeignKey(
    '_brick_KitchenSink_set_offline_first_serdes',
    'KitchenSink',
    foreignKeyColumn: 'l_KitchenSink_brick_id',
    onDeleteCascade: true,
    onDeleteSetDefault: false,
  ),
  InsertForeignKey(
    '_brick_KitchenSink_set_offline_first_serdes',
    'Hat',
    foreignKeyColumn: 'f_Hat_brick_id',
    onDeleteCascade: true,
    onDeleteSetDefault: false,
  ),
  InsertColumn('any_string', Column.varchar, onTable: 'KitchenSink'),
  InsertColumn('any_int', Column.integer, onTable: 'KitchenSink'),
  InsertColumn('any_double', Column.Double, onTable: 'KitchenSink'),
  InsertColumn('any_num', Column.num, onTable: 'KitchenSink'),
  InsertColumn('any_date_time', Column.datetime, onTable: 'KitchenSink'),
  InsertColumn('any_bool', Column.boolean, onTable: 'KitchenSink'),
  InsertColumn('any_map', Column.varchar, onTable: 'KitchenSink'),
  InsertColumn('enum_from_index', Column.integer, onTable: 'KitchenSink'),
  InsertColumn('any_list', Column.varchar, onTable: 'KitchenSink'),
  InsertColumn('any_set', Column.varchar, onTable: 'KitchenSink'),
  InsertForeignKey(
    'KitchenSink',
    'Mounty',
    foreignKeyColumn: 'offline_first_model_Mounty_brick_id',
    onDeleteCascade: false,
    onDeleteSetDefault: false,
  ),
  InsertForeignKey(
    'KitchenSink',
    'Hat',
    foreignKeyColumn: 'offline_first_serdes_Hat_brick_id',
    onDeleteCascade: false,
    onDeleteSetDefault: false,
  ),
  InsertColumn('rest_annotation_name', Column.varchar, onTable: 'KitchenSink'),
  InsertColumn('rest_annotation_default_value', Column.varchar, onTable: 'KitchenSink'),
  InsertColumn('rest_annotation_nullable', Column.varchar, onTable: 'KitchenSink'),
  InsertColumn('rest_annotation_ignore', Column.varchar, onTable: 'KitchenSink'),
  InsertColumn('rest_annotation_ignore_to', Column.varchar, onTable: 'KitchenSink'),
  InsertColumn('rest_annotation_ignore_from', Column.varchar, onTable: 'KitchenSink'),
  InsertColumn('rest_annotation_from_generator', Column.varchar, onTable: 'KitchenSink'),
  InsertColumn('rest_annotation_to_generator', Column.varchar, onTable: 'KitchenSink'),
  InsertColumn('enum_from_string', Column.integer, onTable: 'KitchenSink'),
  InsertColumn('sqlite_annotation_nullable', Column.varchar, onTable: 'KitchenSink'),
  InsertColumn('sqlite_annotation_default_value', Column.varchar, onTable: 'KitchenSink'),
  InsertColumn('sqlite_annotation_from_generator', Column.varchar, onTable: 'KitchenSink'),
  InsertColumn('sqlite_annotation_to_generator', Column.varchar, onTable: 'KitchenSink'),
  InsertColumn('sqlite_annotation_unique', Column.varchar, onTable: 'KitchenSink', unique: true),
  InsertColumn('custom column name', Column.varchar, onTable: 'KitchenSink'),
  InsertForeignKey(
    'KitchenSink',
    'Mounty',
    foreignKeyColumn: 'offline_first_where_Mounty_brick_id',
    onDeleteCascade: false,
    onDeleteSetDefault: false,
  ),
  InsertColumn('name', Column.varchar, onTable: 'Mounty'),
  InsertColumn('email', Column.varchar, onTable: 'Mounty'),
  InsertForeignKey(
    'Mounty',
    'Hat',
    foreignKeyColumn: 'hat_Hat_brick_id',
    onDeleteCascade: false,
    onDeleteSetDefault: false,
  ),
  InsertForeignKey(
    '_brick_Horse_mounties',
    'Horse',
    foreignKeyColumn: 'l_Horse_brick_id',
    onDeleteCascade: true,
    onDeleteSetDefault: false,
  ),
  InsertForeignKey(
    '_brick_Horse_mounties',
    'Mounty',
    foreignKeyColumn: 'f_Mounty_brick_id',
    onDeleteCascade: true,
    onDeleteSetDefault: false,
  ),
  InsertColumn('name', Column.varchar, onTable: 'Horse'),
  CreateIndex(
    columns: ['l_KitchenSink_brick_id', 'f_Mounty_brick_id'],
    onTable: '_brick_KitchenSink_list_offline_first_model',
    unique: true,
  ),
  CreateIndex(
    columns: ['l_KitchenSink_brick_id', 'f_Mounty_brick_id'],
    onTable: '_brick_KitchenSink_set_offline_first_model',
    unique: true,
  ),
  CreateIndex(
    columns: ['l_KitchenSink_brick_id', 'f_Hat_brick_id'],
    onTable: '_brick_KitchenSink_list_offline_first_serdes',
    unique: true,
  ),
  CreateIndex(
    columns: ['l_KitchenSink_brick_id', 'f_Hat_brick_id'],
    onTable: '_brick_KitchenSink_set_offline_first_serdes',
    unique: true,
  ),
  CreateIndex(
    columns: ['l_Horse_brick_id', 'f_Mounty_brick_id'],
    onTable: '_brick_Horse_mounties',
    unique: true,
  ),
];

const List<MigrationCommand> _migration_20240824214217_down = [
  DropTable('_brick_KitchenSink_list_offline_first_model'),
  DropTable('_brick_KitchenSink_set_offline_first_model'),
  DropTable('_brick_KitchenSink_list_offline_first_serdes'),
  DropTable('_brick_KitchenSink_set_offline_first_serdes'),
  DropTable('KitchenSink'),
  DropTable('Mounty'),
  DropTable('_brick_Horse_mounties'),
  DropTable('Horse'),
  DropColumn('l_KitchenSink_brick_id', onTable: '_brick_KitchenSink_list_offline_first_model'),
  DropColumn('f_Mounty_brick_id', onTable: '_brick_KitchenSink_list_offline_first_model'),
  DropColumn('l_KitchenSink_brick_id', onTable: '_brick_KitchenSink_set_offline_first_model'),
  DropColumn('f_Mounty_brick_id', onTable: '_brick_KitchenSink_set_offline_first_model'),
  DropColumn('l_KitchenSink_brick_id', onTable: '_brick_KitchenSink_list_offline_first_serdes'),
  DropColumn('f_Hat_brick_id', onTable: '_brick_KitchenSink_list_offline_first_serdes'),
  DropColumn('l_KitchenSink_brick_id', onTable: '_brick_KitchenSink_set_offline_first_serdes'),
  DropColumn('f_Hat_brick_id', onTable: '_brick_KitchenSink_set_offline_first_serdes'),
  DropColumn('any_string', onTable: 'KitchenSink'),
  DropColumn('any_int', onTable: 'KitchenSink'),
  DropColumn('any_double', onTable: 'KitchenSink'),
  DropColumn('any_num', onTable: 'KitchenSink'),
  DropColumn('any_date_time', onTable: 'KitchenSink'),
  DropColumn('any_bool', onTable: 'KitchenSink'),
  DropColumn('any_map', onTable: 'KitchenSink'),
  DropColumn('enum_from_index', onTable: 'KitchenSink'),
  DropColumn('any_list', onTable: 'KitchenSink'),
  DropColumn('any_set', onTable: 'KitchenSink'),
  DropColumn('offline_first_model_Mounty_brick_id', onTable: 'KitchenSink'),
  DropColumn('offline_first_serdes_Hat_brick_id', onTable: 'KitchenSink'),
  DropColumn('rest_annotation_name', onTable: 'KitchenSink'),
  DropColumn('rest_annotation_default_value', onTable: 'KitchenSink'),
  DropColumn('rest_annotation_nullable', onTable: 'KitchenSink'),
  DropColumn('rest_annotation_ignore', onTable: 'KitchenSink'),
  DropColumn('rest_annotation_ignore_to', onTable: 'KitchenSink'),
  DropColumn('rest_annotation_ignore_from', onTable: 'KitchenSink'),
  DropColumn('rest_annotation_from_generator', onTable: 'KitchenSink'),
  DropColumn('rest_annotation_to_generator', onTable: 'KitchenSink'),
  DropColumn('enum_from_string', onTable: 'KitchenSink'),
  DropColumn('sqlite_annotation_nullable', onTable: 'KitchenSink'),
  DropColumn('sqlite_annotation_default_value', onTable: 'KitchenSink'),
  DropColumn('sqlite_annotation_from_generator', onTable: 'KitchenSink'),
  DropColumn('sqlite_annotation_to_generator', onTable: 'KitchenSink'),
  DropColumn('sqlite_annotation_unique', onTable: 'KitchenSink'),
  DropColumn('custom column name', onTable: 'KitchenSink'),
  DropColumn('offline_first_where_Mounty_brick_id', onTable: 'KitchenSink'),
  DropColumn('name', onTable: 'Mounty'),
  DropColumn('email', onTable: 'Mounty'),
  DropColumn('hat_Hat_brick_id', onTable: 'Mounty'),
  DropColumn('l_Horse_brick_id', onTable: '_brick_Horse_mounties'),
  DropColumn('f_Mounty_brick_id', onTable: '_brick_Horse_mounties'),
  DropColumn('name', onTable: 'Horse'),
  DropIndex(
    'index__brick_KitchenSink_list_offline_first_model_on_l_KitchenSink_brick_id_f_Mounty_brick_id',
  ),
  DropIndex(
    'index__brick_KitchenSink_set_offline_first_model_on_l_KitchenSink_brick_id_f_Mounty_brick_id',
  ),
  DropIndex(
    'index__brick_KitchenSink_list_offline_first_serdes_on_l_KitchenSink_brick_id_f_Hat_brick_id',
  ),
  DropIndex(
    'index__brick_KitchenSink_set_offline_first_serdes_on_l_KitchenSink_brick_id_f_Hat_brick_id',
  ),
  DropIndex('index__brick_Horse_mounties_on_l_Horse_brick_id_f_Mounty_brick_id'),
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20240824214217',
  up: _migration_20240824214217_up,
  down: _migration_20240824214217_down,
)
class Migration20240824214217 extends Migration {
  const Migration20240824214217()
      : super(
          version: 20240824214217,
          up: _migration_20240824214217_up,
          down: _migration_20240824214217_down,
        );
}
