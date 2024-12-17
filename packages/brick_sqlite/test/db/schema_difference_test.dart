import 'package:brick_sqlite/src/db/column.dart';
import 'package:brick_sqlite/src/db/migration_commands/create_index.dart';
import 'package:brick_sqlite/src/db/migration_commands/drop_column.dart';
import 'package:brick_sqlite/src/db/migration_commands/drop_table.dart';
import 'package:brick_sqlite/src/db/migration_commands/insert_column.dart';
import 'package:brick_sqlite/src/db/migration_commands/insert_foreign_key.dart';
import 'package:brick_sqlite/src/db/migration_commands/insert_table.dart';
import 'package:brick_sqlite/src/db/schema/schema.dart';
import 'package:brick_sqlite/src/db/schema/schema_column.dart';
import 'package:brick_sqlite/src/db/schema/schema_difference.dart';
import 'package:brick_sqlite/src/db/schema/schema_index.dart';
import 'package:brick_sqlite/src/db/schema/schema_table.dart';
import 'package:test/test.dart';

void main() {
  group('SchemaDifference', () {
    final column = SchemaColumn('name', Column.varchar);
    late SchemaTable table;

    final tableNoColumn = SchemaTable(
      'demo',
      columns: <SchemaColumn>{
        SchemaColumn(
          '_brick_id',
          Column.integer,
          autoincrement: true,
          nullable: false,
          isPrimaryKey: true,
        ),
      },
    );

    setUp(() {
      table = SchemaTable(
        'demo',
        columns: <SchemaColumn>{
          SchemaColumn(
            '_brick_id',
            Column.integer,
            autoincrement: true,
            nullable: false,
            isPrimaryKey: true,
          ),
          column,
        },
      );
    });

    test('#droppedTables', () {
      final oldSchema = Schema(0, tables: {table});
      final newSchema = Schema(1, tables: {});

      final diff = SchemaDifference(oldSchema, newSchema);
      expect(diff.droppedTables, contains(table));
      expect(diff.insertedTables, isEmpty);
      expect(diff.hasDifference, isTrue);
    });

    test('#insertedTables', () {
      final oldSchema = Schema(0, tables: {});
      final newSchema = Schema(1, tables: {table});

      final diff = SchemaDifference(oldSchema, newSchema);
      expect(diff.insertedTables, hasLength(1));
      expect(diff.insertedTables, contains(table));
      expect(diff.droppedTables, isEmpty);
      expect(diff.hasDifference, isTrue);
    });

    group('columns', () {
      test('#droppedColumns', () {
        table.columns.add(column);
        final oldSchema = Schema(0, tables: {table});
        final newSchema = Schema(1, tables: {tableNoColumn});

        final diff = SchemaDifference(oldSchema, newSchema);
        expect(diff.droppedColumns, contains(column));
        expect(diff.insertedColumns, isEmpty);
        expect(diff.hasDifference, isTrue);
      });

      test('#insertedColumns', () {
        table.columns.add(column);
        final oldSchema = Schema(0, tables: {tableNoColumn});
        final newSchema = Schema(1, tables: {table});

        final diff = SchemaDifference(oldSchema, newSchema);
        expect(diff.insertedColumns, contains(column));
        expect(diff.droppedColumns, isEmpty);
        expect(diff.hasDifference, isTrue);
      });

      test('#insertedColumns across multiple tables', () {
        final schema = Schema(
          2,
          tables: <SchemaTable>{
            SchemaTable(
              'demo',
              columns: <SchemaColumn>{
                SchemaColumn(
                  '_brick_id',
                  Column.integer,
                  autoincrement: true,
                  nullable: false,
                  isPrimaryKey: true,
                ),
                column,
              },
            ),
            SchemaTable(
              'users',
              columns: <SchemaColumn>{
                SchemaColumn(
                  '_brick_id',
                  Column.integer,
                  autoincrement: true,
                  nullable: false,
                  isPrimaryKey: true,
                ),
                SchemaColumn('email', Column.varchar),
              },
            ),
          },
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
        Column.integer,
        isForeignKey: true,
        foreignTableName: 'user',
      );
      table.columns.add(foreignKeyColumn);

      final oldSchema = Schema(0, tables: {tableNoColumn});
      final newSchema = Schema(1, tables: {table});

      final diff = SchemaDifference(oldSchema, newSchema);
      expect(diff.insertedColumns, contains(foreignKeyColumn));
      expect(diff.droppedColumns, isEmpty);
      expect(diff.hasDifference, isTrue);
    });

    test('#addedForeignKeys:onDeleteCascade', () {
      final foreignKeyColumn = SchemaColumn(
        'user_id',
        Column.integer,
        isForeignKey: true,
        foreignTableName: 'user',
      );
      table.columns.add(foreignKeyColumn);
      final newTable = SchemaTable(
        'demo',
        columns: <SchemaColumn>{
          SchemaColumn(
            '_brick_id',
            Column.integer,
            autoincrement: true,
            nullable: false,
            isPrimaryKey: true,
          ),
          column,
        },
      );
      final foreignKeyColumnWithOnDeleteCascade = SchemaColumn(
        'user_id',
        Column.integer,
        isForeignKey: true,
        foreignTableName: 'user',
        onDeleteCascade: true,
      );
      newTable.columns.add(foreignKeyColumnWithOnDeleteCascade);

      final oldSchema = Schema(0, tables: {table});
      final newSchema = Schema(1, tables: {newTable});

      final diff = SchemaDifference(oldSchema, newSchema);
      expect(diff.insertedColumns, contains(foreignKeyColumnWithOnDeleteCascade));
      expect(diff.droppedColumns, contains(foreignKeyColumn));
      expect(diff.hasDifference, isTrue);
    });

    test('#addedForeignKeys:onDeleteSetDefault', () {
      final foreignKeyColumn = SchemaColumn(
        'user_id',
        Column.integer,
        isForeignKey: true,
        foreignTableName: 'user',
      );
      table.columns.add(foreignKeyColumn);
      final newTable = SchemaTable(
        'demo',
        columns: <SchemaColumn>{
          SchemaColumn(
            '_brick_id',
            Column.integer,
            autoincrement: true,
            nullable: false,
            isPrimaryKey: true,
          ),
          column,
        },
      );
      final foreignKeyColumnWithOnDeleteSetDefault = SchemaColumn(
        'user_id',
        Column.integer,
        isForeignKey: true,
        foreignTableName: 'user',
        onDeleteSetDefault: true,
      );
      newTable.columns.add(foreignKeyColumnWithOnDeleteSetDefault);

      final oldSchema = Schema(0, tables: {table});
      final newSchema = Schema(1, tables: {newTable});

      final diff = SchemaDifference(oldSchema, newSchema);
      expect(diff.insertedColumns, contains(foreignKeyColumnWithOnDeleteSetDefault));
      expect(diff.droppedColumns, contains(foreignKeyColumn));
      expect(diff.hasDifference, isTrue);
    });

    group('#toMigrationCommands', () {
      test('#insertedTables', () {
        final oldSchema = Schema(0, tables: {});
        final newSchema = Schema(1, tables: {table});

        final diff = SchemaDifference(oldSchema, newSchema);
        expect(
          diff.toMigrationCommands(),
          [
            const InsertTable('demo'),
            InsertColumn(column.name, Column.varchar, onTable: column.tableName!),
          ],
        );
        expect(diff.hasDifference, isTrue);
      });

      test('#insertedColumns', () {
        table.columns.add(column);
        final oldSchema = Schema(0, tables: {});
        final newSchema = Schema(1, tables: {table});

        final diff = SchemaDifference(oldSchema, newSchema);
        expect(
          diff.toMigrationCommands(),
          [
            const InsertTable('demo'),
            InsertColumn(column.name, Column.varchar, onTable: column.tableName!),
          ],
        );
        expect(diff.hasDifference, isTrue);
      });

      test('#droppedColumns', () {
        final oldSchema = Schema(0, tables: {table});
        final newSchema = Schema(1, tables: {tableNoColumn});

        final diff = SchemaDifference(oldSchema, newSchema);
        expect(diff.toMigrationCommands(), [DropColumn(column.name, onTable: column.tableName!)]);
        expect(diff.droppedColumns, hasLength(1));
        expect(diff.insertedColumns, isEmpty);
      });

      test('#droppedTables', () {
        final oldSchema = Schema(0, tables: {table});
        final newSchema = Schema(1, tables: {});

        final diff = SchemaDifference(oldSchema, newSchema);
        expect(diff.toMigrationCommands(), [const DropTable('demo')]);
        expect(diff.droppedTables, hasLength(1));
        expect(diff.insertedTables, isEmpty);
      });

      test('joins table indexes', () {
        final oldSchema = Schema(0, tables: {});
        final newSchema = Schema(
          1,
          tables: {
            SchemaTable(
              '_brick_People_friend',
              columns: <SchemaColumn>{
                SchemaColumn(
                  '_brick_id',
                  Column.integer,
                  autoincrement: true,
                  nullable: false,
                  isPrimaryKey: true,
                ),
                SchemaColumn(
                  'l_People_brick_id',
                  Column.integer,
                  isForeignKey: true,
                  foreignTableName: 'People',
                  onDeleteSetDefault: true,
                ),
                SchemaColumn(
                  'f_Friend_brick_id',
                  Column.integer,
                  isForeignKey: true,
                  foreignTableName: 'Friend',
                  onDeleteSetDefault: true,
                ),
              },
              indices: <SchemaIndex>{
                SchemaIndex(columns: ['l_People_brick_id', 'f_Friend_brick_id'], unique: true),
              },
            ),
          },
        );

        final diff = SchemaDifference(oldSchema, newSchema);
        expect(diff.toMigrationCommands(), [
          const InsertTable('_brick_People_friend'),
          const InsertForeignKey(
            '_brick_People_friend',
            'People',
            foreignKeyColumn: 'l_People_brick_id',
            onDeleteSetDefault: true,
          ),
          const InsertForeignKey(
            '_brick_People_friend',
            'Friend',
            foreignKeyColumn: 'f_Friend_brick_id',
            onDeleteSetDefault: true,
          ),
          const CreateIndex(
            columns: ['l_People_brick_id', 'f_Friend_brick_id'],
            onTable: '_brick_People_friend',
            unique: true,
          ),
        ]);
      });
    });

    test('#forGenerator', () {
      final oldSchema = Schema(0, tables: {});
      final newSchema = Schema(1, tables: {table});

      final diff = SchemaDifference(oldSchema, newSchema);
      expect(
        diff.forGenerator,
        "[\nInsertTable('demo'),\nInsertColumn('name', Column.varchar, onTable: 'demo')\n]",
      );
      expect(diff.hasDifference, isTrue);
    });

    test('#hasDifference between equal schemas', () {
      final oldSchema = Schema(0, tables: {table});
      final newSchema = Schema(1, tables: {table});

      final diff = SchemaDifference(oldSchema, newSchema);
      expect(diff.hasDifference, isFalse);
    });

    test('oldSchema is less than newSchema', () {
      final old = Schema(2, tables: <SchemaTable>{});
      final fresh = Schema(1, tables: <SchemaTable>{});

      expect(() => SchemaDifference(old, fresh), throwsA(const TypeMatcher<AssertionError>()));
    });
  });
}
