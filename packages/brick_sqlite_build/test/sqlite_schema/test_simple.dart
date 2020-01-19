import 'package:brick_offline_first_abstract/annotations.dart';

final migrationOutput = r'''
// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_1_up = [
  InsertTable("Simple"),
  InsertColumn("name", Column.varchar, onTable: "Simple")
];

const List<MigrationCommand> _migration_1_down = [
  DropTable("Simple"),
  DropColumn("name", onTable: "Simple")
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '1',
  up: _migration_1_up,
  down: _migration_1_down,
)
class Migration1 extends Migration {
  const Migration1()
    : super(
        version: 1,
        up: _migration_1_up,
        down: _migration_1_down,
      );
}
''';

final output = r'''
// GENERATED CODE DO NOT EDIT
// This file should be version controlled
import 'package:brick_sqlite_abstract/db.dart';
// ignore: unused_import
import 'package:brick_sqlite_abstract/db.dart' show Migratable;

/// All intelligently-generated migrations from all `@Migratable` classes on disk
final Set<Migration> migrations = Set.from([]);

/// A consumable database structure including the latest generated migration.
final schema = Schema(0,
    generatorVersion: 1,
    tables: Set<SchemaTable>.from([
      SchemaTable("Simple",
          columns: Set.from([
            SchemaColumn("_brick_id", int,
                autoincrement: true, nullable: false, isPrimaryKey: true),
            SchemaColumn("name", String)
          ]))
    ]));
''';

@ConnectOfflineFirstWithRest()
class Simple {
  final String name;

  Simple({this.name});
}
