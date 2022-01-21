// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20200124174431_up = [
  InsertTable('KitchenSink'),
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
  InsertForeignKey('KitchenSink', 'Mounty',
      foreignKeyColumn: 'offline_first_model_Mounty_brick_id'),
  InsertColumn('list_offline_first_model', Column.varchar, onTable: 'KitchenSink'),
  InsertColumn('set_offline_first_model', Column.varchar, onTable: 'KitchenSink'),
  InsertColumn('offline_first_serdes', Column.varchar, onTable: 'KitchenSink'),
  InsertColumn('list_offline_first_serdes', Column.varchar, onTable: 'KitchenSink'),
  InsertColumn('set_offline_first_serdes', Column.varchar, onTable: 'KitchenSink'),
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
  InsertForeignKey('KitchenSink', 'Mounty', foreignKeyColumn: 'offline_first_where_Mounty_brick_id')
];

const List<MigrationCommand> _migration_20200124174431_down = [
  DropTable('KitchenSink'),
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
  DropColumn('list_offline_first_model', onTable: 'KitchenSink'),
  DropColumn('set_offline_first_model', onTable: 'KitchenSink'),
  DropColumn('offline_first_serdes', onTable: 'KitchenSink'),
  DropColumn('list_offline_first_serdes', onTable: 'KitchenSink'),
  DropColumn('set_offline_first_serdes', onTable: 'KitchenSink'),
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
  DropColumn('offline_first_where_Mounty_brick_id', onTable: 'KitchenSink')
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20200124174431',
  up: _migration_20200124174431_up,
  down: _migration_20200124174431_down,
)
class Migration20200124174431 extends Migration {
  const Migration20200124174431()
      : super(
          version: 20200124174431,
          up: _migration_20200124174431_up,
          down: _migration_20200124174431_down,
        );
}
