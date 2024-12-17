import 'package:brick_sqlite/src/db/column.dart';
import 'package:brick_sqlite/src/db/migration_commands/drop_table.dart';
import 'package:brick_sqlite/src/db/migration_commands/insert_column.dart';
import 'package:brick_sqlite/src/db/migration_commands/insert_foreign_key.dart';
import 'package:brick_sqlite/src/db/migration_commands/insert_table.dart';
import 'package:brick_sqlite/src/db/schema/schema_column.dart';
import 'package:brick_sqlite/src/db/schema/schema_table.dart';
import 'package:test/test.dart';

void main() {
  group('SchemaTable', () {
    test('#forGenerator', () {
      final table = SchemaTable(
        'users',
        columns: <SchemaColumn>{
          SchemaColumn('first_name', Column.varchar),
          SchemaColumn('_brick_id', Column.integer, autoincrement: true, isPrimaryKey: true),
          SchemaColumn('amount', Column.integer, defaultValue: 0),
          SchemaColumn('last_name', Column.varchar, nullable: false),
        },
      );

      expect(table.forGenerator, '''SchemaTable(
\t'users',
\tcolumns: <SchemaColumn>{
\t\tSchemaColumn('first_name', Column.varchar),
\t\tSchemaColumn('_brick_id', Column.integer, autoincrement: true, isPrimaryKey: true),
\t\tSchemaColumn('amount', Column.integer, defaultValue: 0),
\t\tSchemaColumn('last_name', Column.varchar, nullable: false)
\t},
\tindices: <SchemaIndex>{

\t}
)''');
    });

    group('#toCommand', () {
      final table = SchemaTable('users', columns: <SchemaColumn>{});

      test('shouldDrop:false', () {
        expect(table.toCommand(), const InsertTable('users'));
      });

      test('shouldDrop:true', () {
        expect(table.toCommand(shouldDrop: true), const DropTable('users'));
      });
    });

    group('==', () {
      test('same name, different columns', () {
        final table1 = SchemaTable(
          'users',
          columns: <SchemaColumn>{
            SchemaColumn('first_name', Column.varchar),
          },
        );
        final table2 = SchemaTable(
          'users',
          columns: <SchemaColumn>{
            SchemaColumn('last_name', Column.varchar),
          },
        );

        expect(table1, equals(table2));
      });

      test('different name, same columns', () {
        final table1 = SchemaTable(
          'users',
          columns: <SchemaColumn>{
            SchemaColumn('first_name', Column.varchar),
          },
        );
        final table2 = SchemaTable(
          'people',
          columns: <SchemaColumn>{
            SchemaColumn('first_name', Column.varchar),
          },
        );

        expect(table1, isNot(table2));
      });
    });
  });

  group('SchemaColumn', () {
    test('isPrimaryKey must be int', () {
      expect(
        () => SchemaColumn(InsertTable.PRIMARY_KEY_COLUMN, Column.varchar, isPrimaryKey: true),
        throwsA(const TypeMatcher<AssertionError>()),
      );
    });

    test('defaults', () {
      final column = SchemaColumn(InsertTable.PRIMARY_KEY_COLUMN, Column.varchar);

      // These expectations can never be removed, otherwise old schemas would be invalid
      expect(column.autoincrement, isFalse);
      expect(column.nullable, isTrue);
      expect(column.isPrimaryKey, isFalse);
      expect(column.isForeignKey, isFalse);
      expect(column.onDeleteCascade, isFalse);
      expect(column.onDeleteSetDefault, isFalse);
    });

    test('#forGenerator', () {
      var column = SchemaColumn('first_name', Column.varchar);
      expect(column.forGenerator, "SchemaColumn('first_name', Column.varchar)");

      column = SchemaColumn('_brick_id', Column.integer, autoincrement: true, isPrimaryKey: true);
      expect(
        column.forGenerator,
        "SchemaColumn('_brick_id', Column.integer, autoincrement: true, isPrimaryKey: true)",
      );

      column = SchemaColumn('amount', Column.integer, defaultValue: 0);
      expect(column.forGenerator, "SchemaColumn('amount', Column.integer, defaultValue: 0)");

      column = SchemaColumn('last_name', Column.varchar, nullable: false);
      expect(column.forGenerator, "SchemaColumn('last_name', Column.varchar, nullable: false)");

      column = SchemaColumn('hat_id', Column.integer, isForeignKey: true, foreignTableName: 'hat');
      expect(
        column.forGenerator,
        "SchemaColumn('hat_id', Column.integer, isForeignKey: true, foreignTableName: 'hat', onDeleteCascade: false, onDeleteSetDefault: false)",
      );

      column = SchemaColumn(
        'hat_id',
        Column.integer,
        isForeignKey: true,
        foreignTableName: 'hat',
        onDeleteCascade: true,
      );
      expect(
        column.forGenerator,
        "SchemaColumn('hat_id', Column.integer, isForeignKey: true, foreignTableName: 'hat', onDeleteCascade: true, onDeleteSetDefault: false)",
      );
    });

    test('#toCommand', () {
      var column = SchemaColumn('first_name', Column.varchar)..tableName = 'demo';
      expect(column.toCommand(), const InsertColumn('first_name', Column.varchar, onTable: 'demo'));

      column = SchemaColumn('_brick_id', Column.integer, autoincrement: true, isPrimaryKey: true)
        ..tableName = 'demo';
      expect(
        column.toCommand(),
        const InsertColumn('_brick_id', Column.integer, onTable: 'demo', autoincrement: true),
      );

      column = SchemaColumn('amount', Column.integer, defaultValue: 0)..tableName = 'demo';
      expect(
        column.toCommand(),
        const InsertColumn('amount', Column.integer, onTable: 'demo', defaultValue: 0),
      );

      column = SchemaColumn('last_name', Column.varchar, nullable: false)..tableName = 'demo';
      expect(
        column.toCommand(),
        const InsertColumn('last_name', Column.varchar, onTable: 'demo', nullable: false),
      );

      column = SchemaColumn('Hat_id', Column.integer, isForeignKey: true, foreignTableName: 'hat')
        ..tableName = 'demo';
      expect(column.toCommand(), const InsertForeignKey('demo', 'hat', foreignKeyColumn: 'Hat_id'));

      column = SchemaColumn(
        'Hat_id',
        Column.integer,
        isForeignKey: true,
        foreignTableName: 'hat',
        onDeleteCascade: true,
      )..tableName = 'demo';
      expect(
        column.toCommand(),
        const InsertForeignKey('demo', 'hat', foreignKeyColumn: 'Hat_id', onDeleteCascade: true),
      );

      column = SchemaColumn(
        'Hat_id',
        Column.integer,
        isForeignKey: true,
        foreignTableName: 'hat',
        onDeleteSetDefault: true,
      )..tableName = 'demo';
      expect(
        column.toCommand(),
        const InsertForeignKey(
          'demo',
          'hat',
          foreignKeyColumn: 'Hat_id',
          onDeleteSetDefault: true,
        ),
      );
    });

    test('==', () {
      const column1 = InsertColumn('1', Column.varchar, onTable: 'table1');
      const column1b = InsertColumn('1', Column.varchar, onTable: 'table1');
      const column2 = InsertColumn('1', Column.varchar, onTable: 'table2');

      expect(column1, isNot(column2));
      expect(column1, column1b);
    });
  });
}
