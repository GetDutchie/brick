import '__mocks__.dart';

void main() {
  group('SchemaDifference', () {
    final column = SchemaColumn('name', String);
    SchemaTable table;

    final tableNoColumn = SchemaTable(
      'demo',
      columns: Set<SchemaColumn>.from([
        SchemaColumn('_brick_id', int, autoincrement: true, nullable: false, isPrimaryKey: true),
      ]),
    );

    setUp(() {
      table = SchemaTable(
        'demo',
        columns: Set<SchemaColumn>.from([
          SchemaColumn('_brick_id', int, autoincrement: true, nullable: false, isPrimaryKey: true),
          column
        ]),
      );
    });

    test('#droppedTables', () {
      final oldSchema = Schema(0, tables: Set.from([table]));
      final newSchema = Schema(1, tables: Set.from([]));

      final diff = SchemaDifference(oldSchema, newSchema);
      expect(diff.droppedTables, contains(table));
      expect(diff.insertedTables, isEmpty);
      expect(diff.hasDifference, isTrue);
    });

    test('#insertedTables', () {
      final oldSchema = Schema(0, tables: Set.from([]));
      final newSchema = Schema(1, tables: Set.from([table]));

      final diff = SchemaDifference(oldSchema, newSchema);
      expect(diff.insertedTables, hasLength(1));
      expect(diff.insertedTables, contains(table));
      expect(diff.droppedTables, isEmpty);
      expect(diff.hasDifference, isTrue);
    });

    group('columns', () {
      test('#droppedColumns', () {
        table.columns.add(column);
        final oldSchema = Schema(0, tables: Set.from([table]));
        final newSchema = Schema(1, tables: Set.from([tableNoColumn]));

        final diff = SchemaDifference(oldSchema, newSchema);
        expect(diff.droppedColumns, contains(column));
        expect(diff.insertedColumns, isEmpty);
        expect(diff.hasDifference, isTrue);
      });

      test('#insertedColumns', () {
        table.columns.add(column);
        final oldSchema = Schema(0, tables: Set.from([tableNoColumn]));
        final newSchema = Schema(1, tables: Set.from([table]));

        final diff = SchemaDifference(oldSchema, newSchema);
        expect(diff.insertedColumns, contains(column));
        expect(diff.droppedColumns, isEmpty);
        expect(diff.hasDifference, isTrue);
      });

      test('#insertedColumns across multiple tables', () {
        final schema = Schema(
          2,
          tables: Set<SchemaTable>.from([
            SchemaTable(
              'demo',
              columns: Set<SchemaColumn>.from([
                SchemaColumn('_brick_id', int,
                    autoincrement: true, nullable: false, isPrimaryKey: true),
                column,
              ]),
            ),
            SchemaTable(
              'users',
              columns: Set<SchemaColumn>.from([
                SchemaColumn('_brick_id', int,
                    autoincrement: true, nullable: false, isPrimaryKey: true),
                SchemaColumn('email', String)
              ]),
            ),
          ]),
        );

        expect(
          schema.forGenerator,
          stringContainsInOrder([
            "SchemaTable(\n      'demo'",
            "SchemaTable(\n      'users'",
          ]),
        );
      });
    });

    test('#addedForeignKeys', () {
      final foreignKeyColumn = SchemaColumn(
        'user_id',
        int,
        isForeignKey: true,
        foreignTableName: 'user',
      );
      table.columns.add(foreignKeyColumn);

      final oldSchema = Schema(0, tables: Set.from([tableNoColumn]));
      final newSchema = Schema(1, tables: Set.from([table]));

      final diff = SchemaDifference(oldSchema, newSchema);
      expect(diff.insertedColumns, contains(foreignKeyColumn));
      expect(diff.droppedColumns, isEmpty);
      expect(diff.hasDifference, isTrue);
    });

    test('#addedForeignKeys:onDeleteCascade', () {
      final foreignKeyColumn = SchemaColumn(
        'user_id',
        int,
        isForeignKey: true,
        foreignTableName: 'user',
      );
      table.columns.add(foreignKeyColumn);
      final newTable = SchemaTable(
        'demo',
        columns: Set<SchemaColumn>.from([
          SchemaColumn('_brick_id', int, autoincrement: true, nullable: false, isPrimaryKey: true),
          column
        ]),
      );
      final foreignKeyColumnWithOnDeleteCascade = SchemaColumn(
        'user_id',
        int,
        isForeignKey: true,
        foreignTableName: 'user',
        onDeleteCascade: true,
      );
      newTable.columns.add(foreignKeyColumnWithOnDeleteCascade);

      final oldSchema = Schema(0, tables: Set.from([table]));
      final newSchema = Schema(1, tables: Set.from([newTable]));

      final diff = SchemaDifference(oldSchema, newSchema);
      expect(diff.insertedColumns, contains(foreignKeyColumnWithOnDeleteCascade));
      expect(diff.droppedColumns, contains(foreignKeyColumn));
      expect(diff.hasDifference, isTrue);
    });

    test('#addedForeignKeys:onDeleteSetDefault', () {
      final foreignKeyColumn = SchemaColumn(
        'user_id',
        int,
        isForeignKey: true,
        foreignTableName: 'user',
      );
      table.columns.add(foreignKeyColumn);
      final newTable = SchemaTable(
        'demo',
        columns: Set<SchemaColumn>.from([
          SchemaColumn('_brick_id', int, autoincrement: true, nullable: false, isPrimaryKey: true),
          column
        ]),
      );
      final foreignKeyColumnWithOnDeleteSetDefault = SchemaColumn(
        'user_id',
        int,
        isForeignKey: true,
        foreignTableName: 'user',
        onDeleteSetDefault: true,
      );
      newTable.columns.add(foreignKeyColumnWithOnDeleteSetDefault);

      final oldSchema = Schema(0, tables: Set.from([table]));
      final newSchema = Schema(1, tables: Set.from([newTable]));

      final diff = SchemaDifference(oldSchema, newSchema);
      expect(diff.insertedColumns, contains(foreignKeyColumnWithOnDeleteSetDefault));
      expect(diff.droppedColumns, contains(foreignKeyColumn));
      expect(diff.hasDifference, isTrue);
    });

    group('#toMigrationCommands', () {
      test('#insertedTables', () {
        final oldSchema = Schema(0, tables: Set.from([]));
        final newSchema = Schema(1, tables: Set.from([table]));

        final diff = SchemaDifference(oldSchema, newSchema);
        expect(
          diff.toMigrationCommands(),
          [
            InsertTable('demo'),
            InsertColumn(column.name, Column.varchar, onTable: column.tableName)
          ],
        );
        expect(diff.hasDifference, isTrue);
      });

      test('#insertedColumns', () {
        table.columns.add(column);
        final oldSchema = Schema(0, tables: Set.from([]));
        final newSchema = Schema(1, tables: Set.from([table]));

        final diff = SchemaDifference(oldSchema, newSchema);
        expect(
          diff.toMigrationCommands(),
          [
            InsertTable('demo'),
            InsertColumn(column.name, Column.varchar, onTable: column.tableName)
          ],
        );
        expect(diff.hasDifference, isTrue);
      });

      test('#droppedColumns', () {
        final oldSchema = Schema(0, tables: Set.from([table]));
        final newSchema = Schema(1, tables: Set.from([tableNoColumn]));

        final diff = SchemaDifference(oldSchema, newSchema);
        expect(diff.toMigrationCommands(), [DropColumn(column.name, onTable: column.tableName)]);
        expect(diff.droppedColumns, hasLength(1));
        expect(diff.insertedColumns, isEmpty);
      });

      test('#droppedTables', () {
        final oldSchema = Schema(0, tables: Set.from([table]));
        final newSchema = Schema(1, tables: Set.from([]));

        final diff = SchemaDifference(oldSchema, newSchema);
        expect(diff.toMigrationCommands(), [DropTable('demo')]);
        expect(diff.droppedTables, hasLength(1));
        expect(diff.insertedTables, isEmpty);
      });
    });

    test('#forGenerator', () {
      final oldSchema = Schema(0, tables: Set.from([]));
      final newSchema = Schema(1, tables: Set.from([table]));

      final diff = SchemaDifference(oldSchema, newSchema);
      expect(
        diff.forGenerator,
        "[\nInsertTable('demo'),\nInsertColumn('name', Column.varchar, onTable: 'demo')\n]",
      );
      expect(diff.hasDifference, isTrue);
    });

    test('#hasDifference between equal schemas', () {
      final oldSchema = Schema(0, tables: Set.from([table]));
      final newSchema = Schema(1, tables: Set.from([table]));

      final diff = SchemaDifference(oldSchema, newSchema);
      expect(diff.hasDifference, isFalse);
    });

    test('oldSchema is less than newSchema', () {
      final old = Schema(2, tables: Set<SchemaTable>());
      final fresh = Schema(1, tables: Set<SchemaTable>());

      expect(() => SchemaDifference(old, fresh), throwsA(TypeMatcher<AssertionError>()));
    });
  });
}
