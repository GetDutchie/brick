import 'package:test/test.dart';
import 'package:brick_sqlite_abstract/db.dart';

void main() {
  group('SchemaColumn', () {
    test('isPrimaryKey must be int', () {
      expect(
        () => SchemaColumn(InsertTable.PRIMARY_KEY_COLUMN, Column.varchar, isPrimaryKey: true),
        throwsA(TypeMatcher<AssertionError>()),
      );
    });

    test('defaults', () {
      final column = SchemaColumn(InsertTable.PRIMARY_KEY_COLUMN, Column.varchar);

      // These expectations can never be removed, otherwise old schemas would be invalid
      expect(column.autoincrement, isFalse);
      expect(column.nullable, isTrue);
      expect(column.isPrimaryKey, isFalse);
      expect(column.isForeignKey, isFalse);
    });

    group('#forGenerator', () {
      test('simple', () {
        final column = SchemaColumn('first_name', Column.varchar);
        expect(column.forGenerator, "SchemaColumn('first_name', Column.varchar)");
      });

      test('primary key', () {
        final column =
            SchemaColumn('_brick_id', Column.integer, autoincrement: true, isPrimaryKey: true);
        expect(
          column.forGenerator,
          "SchemaColumn('_brick_id', Column.integer, autoincrement: true, isPrimaryKey: true)",
        );
      });

      test('defaultValue', () {
        final column = SchemaColumn('amount', Column.integer, defaultValue: 0);
        expect(column.forGenerator, "SchemaColumn('amount', Column.integer, defaultValue: 0)");
      });

      test('nullable', () {
        final column = SchemaColumn('last_name', Column.varchar, nullable: false);
        expect(column.forGenerator, "SchemaColumn('last_name', Column.varchar, nullable: false)");
      });

      test('association', () {
        final column =
            SchemaColumn('hat_id', Column.integer, isForeignKey: true, foreignTableName: 'hat');
        expect(
          column.forGenerator,
          "SchemaColumn('hat_id', Column.integer, isForeignKey: true, foreignTableName: 'hat', onDeleteCascade: false, onDeleteSetDefault: false)",
        );
      });

      test('columnType', () {
        final column = SchemaColumn('image', Column.blob);
        expect(
          column.forGenerator,
          "SchemaColumn('image', Column.blob)",
        );
      });
    });

    group('#toCommand', () {
      test('simple', () {
        final column = SchemaColumn('first_name', Column.varchar);
        column.tableName = 'demo';
        expect(
            column.toCommand(), const InsertColumn('first_name', Column.varchar, onTable: 'demo'));
      });

      test('primary key', () {
        final column =
            SchemaColumn('_brick_id', Column.integer, autoincrement: true, isPrimaryKey: true);
        column.tableName = 'demo';
        expect(
          column.toCommand(),
          const InsertColumn('_brick_id', Column.integer, onTable: 'demo', autoincrement: true),
        );
      });

      test('defaultValue', () {
        final column = SchemaColumn('amount', Column.integer, defaultValue: 0);
        column.tableName = 'demo';
        expect(
          column.toCommand(),
          const InsertColumn('amount', Column.integer, onTable: 'demo', defaultValue: 0),
        );
      });

      test('nullable', () {
        final column = SchemaColumn('last_name', Column.varchar, nullable: false);
        column.tableName = 'demo';
        expect(
          column.toCommand(),
          const InsertColumn('last_name', Column.varchar, onTable: 'demo', nullable: false),
        );
      });

      test('association', () {
        final column =
            SchemaColumn('Hat_id', Column.integer, isForeignKey: true, foreignTableName: 'hat');
        column.tableName = 'demo';
        expect(
            column.toCommand(), const InsertForeignKey('demo', 'hat', foreignKeyColumn: 'Hat_id'));
      });

      test('columnType', () {
        final column = SchemaColumn('image', Column.blob);
        column.tableName = 'demo';
        expect(column.toCommand(), const InsertColumn('image', Column.blob, onTable: 'demo'));
      });
    });

    group('==', () {
      test('subclasses', () {
        const column1 = InsertColumn('1', Column.varchar, onTable: 'table1');
        const column1b = InsertColumn('1', Column.varchar, onTable: 'table1');
        const column2 = InsertColumn('1', Column.varchar, onTable: 'table2');

        expect(column1, isNot(column2));
        expect(column1, column1b);
      });

      test('columnType', () {
        final column3 = SchemaColumn('1', Column.blob);
        final column3b = SchemaColumn('1', Column.blob);
        final column3c = SchemaColumn('1', Column.bigint);

        expect(column3, column3b);
        expect(column3, isNot(column3c));
      });
    });
  });
}
