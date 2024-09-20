// GENERATED CODE DO NOT EDIT
// This file should be version controlled
import 'package:brick_sqlite/db.dart';
part '20240906052847.migration.dart';

/// All intelligently-generated migrations from all `@Migratable` classes on disk
final migrations = <Migration>{const Migration20240920034504()};

/// A consumable database structure including the latest generated migration.
final schema = Schema(20240906052847, generatorVersion: 1, tables: <SchemaTable>{
  SchemaTable('_brick_Customer_pizzas', columns: <SchemaColumn>{
    SchemaColumn('_brick_id', Column.integer,
        autoincrement: true, nullable: false, isPrimaryKey: true),
    SchemaColumn('l_Customer_brick_id', Column.integer,
        isForeignKey: true,
        foreignTableName: 'Customer',
        onDeleteCascade: true,
        onDeleteSetDefault: false),
    SchemaColumn('f_Pizza_brick_id', Column.integer,
        isForeignKey: true,
        foreignTableName: 'Pizza',
        onDeleteCascade: true,
        onDeleteSetDefault: false)
  }, indices: <SchemaIndex>{
    SchemaIndex(columns: ['l_Customer_brick_id', 'f_Pizza_brick_id'], unique: true)
  }),
  SchemaTable('Customer', columns: <SchemaColumn>{
    SchemaColumn('_brick_id', Column.integer,
        autoincrement: true, nullable: false, isPrimaryKey: true),
    SchemaColumn('id', Column.varchar, unique: true),
    SchemaColumn('first_name', Column.varchar),
    SchemaColumn('last_name', Column.varchar)
  }, indices: <SchemaIndex>{}),
  SchemaTable('Pizza', columns: <SchemaColumn>{
    SchemaColumn('_brick_id', Column.integer,
        autoincrement: true, nullable: false, isPrimaryKey: true),
    SchemaColumn('id', Column.varchar, unique: true),
    SchemaColumn('frozen', Column.boolean)
  }, indices: <SchemaIndex>{})
});
