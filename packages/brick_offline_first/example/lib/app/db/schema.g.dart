// GENERATED CODE DO NOT EDIT
// This file should be version controlled
import 'package:brick_sqlite_abstract/db.dart';
// ignore: unused_import
import 'package:brick_sqlite_abstract/db.dart' show Migratable;
part '20200616220821.migration.dart';
part '20200106215014.migration.dart';
part '20200124174431.migration.dart';
part '20200616215211.migration.dart';

/// All intelligently-generated migrations from all `@Migratable` classes on disk
final Set<Migration> migrations = Set.from([
  Migration20200616220821(),
  Migration20200106215014(),
  Migration20200124174431(),
  Migration20200616215211()
]);

/// A consumable database structure including the latest generated migration.
final schema = Schema(20200616220821,
    generatorVersion: 1,
    tables: Set<SchemaTable>.from([
      SchemaTable('_brick_Horse_mounties',
          columns: Set.from([
            SchemaColumn('_brick_id', int,
                autoincrement: true, nullable: false, isPrimaryKey: true),
            SchemaColumn('Horse_brick_id', int,
                isForeignKey: true,
                foreignTableName: 'Horse',
                onDeleteCascade: true),
            SchemaColumn('Mounty_brick_id', int,
                isForeignKey: true,
                foreignTableName: 'Mounty',
                onDeleteCascade: true)
          ])),
      SchemaTable('Horse',
          columns: Set.from([
            SchemaColumn('_brick_id', int,
                autoincrement: true, nullable: false, isPrimaryKey: true),
            SchemaColumn('name', String)
          ])),
      SchemaTable('_brick_KitchenSink_list_offline_first_model',
          columns: Set.from([
            SchemaColumn('_brick_id', int,
                autoincrement: true, nullable: false, isPrimaryKey: true),
            SchemaColumn('KitchenSink_brick_id', int,
                isForeignKey: true,
                foreignTableName: 'KitchenSink',
                onDeleteCascade: true),
            SchemaColumn('Mounty_brick_id', int,
                isForeignKey: true,
                foreignTableName: 'Mounty',
                onDeleteCascade: true)
          ])),
      SchemaTable('_brick_KitchenSink_set_offline_first_model',
          columns: Set.from([
            SchemaColumn('_brick_id', int,
                autoincrement: true, nullable: false, isPrimaryKey: true),
            SchemaColumn('KitchenSink_brick_id', int,
                isForeignKey: true,
                foreignTableName: 'KitchenSink',
                onDeleteCascade: true),
            SchemaColumn('Mounty_brick_id', int,
                isForeignKey: true,
                foreignTableName: 'Mounty',
                onDeleteCascade: true)
          ])),
      SchemaTable('_brick_KitchenSink_future_list_offline_first_model',
          columns: Set.from([
            SchemaColumn('_brick_id', int,
                autoincrement: true, nullable: false, isPrimaryKey: true),
            SchemaColumn('KitchenSink_brick_id', int,
                isForeignKey: true,
                foreignTableName: 'KitchenSink',
                onDeleteCascade: true),
            SchemaColumn('Mounty_brick_id', int,
                isForeignKey: true,
                foreignTableName: 'Mounty',
                onDeleteCascade: true)
          ])),
      SchemaTable('_brick_KitchenSink_future_set_offline_first_model',
          columns: Set.from([
            SchemaColumn('_brick_id', int,
                autoincrement: true, nullable: false, isPrimaryKey: true),
            SchemaColumn('KitchenSink_brick_id', int,
                isForeignKey: true,
                foreignTableName: 'KitchenSink',
                onDeleteCascade: true),
            SchemaColumn('Mounty_brick_id', int,
                isForeignKey: true,
                foreignTableName: 'Mounty',
                onDeleteCascade: true)
          ])),
      SchemaTable('KitchenSink',
          columns: Set.from([
            SchemaColumn('_brick_id', int,
                autoincrement: true, nullable: false, isPrimaryKey: true),
            SchemaColumn('any_string', String),
            SchemaColumn('any_int', int),
            SchemaColumn('any_double', double),
            SchemaColumn('any_num', num),
            SchemaColumn('any_date_time', DateTime),
            SchemaColumn('any_bool', bool),
            SchemaColumn('any_map', String),
            SchemaColumn('enum_from_index', int),
            SchemaColumn('any_list', String),
            SchemaColumn('any_set', String),
            SchemaColumn('offline_first_model_Mounty_brick_id', int,
                isForeignKey: true,
                foreignTableName: 'Mounty',
                onDeleteCascade: false),
            SchemaColumn('future_offline_first_model_Mounty_brick_id', int,
                isForeignKey: true,
                foreignTableName: 'Mounty',
                onDeleteCascade: false),
            SchemaColumn('offline_first_serdes', String),
            SchemaColumn('list_offline_first_serdes', String),
            SchemaColumn('set_offline_first_serdes', String),
            SchemaColumn('rest_annotation_name', String),
            SchemaColumn('rest_annotation_default_value', String),
            SchemaColumn('rest_annotation_nullable', String),
            SchemaColumn('rest_annotation_ignore', String),
            SchemaColumn('rest_annotation_ignore_to', String),
            SchemaColumn('rest_annotation_ignore_from', String),
            SchemaColumn('rest_annotation_from_generator', String),
            SchemaColumn('rest_annotation_to_generator', String),
            SchemaColumn('enum_from_string', int),
            SchemaColumn('sqlite_annotation_nullable', String),
            SchemaColumn('sqlite_annotation_default_value', String),
            SchemaColumn('sqlite_annotation_from_generator', String),
            SchemaColumn('sqlite_annotation_to_generator', String),
            SchemaColumn('sqlite_annotation_unique', String, unique: true),
            SchemaColumn('custom column name', String),
            SchemaColumn('offline_first_where_Mounty_brick_id', int,
                isForeignKey: true,
                foreignTableName: 'Mounty',
                onDeleteCascade: false)
          ])),
      SchemaTable('Mounty',
          columns: Set.from([
            SchemaColumn('_brick_id', int,
                autoincrement: true, nullable: false, isPrimaryKey: true),
            SchemaColumn('name', String),
            SchemaColumn('email', String),
            SchemaColumn('hat', String)
          ]))
    ]));
