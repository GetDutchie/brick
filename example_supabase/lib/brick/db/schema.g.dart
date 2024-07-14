// GENERATED CODE DO NOT EDIT
// This file should be version controlled
import 'package:brick_sqlite/db.dart';
part '20240714103011.migration.dart';

/// All intelligently-generated migrations from all `@Migratable` classes on disk
final migrations = <Migration>{
  const Migration20240714103011(),};

/// A consumable database structure including the latest generated migration.
final schema = Schema(20240714103011, generatorVersion: 1, tables: <SchemaTable>{
  SchemaTable('Customer', columns: <SchemaColumn>{
    SchemaColumn('_brick_id', Column.integer,
        autoincrement: true, nullable: false, isPrimaryKey: true),
    SchemaColumn('id', Column.varchar, unique: true),
    SchemaColumn('first_name', Column.varchar),
    SchemaColumn('last_name', Column.varchar),
    SchemaColumn('created_at', Column.datetime)
  }, indices: <SchemaIndex>{})
});
