import 'package:brick_core/core.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_sqlite/src/db/migration_commands/insert_table.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:test/test.dart';

import '__mocks__.dart';

void main() {
  sqfliteFfiInit();

  group('SqliteProvider', () {
    final provider = SqliteProvider(
      inMemoryDatabasePath,
      databaseFactory: databaseFactoryFfi,
      modelDictionary: dictionary,
    );

    setUp(() async {
      await provider.migrate([const DemoModelMigration()]);
      await provider.upsert<DemoModel>(DemoModel(name: 'ThomasDefault'));
      await provider.upsert<DemoModel>(DemoModel(name: 'GuyDefault'));
      await provider.upsert<DemoModel>(DemoModel(name: 'AliceDefault'));
    });

    tearDown(() async {
      await provider.resetDb();
    });

    test('#get', () async {
      final models = await provider.get<DemoModel>();
      expect(models, hasLength(3));
    });

    group('#upsert', () {
      test('insert', () async {
        final newModel = DemoModel(name: 'John');

        final newPrimaryKey = await provider.upsert<DemoModel>(newModel);
        expect(newPrimaryKey, 4);
      });

      test('update', () async {
        final newModel = DemoModel(name: 'Guy')..primaryKey = 2;

        final primaryKey = await provider.upsert<DemoModel>(newModel);
        expect(primaryKey, 2);
      });

      test('append associations', () async {
        final newModel = DemoModel(
          name: 'Guy',
          manyAssoc: [DemoModelAssoc(name: 'Thomas'), DemoModelAssoc(name: 'Alice')],
        );
        await provider.upsert<DemoModel>(newModel);
        final associationCount = await provider.get<DemoModelAssoc>();
        expect(associationCount, hasLength(2));
      });

      test('remove associations', () async {
        final newModel = DemoModel(
          name: 'Guy',
          manyAssoc: [DemoModelAssoc(name: 'Thomas'), DemoModelAssoc(name: 'Alice')],
        );
        final model = newModel..primaryKey = await provider.upsert<DemoModel>(newModel);
        model.manyAssoc?.clear();
        await provider.upsert<DemoModel>(model);
        final withClearedAssociations = await provider.get<DemoModel>(
          query: Query.where(
            InsertTable.PRIMARY_KEY_FIELD,
            model.primaryKey,
            limit1: true,
          ),
        );
        expect(withClearedAssociations.first.manyAssoc, isEmpty);
      });
    });

    test('#delete', () async {
      final newModel = DemoModel(name: 'GuyDelete');

      final model = newModel..primaryKey = await provider.upsert<DemoModel>(newModel);
      final doesExist = await provider.exists<DemoModel>(query: Query.where('name', newModel.name));
      expect(doesExist, isTrue);
      final result = await provider.delete<DemoModel>(model);
      expect(result, 1);
      final existsAfterDelete =
          await provider.exists<DemoModel>(query: Query.where('name', newModel.name));
      expect(existsAfterDelete, isFalse);
    });

    group('#migrate', () {
      late SqliteProvider cleanProvider;

      setUp(() {
        cleanProvider = SqliteProvider(
          inMemoryDatabasePath,
          databaseFactory: databaseFactoryFfi,
          modelDictionary: dictionary,
        );
      });

      tearDown(() async {
        await cleanProvider.resetDb();
      });

      test('runs migrations for the first time', () async {
        await cleanProvider.migrate([const DemoModelMigration()]);

        final version = await cleanProvider.lastMigrationVersion();
        expect(version, 1);

        // Verify tables were created
        final tables = await cleanProvider.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
        );
        final tableNames = tables.map((t) => t['name']).toList();
        expect(tableNames, contains('DemoModelAssoc'));
        expect(tableNames, contains('DemoModel'));
      });

      test('skips migrations when already at latest version', () async {
        // Run migration first time
        await cleanProvider.migrate([const DemoModelMigration()]);
        expect(await cleanProvider.lastMigrationVersion(), 1);

        // Run again - should skip
        await cleanProvider.migrate([const DemoModelMigration()]);
        expect(await cleanProvider.lastMigrationVersion(), 1);
      });

      test('enables foreign keys pragma', () async {
        const migration = DemoModelMigration();

        await cleanProvider.migrate([migration]);

        final result = await cleanProvider.rawQuery('PRAGMA foreign_keys');
        expect(result.first['foreign_keys'], 1);
      });

      test('tracks migration versions correctly', () async {
        const migration1 = DemoModelMigration(2, [], []);
        const migration2 = DemoModelMigration(3, [], []);

        // After first migration
        await cleanProvider.migrate([migration1]);
        expect(await cleanProvider.lastMigrationVersion(), 2);

        // After second migration
        await cleanProvider.migrate([migration2]);
        expect(await cleanProvider.lastMigrationVersion(), 3);

        // Verify version records exist
        // ignore: invalid_use_of_protected_member
        final db = await cleanProvider.getDb();
        final versions = await db.query('MigrationVersions', orderBy: 'version');
        expect(versions, hasLength(3));
        expect(versions[0]['version'], 1);
        expect(versions[1]['version'], 2);
        expect(versions[2]['version'], 3);
      });

      test('runs down migrations correctly', () async {
        const migration1 = DemoModelMigration(2, [], []);
        const migration2 = DemoModelMigration(3, [], []);

        // After first migration
        await cleanProvider.migrate([migration1]);
        expect(await cleanProvider.lastMigrationVersion(), 2);

        // After second migration
        await cleanProvider.migrate([migration2]);
        expect(await cleanProvider.lastMigrationVersion(), 3);

        await cleanProvider.migrate([migration1, migration2], down: true);
        expect(await cleanProvider.lastMigrationVersion(), 1);

        // Verify version records exist
        // ignore: invalid_use_of_protected_member
        final db = await cleanProvider.getDb();
        final versions = await db.query('MigrationVersions', orderBy: 'version');
        expect(versions, hasLength(1));
        expect(versions[0]['version'], 1);
      });
    });

    group('#exists', () {
      test('specific', () async {
        final newModel = DemoModel(name: 'Guy');

        await provider.upsert<DemoModel>(newModel);
        final doesExist =
            await provider.exists<DemoModel>(query: Query.where('name', newModel.name));
        expect(doesExist, isTrue);
      });

      test('general', () async {
        final newModel = DemoModel(name: 'Guy');

        await provider.upsert<DemoModel>(newModel);
        final doesExist = await provider.exists<DemoModel>();
        expect(doesExist, isTrue);
      });

      test('does not exist', () async {
        final doesExist = await provider.exists<DemoModel>(query: Query.where('name', 'Alice'));
        expect(doesExist, isFalse);
      });

      test('with an offset', () async {
        await provider.upsert<DemoModel>(DemoModel(name: 'Guy'));
        final existingModels = await provider.get<DemoModel>();
        final query = Query(limit: 1, offset: existingModels.length);

        final doesExistWithoutModel = await provider.exists<DemoModel>(query: query);
        expect(doesExistWithoutModel, isFalse);

        await provider.upsert<DemoModel>(DemoModel(name: 'Guy'));
        final doesExistWithModel = await provider.exists<DemoModel>(query: query);
        expect(doesExistWithModel, isTrue);
      });
    });

    test('with an association and an offset', () async {
      await provider
          .upsert<DemoModel>(DemoModel(name: 'Guy', manyAssoc: [DemoModelAssoc(name: 'Thomas')]));
      final query = Query(
        where: [const Where('manyAssoc').isExactly(const Where('name').isExactly('Thomas'))],
        limit: 1,
        offset: 1,
      );

      final doesExistWithoutModel = await provider.exists<DemoModel>(query: query);
      expect(doesExistWithoutModel, isFalse);

      await provider
          .upsert<DemoModel>(DemoModel(name: 'Guy', manyAssoc: [DemoModelAssoc(name: 'Thomas')]));
      final doesExistWithModel = await provider.exists<DemoModel>(query: query);
      expect(doesExistWithModel, isTrue);
    });
  });
}
