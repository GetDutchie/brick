import 'package:brick_sqlite/src/db/column.dart';
import 'package:brick_sqlite/src/db/migration.dart';
import 'package:brick_sqlite/src/db/migration_commands/create_index.dart';
import 'package:brick_sqlite/src/db/migration_commands/drop_index.dart';
import 'package:brick_sqlite/src/db/migration_commands/drop_table.dart';
import 'package:brick_sqlite/src/db/migration_commands/insert_column.dart';
import 'package:brick_sqlite/src/db/migration_commands/insert_foreign_key.dart';
import 'package:brick_sqlite/src/db/migration_commands/insert_table.dart';
import 'package:brick_sqlite/src/db/migration_commands/rename_column.dart';
import 'package:brick_sqlite/src/db/migration_commands/rename_table.dart';

class Migration1 extends Migration {
  const Migration1()
      : super(
          version: 1,
          up: const [InsertTable('demo')],
          down: const [DropTable('demo')],
        );
}

class Migration2 extends Migration {
  const Migration2()
      : super(
          version: 2,
          up: const [InsertTable('demo2')],
          down: const [DropTable('demo2')],
        );
}

class Migration0None extends Migration {
  const Migration0None()
      : super(
          version: 0,
          up: const [InsertTable('nonexistent_table')],
          down: const [DropTable('nonexistent_table')],
        );
}

class MigrationInsertTable extends Migration {
  const MigrationInsertTable()
      : super(
          version: 1,
          up: const [InsertTable('demo')],
          down: const [DropTable('demo')],
        );
}

class MigrationRenameTable extends Migration {
  const MigrationRenameTable()
      : super(
          version: 2,
          up: const [RenameTable('demo', 'demo1')],
          down: const [RenameTable('demo1', 'demo')],
        );
}

class MigrationDropTable extends Migration {
  const MigrationDropTable()
      : super(
          version: 3,
          up: const [DropTable('demo')],
          down: const [InsertTable('demo')],
        );
}

class MigrationInsertColumn extends Migration {
  const MigrationInsertColumn()
      : super(
          version: 4,
          up: const [InsertColumn('name', Column.varchar, onTable: 'demo')],
          down: const [],
        );
}

class MigrationRenameColumn extends Migration {
  const MigrationRenameColumn()
      : super(
          version: 5,
          up: const [RenameColumn('name', 'first_name', onTable: 'demo')],
          down: const [RenameColumn('first_name', 'name', onTable: 'demo')],
        );
}

class MigrationInsertForeignKey extends Migration {
  const MigrationInsertForeignKey()
      : super(
          version: 6,
          up: const [InsertForeignKey('demo', 'demo2')],
          down: const [],
        );
}

class MigrationCreateIndex extends Migration {
  const MigrationCreateIndex()
      : super(
          version: 7,
          up: const [
            CreateIndex(columns: ['_brick_id'], onTable: 'demo', unique: true),
          ],
          down: const [DropIndex('index_demo_on__brick_id')],
        );
}

class MigrationDropIndex extends Migration {
  const MigrationDropIndex()
      : super(
          version: 8,
          up: const [DropIndex('index_demo_on__brick_id')],
          down: const [],
        );
}
