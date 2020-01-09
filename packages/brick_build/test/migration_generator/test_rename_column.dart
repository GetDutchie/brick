import 'package:brick_sqlite_abstract/db.dart';

const version = 1;

const up = [
  const InsertTable("demo"),
  const InsertColumn("name", Column.varchar, onTable: "demo"),
  const RenameColumn("name", "new_name", onTable: "demo"),
];

const down = [];

@Migratable(version: "$version", up: up, down: down)
class Migration1 extends Migration {
  const Migration1() : super(version: version, up: up, down: down);
}
