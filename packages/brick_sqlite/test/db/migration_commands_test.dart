import 'package:brick_sqlite/src/db/column.dart';
import 'package:brick_sqlite/src/db/migration_commands/create_index.dart';
import 'package:brick_sqlite/src/db/migration_commands/drop_column.dart';
import 'package:brick_sqlite/src/db/migration_commands/drop_index.dart';
import 'package:brick_sqlite/src/db/migration_commands/drop_table.dart';
import 'package:brick_sqlite/src/db/migration_commands/insert_column.dart';
import 'package:brick_sqlite/src/db/migration_commands/insert_foreign_key.dart';
import 'package:brick_sqlite/src/db/migration_commands/insert_table.dart';
import 'package:brick_sqlite/src/db/migration_commands/rename_column.dart';
import 'package:brick_sqlite/src/db/migration_commands/rename_table.dart';
import 'package:test/test.dart';

void main() {
  group('MigrationCommand', () {
    group('CreateIndex', () {
      const m = CreateIndex(
        columns: ['f_Local_brick_id', 'l_Field_brick_id'],
        onTable: '_brick_Local_field',
      );
      const mUnique = CreateIndex(
        columns: ['f_Local_brick_id', 'l_Field_brick_id'],
        onTable: '_brick_Local_field',
        unique: true,
      );

      test('defaults', () {
        expect(m.unique, isFalse);
      });

      test('#statement', () {
        expect(
          m.statement,
          'CREATE INDEX IF NOT EXISTS index__brick_Local_field_on_f_Local_brick_id_l_Field_brick_id on `_brick_Local_field`(`f_Local_brick_id`, `l_Field_brick_id`)',
        );
        expect(
          mUnique.statement,
          'CREATE UNIQUE INDEX IF NOT EXISTS index__brick_Local_field_on_f_Local_brick_id_l_Field_brick_id on `_brick_Local_field`(`f_Local_brick_id`, `l_Field_brick_id`)',
        );
      });

      test('#forGenerator', () {
        expect(
          m.forGenerator,
          "CreateIndex(columns: ['f_Local_brick_id', 'l_Field_brick_id'], onTable: '_brick_Local_field', unique: false)",
        );
        expect(
          mUnique.forGenerator,
          "CreateIndex(columns: ['f_Local_brick_id', 'l_Field_brick_id'], onTable: '_brick_Local_field', unique: true)",
        );
      });

      test('.generateName', () {
        expect(
          CreateIndex.generateName(['user_id', 'friend_id', 'account_id'], 'Person'),
          'index_Person_on_user_id_friend_id_account_id',
        );
      });
    });

    group('DropColumn', () {
      const m = DropColumn('name', onTable: 'demo');

      test('#statement', () {
        expect(m.statement, null);
      });

      test('#forGenerator', () {
        expect(m.forGenerator, "DropColumn('name', onTable: 'demo')");
      });
    });

    group('DropIndex', () {
      const m = DropIndex('name');

      test('#statement', () {
        expect(m.statement, 'DROP INDEX IF EXISTS name');
      });

      test('#forGenerator', () {
        expect(m.forGenerator, "DropIndex('name')");
      });
    });

    group('DropTable', () {
      const m = DropTable('demo');

      test('#statement', () {
        expect(m.statement, 'DROP TABLE IF EXISTS `demo`');
      });

      test('#forGenerator', () {
        expect(m.forGenerator, "DropTable('demo')");
      });
    });

    group('InsertColumn', () {
      test('defaults', () {
        const m = InsertColumn('name', Column.varchar, onTable: 'demo');

        // These expectations can never be removed, otherwise all migrations must be regenerated
        // And some migrations are modified by hand, making regeneration not possible
        expect(m.autoincrement, isFalse);
        expect(m.nullable, isTrue);
        expect(m.unique, isFalse);
      });

      group('#statement', () {
        test('basic', () {
          const m = InsertColumn('name', Column.varchar, onTable: 'demo');
          expect(m.statement, 'ALTER TABLE `demo` ADD `name` VARCHAR NULL');
        });

        test('autoincrement:true', () {
          const m = InsertColumn('name', Column.integer, onTable: 'demo', autoincrement: true);
          expect(m.statement, 'ALTER TABLE `demo` ADD `name` INTEGER AUTOINCREMENT NULL');
        });

        test('defaultValue:', () {
          const m = InsertColumn('name', Column.integer, onTable: 'demo', defaultValue: 0);
          expect(m.statement, 'ALTER TABLE `demo` ADD `name` INTEGER NULL DEFAULT 0');
        });

        test('nullable:', () {
          const m = InsertColumn('name', Column.integer, onTable: 'demo', nullable: false);
          expect(m.statement, 'ALTER TABLE `demo` ADD `name` INTEGER NOT NULL');
        });

        test('unique:', () {
          const m = InsertColumn('name', Column.integer, onTable: 'demo', unique: true);
          expect(m.statement, 'ALTER TABLE `demo` ADD `name` INTEGER NULL');
        });
      });

      group('#forGenerator', () {
        test('basic', () {
          const m = InsertColumn('name', Column.varchar, onTable: 'demo');
          expect(m.forGenerator, "InsertColumn('name', Column.varchar, onTable: 'demo')");
        });

        test('autoincrement:true', () {
          const m = InsertColumn('name', Column.integer, onTable: 'demo', autoincrement: true);
          expect(
            m.forGenerator,
            "InsertColumn('name', Column.integer, onTable: 'demo', autoincrement: true)",
          );
        });

        test('defaultValue:', () {
          const m = InsertColumn('name', Column.integer, onTable: 'demo', defaultValue: 0);
          expect(
            m.forGenerator,
            "InsertColumn('name', Column.integer, onTable: 'demo', defaultValue: 0)",
          );
        });

        test('nullable:', () {
          const m = InsertColumn('name', Column.integer, onTable: 'demo', nullable: false);
          expect(
            m.forGenerator,
            "InsertColumn('name', Column.integer, onTable: 'demo', nullable: false)",
          );
        });
      });
    });

    group('InsertForeignKey', () {
      const m = InsertForeignKey('demo', 'demo2');

      test('defaults', () {
        // These expectations can never be removed, otherwise all migrations must be regenerated
        // And some migrations are modified by hand, making regeneration not possible
        expect(m.onDeleteCascade, isFalse);
        expect(m.onDeleteSetDefault, isFalse);
      });

      test('#statement', () {
        expect(
          m.statement,
          'ALTER TABLE `demo` ADD COLUMN `demo2_brick_id` INTEGER REFERENCES `demo2`(`_brick_id`)',
        );

        const withOnDeleteCascade = InsertForeignKey('demo', 'demo2', onDeleteCascade: true);
        expect(
          withOnDeleteCascade.statement,
          'ALTER TABLE `demo` ADD COLUMN `demo2_brick_id` INTEGER REFERENCES `demo2`(`_brick_id`) ON DELETE CASCADE',
        );

        const withOnDeleteSetDefault = InsertForeignKey('demo', 'demo2', onDeleteSetDefault: true);
        expect(
          withOnDeleteSetDefault.statement,
          'ALTER TABLE `demo` ADD COLUMN `demo2_brick_id` INTEGER REFERENCES `demo2`(`_brick_id`) ON DELETE SET DEFAULT',
        );
      });

      test('#forGenerator', () {
        expect(
          m.forGenerator,
          "InsertForeignKey('demo', 'demo2', foreignKeyColumn: 'demo2_brick_id', onDeleteCascade: false, onDeleteSetDefault: false)",
        );
        const withOnDeleteCascade = InsertForeignKey('demo', 'demo2', onDeleteCascade: true);
        expect(
          withOnDeleteCascade.forGenerator,
          "InsertForeignKey('demo', 'demo2', foreignKeyColumn: 'demo2_brick_id', onDeleteCascade: true, onDeleteSetDefault: false)",
        );

        const withOnDeleteSetDefault = InsertForeignKey('demo', 'demo2', onDeleteSetDefault: true);
        expect(
          withOnDeleteSetDefault.forGenerator,
          "InsertForeignKey('demo', 'demo2', foreignKeyColumn: 'demo2_brick_id', onDeleteCascade: false, onDeleteSetDefault: true)",
        );
      });

      test('.foreignKeyColumnName', () {
        final columnName = InsertForeignKey.foreignKeyColumnName('BigHat');
        expect(columnName, 'BigHat_brick_id');

        final prefixedName = InsertForeignKey.foreignKeyColumnName('BigHat', 'casual');
        expect(prefixedName, 'casual_BigHat_brick_id');
      });

      test('.joinsTableLocalColumnName', () {
        final columnName = InsertForeignKey.joinsTableLocalColumnName('BigHat');
        expect(columnName, 'l_BigHat_brick_id');
      });

      test('.joinsTableForeignColumnName', () {
        final columnName = InsertForeignKey.joinsTableForeignColumnName('BigHat');
        expect(columnName, 'f_BigHat_brick_id');
      });

      test('.joinsTableName', () {
        var tableName = InsertForeignKey.joinsTableName('sunday_hat', localTableName: 'User');
        expect(tableName, '_brick_User_sunday_hat');

        tableName = InsertForeignKey.joinsTableName('address', localTableName: 'People');
        expect(tableName, '_brick_People_address');
      });
    });

    group('InsertTable', () {
      const m = InsertTable('demo');

      test('#statement', () {
        expect(
          m.statement,
          'CREATE TABLE IF NOT EXISTS `demo` (`_brick_id` INTEGER PRIMARY KEY AUTOINCREMENT)',
        );
      });

      test('#forGenerator', () {
        expect(m.forGenerator, "InsertTable('demo')");
      });

      test('.PRIMARY_KEY_COLUMN', () {
        expect(InsertTable.PRIMARY_KEY_COLUMN, '_brick_id');
      });
    });

    group('RenameColumn', () {
      const m = RenameColumn('name', 'first_name', onTable: 'demo');
      test('#statement', () {
        expect(m.statement, null);
      });

      test('#forGenerator', () {
        expect(m.forGenerator, "RenameColumn('name', 'first_name', onTable: 'demo')");
      });
    });

    group('RenameTable', () {
      const m = RenameTable('demo', 'demo2');

      test('#statement', () {
        expect(m.statement, 'ALTER TABLE `demo` RENAME TO `demo2`');
      });

      test('#forGenerator', () {
        expect(m.forGenerator, "RenameTable('demo', 'demo2')");
      });
    });
  });
}
