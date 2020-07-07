import 'package:brick_sqlite_abstract/db.dart';

const version = 1;

const up = [
  const InsertTable('User'),
  const InsertColumn('name', Column.varchar, onTable: 'User'),
];

const down = <MigrationCommand>[];

@Migratable(version: '$version', up: up, down: down)
class Migration1 extends Migration {
  const Migration1() : super(version: version, up: up, down: down);
}

final schema = Schema(2, generatorVersion: 1, tables: <SchemaTable>{
  SchemaTable('User', columns: <SchemaColumn>{
    SchemaColumn('_brick_id', int, autoincrement: true, nullable: false, isPrimaryKey: true),
    SchemaColumn('name', String),
  })
});
