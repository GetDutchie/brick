import 'package:brick_core/core.dart';
import 'package:brick_sqlite_abstract/sqlite_model.dart';
import 'package:brick_sqlite_abstract/db.dart';
import 'package:brick_sqlite/sqlite.dart';
import 'package:test/test.dart';
import 'package:flutter_test/flutter_test.dart' as ft;
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '__mocks__.dart';
import '__mocks__/demo_model_adapter.dart';

void main() {
  ft.TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  group('SqliteProvider', () {
    final provider = SqliteProvider(
      inMemoryDatabasePath,
      databaseFactory: databaseFactoryFfi,
      modelDictionary: dictionary,
    );

    setUp(() async {
      await provider.migrate([DemoModelMigration()]);
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

      test('update associations', () async {
        final newModel = DemoModel(
          name: 'Guy',
          manyAssoc: [DemoModelAssoc(name: 'Thomas'), DemoModelAssoc(name: 'Alice')],
        );
        final model = newModel..primaryKey = await provider.upsert<DemoModel>(newModel);
        final associationCount = await provider.get<DemoModelAssoc>();
        expect(associationCount, hasLength(2));
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

    test('#migrate', () {}, skip: 'Write test');

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
        final query = Query(providerArgs: {'limit': 1, 'offset': existingModels.length});

        final doesExistWithoutModel = await provider.exists<DemoModel>(query: query);
        expect(doesExistWithoutModel, isFalse);

        await provider.upsert<DemoModel>(DemoModel(name: 'Guy'));
        final doesExistWithModel = await provider.exists<DemoModel>(query: query);
        expect(doesExistWithModel, isTrue);
      });
    });
  });

  group('SqliteModel', () {
    test('#primaryKey', () {
      final m = DemoModel(name: 'Thomas');
      expect(m.primaryKey, NEW_RECORD_ID);

      m.primaryKey = 2;
      expect(m.primaryKey, 2);
    });

    test('#isNewRecord', () {
      final m = DemoModel(name: 'Thomas');
      expect(m.isNewRecord, isTrue);
    });

    test('#beforeSave', () {}, skip: 'add test');
    test('#afterSave', () {}, skip: 'add test');
  });

  group('SqliteAdapter', () {
    final a = DemoModelAdapter();

    test('#tableName', () {
      expect(a.tableName, 'DemoModel');
    });
  });
}
