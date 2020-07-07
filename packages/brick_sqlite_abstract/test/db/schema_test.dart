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
                columns: Set<SchemaColumn>.from([
                  SchemaColumn('_brick_id', int,
                      autoincrement: true, nullable: false, isPrimaryKey: true)
                ]),
              )
            },
          );

          final newSchema = Schema.fromMigrations([insertTable].toSet());
          expect(newSchema.tables, schema.tables);
          expect(newSchema.version, schema.version);
        });
      });

      group('RenameTable', () {
        test('without a prior, relevant insert migration', () {
          expect(
            () => Schema.fromMigrations([Migration0None(), renameTable].toSet()),
            throwsA(TypeMatcher<StateError>()),
          );
        });

        test('runs', () {
          final schema = Schema(
            2,
            tables: <SchemaTable>{
              SchemaTable(
                'demo1',
                columns: Set<SchemaColumn>.from([
                  SchemaColumn('_brick_id', int,
                      autoincrement: true, nullable: false, isPrimaryKey: true)
                ]),
              )
            },
          );

          final newSchema = Schema.fromMigrations([insertTable, renameTable].toSet());
          expect(newSchema.tables, schema.tables);
          expect(newSchema.version, schema.version);
        });
      });

      group('DropTable', () {
        test('without a prior, relevant insert migration', () {
          expect(
            () => Schema.fromMigrations([Migration0None(), dropTable].toSet()),
            throwsA(TypeMatcher<StateError>()),
          );
        });

        test('runs', () {
          final schema = Schema(
            3,
            tables: Set<SchemaTable>(),
          );

          final newSchema = Schema.fromMigrations([insertTable, dropTable].toSet());
          expect(newSchema.tables, schema.tables);
          expect(newSchema.version, schema.version);
        });
      });

      group('InsertColumn', () {
        test('without a prior, relevant InsertTable migration', () {
          expect(() => Schema.fromMigrations([Migration0None(), insertColumn].toSet()),
              throwsA(TypeMatcher<StateError>()));
        });

        test('runs', () {
          final schema = Schema(
            4,
            tables: <SchemaTable>{
              SchemaTable(
                'demo',
                columns: Set<SchemaColumn>.from([
                  SchemaColumn('_brick_id', int,
                      autoincrement: true, nullable: false, isPrimaryKey: true),
                  SchemaColumn('name', String)
                ]),
              )
            },
          );

          final newSchema = Schema.fromMigrations([insertTable, insertColumn].toSet());
          expect(newSchema.tables, schema.tables);
          expect(newSchema.version, schema.version);
        });
      });

      group('RenameColumn', () {
        test('without a prior, relevant InsertTable migration', () {
          expect(
            () => Schema.fromMigrations([Migration0None(), renameColumn].toSet()),
            throwsA(TypeMatcher<StateError>()),
          );
        });

        test('without a prior, relevant InsertColumn migration', () {
          expect(() => Schema.fromMigrations([insertTable, renameColumn].toSet()),
              throwsA(TypeMatcher<StateError>()));
        });

        test('runs', () {
          final schema = Schema(
            5,
            tables: <SchemaTable>{
              SchemaTable(
                'demo',
                columns: Set<SchemaColumn>.from([
                  SchemaColumn('_brick_id', int,
                      autoincrement: true, nullable: false, isPrimaryKey: true),
                  SchemaColumn('first_name', String)
                ]),
              )
            },
          );

          final newSchema =
              Schema.fromMigrations([insertTable, insertColumn, renameColumn].toSet());
          expect(newSchema.tables, schema.tables);
          expect(newSchema.version, schema.version);
        });
      });

      group('InsertForeignKey', () {
        test('without a prior, relevant InsertTable migration', () {
          expect(
            () => Schema.fromMigrations([Migration0None(), insertForeignKey].toSet()),
            throwsA(TypeMatcher<StateError>()),
          );
        });

        test('runs', () {
          final schema = Schema(
            6,
            tables: <SchemaTable>{
              SchemaTable(
                'demo',
                columns: Set<SchemaColumn>.from([
                  SchemaColumn('_brick_id', int,
                      autoincrement: true, nullable: false, isPrimaryKey: true),
                  SchemaColumn('demo2_id', int, isForeignKey: true, foreignTableName: 'demo2')
                ]),
              )
            },
          );

          final newSchema = Schema.fromMigrations([insertTable, insertForeignKey].toSet());
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
                  SchemaColumn('_brick_id', int,
                      autoincrement: true, nullable: false, isPrimaryKey: true),
                },
                indices: <SchemaIndex>{
                  SchemaIndex(columns: ['_brick_id'], unique: true),
                },
              )
            },
          );

          final newSchema = Schema.fromMigrations([insertTable, createIndex].toSet());
          print(newSchema.forGenerator);
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
                  SchemaColumn('_brick_id', int,
                      autoincrement: true, nullable: false, isPrimaryKey: true),
                },
                indices: <SchemaIndex>{},
              )
            },
          );

          final newSchema = Schema.fromMigrations([insertTable, createIndex, dropIndex].toSet());
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
              columns: Set<SchemaColumn>.from([
                SchemaColumn('_brick_id', int,
                    autoincrement: true, nullable: false, isPrimaryKey: true)
              ]),
            ),
            SchemaTable(
              'demo2',
              columns: Set<SchemaColumn>.from([
                SchemaColumn('_brick_id', int,
                    autoincrement: true, nullable: false, isPrimaryKey: true)
              ]),
            ),
          },
        );

        final newSchema = Schema.fromMigrations([insertTable, Migration2()].toSet());
        expect(newSchema.tables, schema.tables);
        expect(newSchema.version, schema.version);
      });

      test('version must be positive if provided', () {
        expect(() => Schema.fromMigrations(<Migration>{}, -1),
            throwsA(const TypeMatcher<AssertionError>()));
      });

      test("version uses the migrations' largest version if not provided", () {
        expect(Schema.fromMigrations([Migration2(), Migration1()].toSet()).version, 2);
      });
    });

    test('.expandMigrations', () {
      final migrations = [MigrationInsertTable(), MigrationRenameColumn()].toSet();

      final commands = Schema.expandMigrations(migrations);
      // Maintains sort order
      expect(commands, [InsertTable('demo'), RenameColumn('name', 'first_name', onTable: 'demo')]);
    });

    test('#forGenerator', () {
      final schema = Schema.fromMigrations([MigrationInsertTable(), Migration2()].toSet());

      expect(schema.forGenerator, '''
Schema(
  2,
  generatorVersion: 1,
  tables: <SchemaTable>{
    SchemaTable(
      'demo',
      columns: <SchemaColumn>{
        SchemaColumn('_brick_id', int, autoincrement: true, nullable: false, isPrimaryKey: true)
      },
      indices: <SchemaIndex>{
          
      }
    ),
    SchemaTable(
      'demo2',
      columns: <SchemaColumn>{
        SchemaColumn('_brick_id', int, autoincrement: true, nullable: false, isPrimaryKey: true)
      },
      indices: <SchemaIndex>{
          
      }
    )
  }
)''');
    });
  });
}
