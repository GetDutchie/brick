import 'package:brick_sqlite_abstract/db.dart';

const version = 1;

const up = [
  InsertTable('demo'),
  InsertColumn('name', Column.varchar, onTable: 'demo'),
];

const down = <MigrationCommand>[];

@Migratable(version: '$version', up: up, down: down)
class Migration1 extends Migration {
  const Migration1() : super(version: version, up: up, down: down);
}
