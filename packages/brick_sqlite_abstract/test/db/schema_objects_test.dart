import 'package:test/test.dart';
import '../../lib/db.dart';

void main() {
  group('SchemaTable', () {
    test('#forGenerator', () {
      final table = SchemaTable(
        'users',
        columns: <SchemaColumn>{
          SchemaColumn('first_name', String),
          SchemaColumn('_brick_id', int, autoincrement: true, isPrimaryKey: true),
          SchemaColumn('amount', int, defaultValue: 0),
          SchemaColumn('last_name', String, nullable: false),
        },
      );

      expect(table.forGenerator, '''SchemaTable(
\t'users',
\tcolumns: <SchemaColumn>{
\t\tSchemaColumn('first_name', String),
\t\tSchemaColumn('_brick_id', int, autoincrement: true, isPrimaryKey: true),
\t\tSchemaColumn('amount', int, defaultValue: 0),
\t\tSchemaColumn('last_name', String, nullable: false)
\t},
\tindices: <SchemaIndex>{
\t\t  
\t}
)''');
    });

    group('#toCommand', () {
      final table = SchemaTable('users', columns: <SchemaColumn>{});

      test('shouldDrop:false', () {
        expect(table.toCommand(shouldDrop: false), const InsertTable('users'));
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
            SchemaColumn('first_name', String),
          },
        );
        final table2 = SchemaTable(
          'users',
          columns: <SchemaColumn>{
            SchemaColumn('last_name', String),
          },
        );

        expect(table1, equals(table2));
      });

      test('different name, same columns', () {
        final table1 = SchemaTable(
          'users',
          columns: <SchemaColumn>{
            SchemaColumn('first_name', String),
          },
        );
        final table2 = SchemaTable(
          'people',
          columns: <SchemaColumn>{
            SchemaColumn('first_name', String),
          },
        );

        expect(table1, isNot(table2));
      });
    });
  });

  group('SchemaColumn', () {
    test('isPrimaryKey must be int', () {
      expect(
        () => SchemaColumn(InsertTable.PRIMARY_KEY_COLUMN, String, isPrimaryKey: true),
        throwsA(TypeMatcher<AssertionError>()),
      );
    });

    test('defaults', () {
      final column = SchemaColumn(InsertTable.PRIMARY_KEY_COLUMN, String);

      // These expectations can never be removed, otherwise old schemas would be invalid
      expect(column.autoincrement, isFalse);
      expect(column.nullable, isTrue);
      expect(column.isPrimaryKey, isFalse);
      expect(column.isForeignKey, isFalse);
      expect(column.onDeleteCascade, isFalse);
      expect(column.onDeleteSetDefault, isFalse);
    });

    test('#forGenerator', () {
      var column = SchemaColumn('first_name', String);
      expect(column.forGenerator, "SchemaColumn('first_name', String)");

      column = SchemaColumn('_brick_id', int, autoincrement: true, isPrimaryKey: true);
      expect(
        column.forGenerator,
        "SchemaColumn('_brick_id', int, autoincrement: true, isPrimaryKey: true)",
      );

      column = SchemaColumn('amount', int, defaultValue: 0);
      expect(column.forGenerator, "SchemaColumn('amount', int, defaultValue: 0)");

      column = SchemaColumn('last_name', String, nullable: false);
      expect(column.forGenerator, "SchemaColumn('last_name', String, nullable: false)");

      column = SchemaColumn('hat_id', int, isForeignKey: true, foreignTableName: 'hat');
      expect(
        column.forGenerator,
        "SchemaColumn('hat_id', int, isForeignKey: true, foreignTableName: 'hat', onDeleteCascade: false, onDeleteSetDefault: false)",
      );

      column = SchemaColumn('hat_id', int,
          isForeignKey: true, foreignTableName: 'hat', onDeleteCascade: true);
      expect(
        column.forGenerator,
        "SchemaColumn('hat_id', int, isForeignKey: true, foreignTableName: 'hat', onDeleteCascade: true, onDeleteSetDefault: false)",
      );
    });

    test('#toCommand', () {
      var column = SchemaColumn('first_name', String);
      column.tableName = 'demo';
      expect(column.toCommand(), const InsertColumn('first_name', Column.varchar, onTable: 'demo'));

      column = SchemaColumn('_brick_id', int, autoincrement: true, isPrimaryKey: true);
      column.tableName = 'demo';
      expect(
        column.toCommand(),
        const InsertColumn('_brick_id', Column.integer, onTable: 'demo', autoincrement: true),
      );

      column = SchemaColumn('amount', int, defaultValue: 0);
      column.tableName = 'demo';
      expect(
        column.toCommand(),
        const InsertColumn('amount', Column.integer, onTable: 'demo', defaultValue: 0),
      );

      column = SchemaColumn('last_name', String, nullable: false);
      column.tableName = 'demo';
      expect(
        column.toCommand(),
        const InsertColumn('last_name', Column.varchar, onTable: 'demo', nullable: false),
      );

      column = SchemaColumn('Hat_id', int, isForeignKey: true, foreignTableName: 'hat');
      column.tableName = 'demo';
      expect(column.toCommand(), const InsertForeignKey('demo', 'hat', foreignKeyColumn: 'Hat_id'));

      column = SchemaColumn('Hat_id', int,
          isForeignKey: true, foreignTableName: 'hat', onDeleteCascade: true);
      column.tableName = 'demo';
      expect(column.toCommand(),
          const InsertForeignKey('demo', 'hat', foreignKeyColumn: 'Hat_id', onDeleteCascade: true));

      column = SchemaColumn('Hat_id', int,
          isForeignKey: true, foreignTableName: 'hat', onDeleteSetDefault: true);
      column.tableName = 'demo';
      expect(
          column.toCommand(),
          const InsertForeignKey('demo', 'hat',
              foreignKeyColumn: 'Hat_id', onDeleteSetDefault: true));
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
