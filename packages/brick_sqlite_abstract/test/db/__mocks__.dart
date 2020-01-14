import '../../lib/db.dart';
export 'package:test/test.dart';
export '../../lib/db.dart';

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
            down: const [DropTable('nonexistent_table')]);
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
