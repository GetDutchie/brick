import 'package:brick_build_test/brick_build_test.dart';
import 'package:brick_sqlite/db.dart';
import 'package:brick_sqlite_generators/src/sqlite_schema/migration_generator.dart';
import 'package:test/test.dart';

import 'migration_generator/test_from_identical_schema.dart' as from_identical_schema;
import 'migration_generator/test_from_new_schema.dart' as from_new_schema;

const generator = MigrationGenerator();
final generateLibrary = generateLibraryForFolder('migration_generator');
void main() {
  group('MigrationGenerator', () {
    group('#expandAllMigrations', () {
      test('DropColumn', () async {
        final reader = await generateLibrary('drop_column');

        final migrations = generator.expandAllMigrations(reader);
        expect(migrations, hasLength(1));
        expect(migrations.first, isA<Migration>());
        expect(migrations.first.up, hasLength(2));
        expect(migrations.first.up.last, isA<DropColumn>());
        expect(migrations.first.up.last.statement, null);
      });

      test('CreateIndex', () async {
        final reader = await generateLibrary('create_index');

        final migrations = generator.expandAllMigrations(reader);
        expect(migrations, hasLength(1));
        expect(migrations.first, isA<Migration>());
        expect(migrations.first.up, hasLength(3));
        expect(migrations.first.up.last, isA<CreateIndex>());
        expect(
          migrations.first.up.last.statement,
          'CREATE INDEX IF NOT EXISTS index_demo_on_name on `demo`(`name`)',
        );
      });

      test('DropTable', () async {
        final reader = await generateLibrary('drop_table');

        final migrations = generator.expandAllMigrations(reader);
        expect(migrations, hasLength(1));
        expect(migrations.first, isA<Migration>());
        expect(migrations.first.up, hasLength(2));
        expect(migrations.first.up.last, isA<DropTable>());
        expect(migrations.first.up.last.statement, startsWith('DROP TABLE IF EXISTS `demo`'));
      });

      test('InsertColumn', () async {
        final reader = await generateLibrary('insert_column');

        final migrations = generator.expandAllMigrations(reader);
        expect(migrations, hasLength(1));
        expect(migrations.first, isA<Migration>());
        expect(migrations.first.up, hasLength(2));
        expect(migrations.first.up.last, isA<InsertColumn>());
        expect(migrations.first.up.last.statement, startsWith('ALTER TABLE `demo` ADD `name`'));
      });

      test('InsertForeignKey', () async {
        final reader = await generateLibrary('insert_foreign_key');

        final migrations = generator.expandAllMigrations(reader);
        expect(migrations, hasLength(1));
        expect(migrations.first, isA<Migration>());
        expect(migrations.first.up, hasLength(2));
        expect(migrations.first.up.last, isA<InsertForeignKey>());
        expect(migrations.first.up.last.statement, contains('`users_brick_id` INTEGER'));
      });

      test('InsertTable', () async {
        final reader = await generateLibrary('insert_table');

        final migrations = generator.expandAllMigrations(reader);
        expect(migrations, hasLength(1));
        expect(migrations.first, isA<Migration>());
        expect(migrations.first.up, hasLength(1));
        expect(migrations.first.up.first, isA<InsertTable>());
        expect(
          migrations.first.up.first.statement,
          startsWith('CREATE TABLE IF NOT EXISTS `demo`'),
        );
      });

      test('RenameColumn', () async {
        final reader = await generateLibrary('rename_column');

        final migrations = generator.expandAllMigrations(reader);
        expect(migrations, hasLength(1));
        expect(migrations.first, isA<Migration>());
        expect(migrations.first.up, hasLength(3));
        expect(migrations.first.up.last, isA<RenameColumn>());
        expect(migrations.first.up.last.statement, null);
      });

      test('RenameTable', () async {
        final reader = await generateLibrary('rename_table');

        final migrations = generator.expandAllMigrations(reader);
        expect(migrations, hasLength(1));
        expect(migrations.first, isA<Migration>());
        expect(migrations.first.up, hasLength(2));
        expect(migrations.first.up.last, isA<RenameTable>());
        expect(migrations.first.up.last.statement, contains('`demo` RENAME TO `new_demo`'));
      });
    });

    group('#generate', () {
      test('with a new schema', () async {
        final reader = await generateLibrary('from_new_schema');
        final output = generator.generate(
          reader,
          MockBuildStep(),
          newSchema: from_new_schema.schema,
          version: 2,
        );

        expect(output, from_new_schema.output);
      });

      test('with an identical schema', () async {
        final reader = await generateLibrary('from_identical_schema');
        final output =
            generator.generate(reader, MockBuildStep(), newSchema: from_identical_schema.schema);
        expect(output, isNull);
      });
    });

    test('.allMigrationsByFilePath', () async {
      final reader = await generateLibrary('insert_table');
      final migrations = MigrationGenerator.allMigrationsByFilePath(reader);

      expect(migrations, hasLength(1));
      expect(migrations, containsPair('Migration1', 'test_insert_table.dart'));
    });
  });
}
