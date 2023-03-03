// GENERATED CODE DO NOT EDIT
// This file should be version controlled
import 'package:brick_sqlite/db.dart';
part '20200616220821.migration.dart';
part '20210111041540.migration.dart';
part '20200106215014.migration.dart';
part '20200124174431.migration.dart';
part '20200616215211.migration.dart';

/// All intelligently-generated migrations from all `@Migratable` classes on disk
final migrations = <Migration>{
  const Migration20200616220821(),
  const Migration20210111041540(),
  const Migration20200106215014(),
  const Migration20200124174431(),
  const Migration20200616215211()
};

/// A consumable database structure including the latest generated migration.
final schema = Schema(20210111041540, generatorVersion: 1, tables: <SchemaTable>{
  SchemaTable('_brick_KitchenSink_list_offline_first_model', columns: <SchemaColumn>{
    SchemaColumn('_brick_id', Column.integer,
        autoincrement: true, nullable: false, isPrimaryKey: true),
    SchemaColumn('l_KitchenSink_brick_id', Column.integer,
        isForeignKey: true,
        foreignTableName: 'KitchenSink',
        onDeleteCascade: true,
        onDeleteSetDefault: false),
    SchemaColumn('f_Mounty_brick_id', Column.integer,
        isForeignKey: true,
        foreignTableName: 'Mounty',
        onDeleteCascade: true,
        onDeleteSetDefault: false)
  }, indices: <SchemaIndex>{
    SchemaIndex(columns: ['l_KitchenSink_brick_id', 'f_Mounty_brick_id'], unique: true)
  }),
  SchemaTable('_brick_KitchenSink_set_offline_first_model', columns: <SchemaColumn>{
    SchemaColumn('_brick_id', Column.integer,
        autoincrement: true, nullable: false, isPrimaryKey: true),
    SchemaColumn('l_KitchenSink_brick_id', Column.integer,
        isForeignKey: true,
        foreignTableName: 'KitchenSink',
        onDeleteCascade: true,
        onDeleteSetDefault: false),
    SchemaColumn('f_Mounty_brick_id', Column.integer,
        isForeignKey: true,
        foreignTableName: 'Mounty',
        onDeleteCascade: true,
        onDeleteSetDefault: false)
  }, indices: <SchemaIndex>{
    SchemaIndex(columns: ['l_KitchenSink_brick_id', 'f_Mounty_brick_id'], unique: true)
  }),
  SchemaTable('KitchenSink', columns: <SchemaColumn>{
    SchemaColumn('_brick_id', Column.integer,
        autoincrement: true, nullable: false, isPrimaryKey: true),
    SchemaColumn('any_string', Column.varchar),
    SchemaColumn('any_int', Column.integer),
    SchemaColumn('any_double', Column.Double),
    SchemaColumn('any_num', Column.num),
    SchemaColumn('any_date_time', Column.datetime),
    SchemaColumn('any_bool', Column.boolean),
    SchemaColumn('any_map', Column.varchar),
    SchemaColumn('enum_from_index', Column.integer),
    SchemaColumn('any_list', Column.varchar),
    SchemaColumn('any_set', Column.varchar),
    SchemaColumn('offline_first_model_Mounty_brick_id', Column.integer,
        isForeignKey: true,
        foreignTableName: 'Mounty',
        onDeleteCascade: false,
        onDeleteSetDefault: false),
    SchemaColumn('offline_first_serdes', Column.varchar),
    SchemaColumn('list_offline_first_serdes', Column.varchar),
    SchemaColumn('set_offline_first_serdes', Column.varchar),
    SchemaColumn('rest_annotation_name', Column.varchar),
    SchemaColumn('rest_annotation_default_value', Column.varchar),
    SchemaColumn('rest_annotation_nullable', Column.varchar),
    SchemaColumn('rest_annotation_ignore', Column.varchar),
    SchemaColumn('rest_annotation_ignore_to', Column.varchar),
    SchemaColumn('rest_annotation_ignore_from', Column.varchar),
    SchemaColumn('rest_annotation_from_generator', Column.varchar),
    SchemaColumn('rest_annotation_to_generator', Column.varchar),
    SchemaColumn('enum_from_string', Column.integer),
    SchemaColumn('sqlite_annotation_nullable', Column.varchar),
    SchemaColumn('sqlite_annotation_default_value', Column.varchar),
    SchemaColumn('sqlite_annotation_from_generator', Column.varchar),
    SchemaColumn('sqlite_annotation_to_generator', Column.varchar),
    SchemaColumn('sqlite_annotation_unique', Column.varchar, unique: true),
    SchemaColumn('custom column name', Column.varchar),
    SchemaColumn('offline_first_where_Mounty_brick_id', Column.integer,
        isForeignKey: true,
        foreignTableName: 'Mounty',
        onDeleteCascade: false,
        onDeleteSetDefault: false)
  }, indices: <SchemaIndex>{}),
  SchemaTable('Mounty', columns: <SchemaColumn>{
    SchemaColumn('_brick_id', Column.integer,
        autoincrement: true, nullable: false, isPrimaryKey: true),
    SchemaColumn('name', Column.varchar),
    SchemaColumn('email', Column.varchar),
    SchemaColumn('hat', Column.varchar)
  }, indices: <SchemaIndex>{}),
  SchemaTable('_brick_Horse_mounties', columns: <SchemaColumn>{
    SchemaColumn('_brick_id', Column.integer,
        autoincrement: true, nullable: false, isPrimaryKey: true),
    SchemaColumn('l_Horse_brick_id', Column.integer,
        isForeignKey: true,
        foreignTableName: 'Horse',
        onDeleteCascade: true,
        onDeleteSetDefault: false),
    SchemaColumn('f_Mounty_brick_id', Column.integer,
        isForeignKey: true,
        foreignTableName: 'Mounty',
        onDeleteCascade: true,
        onDeleteSetDefault: false)
  }, indices: <SchemaIndex>{
    SchemaIndex(columns: ['l_Horse_brick_id', 'f_Mounty_brick_id'], unique: true)
  }),
  SchemaTable('Horse', columns: <SchemaColumn>{
    SchemaColumn('_brick_id', Column.integer,
        autoincrement: true, nullable: false, isPrimaryKey: true),
    SchemaColumn('name', Column.varchar)
  }, indices: <SchemaIndex>{})
});
