import 'package:brick_sqlite/src/db/column.dart';
import 'package:brick_sqlite/src/db/migration.dart';
import 'package:brick_sqlite/src/db/migration_commands/insert_table.dart';
import 'package:brick_sqlite/src/db/migration_commands/rename_column.dart';
import 'package:brick_sqlite/src/db/schema/schema.dart';
import 'package:brick_sqlite/src/db/schema/schema_column.dart';
import 'package:brick_sqlite/src/db/schema/schema_index.dart';
import 'package:brick_sqlite/src/db/schema/schema_table.dart';
import 'package:test/test.dart';

import '__mocks__.dart';

void main() {
  group('Schema', () {
    group('.fromMigrations', () {
      const insertTable = MigrationInsertTable();
      const renameTable = MigrationRenameTable();
      const dropTable = MigrationDropTable();
      const insertColumn = MigrationInsertColumn();
      const renameColumn = MigrationRenameColumn();
      const insertForeignKey = MigrationInsertForeignKey();
      const createIndex = MigrationCreateIndex();
      const dropIndex = MigrationDropIndex();

      group('InsertTable', () {
        test('calls', () {
          final schema = Schema(
            1,
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
                },
              ),
            },
          );

          final newSchema = Schema.fromMigrations({insertTable});
          expect(newSchema.tables, schema.tables);
          expect(newSchema.version, schema.version);
        });
      });

      group('RenameTable', () {
        test('without a prior, relevant insert migration', () {
          expect(
            () => Schema.fromMigrations({const Migration0None(), renameTable}),
            throwsA(const TypeMatcher<StateError>()),
          );
        });

        test('runs', () {
          final schema = Schema(
            2,
            tables: <SchemaTable>{
              SchemaTable(
                'demo1',
                columns: <SchemaColumn>{
                  SchemaColumn(
                    '_brick_id',
                    Column.integer,
                    autoincrement: true,
                    nullable: false,
                    isPrimaryKey: true,
                  ),
                },
              ),
            },
          );

          final newSchema = Schema.fromMigrations({insertTable, renameTable});
          expect(newSchema.tables, schema.tables);
          expect(newSchema.version, schema.version);
        });
      });

      group('DropTable', () {
        test('without a prior, relevant insert migration', () {
          expect(
            () => Schema.fromMigrations({const Migration0None(), dropTable}),
            throwsA(const TypeMatcher<StateError>()),
          );
        });

        test('runs', () {
          final schema = Schema(
            3,
            tables: <SchemaTable>{},
          );

          final newSchema = Schema.fromMigrations({insertTable, dropTable});
          expect(newSchema.tables, schema.tables);
          expect(newSchema.version, schema.version);
        });
      });

      group('InsertColumn', () {
        test('without a prior, relevant InsertTable migration', () {
          expect(
            () => Schema.fromMigrations({const Migration0None(), insertColumn}),
            throwsA(const TypeMatcher<StateError>()),
          );
        });

        test('runs', () {
          final schema = Schema(
            4,
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
                  SchemaColumn('name', Column.varchar),
                },
              ),
            },
          );

          final newSchema = Schema.fromMigrations({insertTable, insertColumn});
          expect(newSchema.tables, schema.tables);
          expect(newSchema.version, schema.version);
        });
      });

      group('RenameColumn', () {
        test('without a prior, relevant InsertTable migration', () {
          expect(
            () => Schema.fromMigrations({const Migration0None(), renameColumn}),
            throwsA(const TypeMatcher<StateError>()),
          );
        });

        test('without a prior, relevant InsertColumn migration', () {
          expect(
            () => Schema.fromMigrations({insertTable, renameColumn}),
            throwsA(const TypeMatcher<StateError>()),
          );
        });

        test('runs', () {
          final schema = Schema(
            5,
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
                  SchemaColumn('first_name', Column.varchar),
                },
              ),
            },
          );

          final newSchema = Schema.fromMigrations({insertTable, insertColumn, renameColumn});
          expect(newSchema.tables, schema.tables);
          expect(newSchema.version, schema.version);
        });
      });

      group('InsertForeignKey', () {
        test('without a prior, relevant InsertTable migration', () {
          expect(
            () => Schema.fromMigrations({const Migration0None(), insertForeignKey}),
            throwsA(const TypeMatcher<StateError>()),
          );
        });

        test('runs', () {
          final schema = Schema(
            6,
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
                  SchemaColumn(
                    'demo2_id',
                    Column.integer,
                    isForeignKey: true,
                    foreignTableName: 'demo2',
                  ),
                },
              ),
            },
          );

          final newSchema = Schema.fromMigrations({insertTable, insertForeignKey});
          expect(newSchema.tables, schema.tables);
          expect(newSchema.version, schema.version);
        });
      });

      group('CreateIndex', () {
        test('runs', () {
          final schema = Schema(
            7,
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
                },
                indices: <SchemaIndex>{
                  SchemaIndex(columns: ['_brick_id'], unique: true),
                },
              ),
            },
          );

          final newSchema = Schema.fromMigrations({insertTable, createIndex});
          expect(newSchema.tables, schema.tables);
          expect(newSchema.version, schema.version);
        });
      });

      group('DropIndex', () {
        test('runs', () {
          final schema = Schema(
            8,
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
                },
                indices: <SchemaIndex>{},
              ),
            },
          );

          final newSchema = Schema.fromMigrations({insertTable, createIndex, dropIndex});
          expect(newSchema.tables, schema.tables);
          expect(newSchema.version, schema.version);
        });
      });

      test('multiple tables', () {
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
              },
            ),
            SchemaTable(
              'demo2',
              columns: <SchemaColumn>{
                SchemaColumn(
                  '_brick_id',
                  Column.integer,
                  autoincrement: true,
                  nullable: false,
                  isPrimaryKey: true,
                ),
              },
            ),
          },
        );

        final newSchema = Schema.fromMigrations({insertTable, const Migration2()});
        expect(newSchema.tables, schema.tables);
        expect(newSchema.version, schema.version);
      });

      test('version must be positive if provided', () {
        expect(
          () => Schema.fromMigrations(<Migration>{}, -1),
          throwsA(const TypeMatcher<AssertionError>()),
        );
      });

      test("version uses the migrations' largest version if not provided", () {
        expect(Schema.fromMigrations({const Migration2(), const Migration1()}).version, 2);
      });
    });

    test('.expandMigrations', () {
      final migrations = {const MigrationInsertTable(), const MigrationRenameColumn()};

      final commands = Schema.expandMigrations(migrations);
      // Maintains sort order
      expect(
        commands,
        [const InsertTable('demo'), const RenameColumn('name', 'first_name', onTable: 'demo')],
      );
    });

    test('#forGenerator', () {
      final schema = Schema.fromMigrations({const MigrationInsertTable(), const Migration2()});

      expect(schema.forGenerator, '''
Schema(
  2,
  generatorVersion: 1,
  tables: <SchemaTable>{
    SchemaTable(
      'demo',
      columns: <SchemaColumn>{
        SchemaColumn('_brick_id', Column.integer, autoincrement: true, nullable: false, isPrimaryKey: true)
      },
      indices: <SchemaIndex>{

      }
    ),
    SchemaTable(
      'demo2',
      columns: <SchemaColumn>{
        SchemaColumn('_brick_id', Column.integer, autoincrement: true, nullable: false, isPrimaryKey: true)
      },
      indices: <SchemaIndex>{

      }
    )
  }
)''');
    });
  });
}
