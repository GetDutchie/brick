import 'package:brick_sqlite/src/db/migration.dart';
import 'package:brick_sqlite/src/db/migration_commands/drop_column.dart';
import 'package:brick_sqlite/src/db/migration_commands/drop_table.dart';
import 'package:brick_sqlite/src/db/migration_commands/insert_table.dart';
import 'package:brick_sqlite/src/db/migration_commands/rename_column.dart';
import 'package:test/test.dart';

import '__mocks__.dart';

class Migration1a extends Migration {
  const Migration1a()
      : super(
          version: 1,
          up: const [InsertTable('demo1a')],
          down: const [],
        );
}

class Migration20 extends Migration {
  const Migration20()
      : super(
          version: 2,
          up: const [InsertTable('demo')],
          down: const [DropTable('demo')],
        );
}

void main() {
  group('Migration', () {
    group('.generate', () {
      test('one command', () {
        final output = Migration.generate([const InsertTable('demo')], 1);
        expect(output, '''
// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_1_up = [
  InsertTable('demo')
];

const List<MigrationCommand> _migration_1_down = [
  DropTable('demo')
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
''');
      });

      test('multiple commands', () {
        final commands = [
          const InsertTable('demo'),
          const RenameColumn('first_name', 'last_name', onTable: 'people'),
        ];

        final output = Migration.generate(commands, 15);
        expect(output, '''
// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_15_up = [
  InsertTable('demo'),
  RenameColumn('first_name', 'last_name', onTable: 'people')
];

const List<MigrationCommand> _migration_15_down = [
  DropTable('demo'),
  RenameColumn('last_name', 'first_name', onTable: 'people')
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '15',
  up: _migration_15_up,
  down: _migration_15_down,
)
class Migration15 extends Migration {
  const Migration15()
    : super(
        version: 15,
        up: _migration_15_up,
        down: _migration_15_down,
      );
}
''');
      });

      test('null drop commands are not reported', () {
        final commands = [
          const DropColumn('first_name', onTable: 'people'),
          const DropColumn('last_name', onTable: 'people'),
        ];

        final output = Migration.generate(commands, 15);
        expect(
          output,
          contains(RegExp(r'const List<MigrationCommand> _migration_15_down = \[\s+\];')),
        );
      });
    });

    test('#statement', () {
      const m = Migration1();

      expect(m.upStatement, startsWith('CREATE TABLE IF NOT EXISTS `demo` ('));
      expect(m.upStatement, endsWith(');'));
      expect(m.statement, equals(m.upStatement));
    });

    test('#upStatement', () {
      const m = Migration1();

      expect(m.upStatement, startsWith('CREATE TABLE IF NOT EXISTS `demo` ('));
      expect(m.upStatement, endsWith(');'));
    });

    test('#dropStatement', () {
      const m = Migration1();

      expect(m.downStatement, equals('DROP TABLE IF EXISTS `demo`;'));
    });

    group('==', () {
      test('same version, different commands', () {
        const m1 = Migration1();
        const m1a = Migration1a();

        expect(m1, equals(m1a));
      });

      test('different version, same commands', () {
        const m1 = Migration1();
        const m2 = Migration20();

        expect(m1, isNot(m2));
      });
    });
  });
}
