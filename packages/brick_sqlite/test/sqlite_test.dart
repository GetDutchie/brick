import 'package:brick_core/core.dart';
import 'package:brick_sqlite_abstract/sqlite_model.dart';
import 'package:brick_sqlite_abstract/db.dart';
import 'package:brick_sqlite/sqlite.dart';
import 'package:test/test.dart';
import 'package:flutter_test/flutter_test.dart' as ft;
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '__mocks__.dart';

void main() {
  ft.TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  group('SqliteProvider', () {
    final provider = SqliteProvider(
      inMemoryDatabasePath,
      databaseFactory: databaseFactoryFfi,
      modelDictionary: dictionary,
    );

    setUpAll(() async {
      await provider.migrate([DemoModelMigration()]);
      await provider.upsert<DemoModel>(DemoModel('Thomas'));
      await provider.upsert<DemoModel>(DemoModel('Guy'));
      await provider.upsert<DemoModel>(DemoModel('John'));
    });

    test('#get', () async {
      final models = await provider.get<DemoModel>();
      expect(models, hasLength(3));
    });

    group('#upsert', () {
      test('insert', () async {
        final newModel = DemoModel('John');

        final newPrimaryKey = await provider.upsert<DemoModel>(newModel);
        expect(newPrimaryKey, 4);
      });

      test('update', () async {
        final newModel = DemoModel('Guy')..primaryKey = 2;

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
        expect(associationCount.length, 2);
        model.manyAssoc.clear();
        await provider.upsert<DemoModel>(model);
        final withClearedAssociations = await provider.get<DemoModel>(
          query: Query.where(
            InsertTable.PRIMARY_KEY_FIELD,
            model.primaryKey,
            limit1: true,
          ),
        );
        expect(withClearedAssociations.first.manyAssoc.length, 0);
      });
    });

    group('#delete', () {
      test('simple', () async {
        final newModel = DemoModel(name: 'GuyDelete');

        final model = newModel..primaryKey = await provider.upsert<DemoModel>(newModel);
        final doesExist =
            await provider.exists<DemoModel>(query: Query.where('name', newModel.name));
        expect(doesExist, isTrue);
        final result = await provider.delete<DemoModel>(model);
        expect(result, 1);
        final existsAfterDelete =
            await provider.exists<DemoModel>(query: Query.where('name', newModel.name));
        expect(existsAfterDelete, isFalse);
      });
    });

    test('#migrate', () {}, skip: 'Write test');

    group('#exists', () {
      test('specific', () async {
        final newModel = DemoModel('John');

        await provider.upsert<DemoModel>(newModel);
        final doesExist = await provider.exists<DemoModel>(query: Query.where('name', 'John'));
        expect(doesExist, isTrue);
      });

      test('general', () async {
        final newModel = DemoModel('John');

        await provider.upsert<DemoModel>(newModel);
        final doesExist = await provider.exists<DemoModel>();
        expect(doesExist, isTrue);
      });

      test('does not exist', () async {
        final doesExist = await provider.exists<DemoModel>(query: Query.where('name', 'Alice'));
        expect(doesExist, isFalse);
      });

      test('with an offset', () async {
        await provider.upsert<DemoModel>(DemoModel('John'));
        final existingModels = await provider.get<DemoModel>();
        final query = Query(providerArgs: {'limit': 1, 'offset': existingModels.length});

        final doesExistWithoutModel = await provider.exists<DemoModel>(query: query);
        expect(doesExistWithoutModel, isFalse);

        await provider.upsert<DemoModel>(DemoModel('John'));
        final doesExistWithModel = await provider.exists<DemoModel>(query: query);
        expect(doesExistWithModel, isTrue);
      });
    });

    group('#migrateFromStringToJoinsTable', () {
      final localTableName = 'User';
      final foreignTableName = 'Hat';
      final columnName = 'hats';
      final oldTable = [
        InsertTable(localTableName),
        InsertColumn(columnName, Column.varchar, onTable: localTableName),
        InsertTable(foreignTableName),
        InsertColumn('name', Column.varchar, onTable: foreignTableName),
      ];
      final joinsTableName =
          InsertForeignKey.joinsTableName(columnName, localTableName: localTableName);
      final joinsColumnLocal = SchemaColumn(
        InsertForeignKey.joinsTableLocalColumnName(localTableName),
        int,
        foreignTableName: localTableName,
        isForeignKey: true,
        onDeleteCascade: true,
      )..tableName = joinsTableName;
      final joinsColumnForeign = SchemaColumn(
        InsertForeignKey.joinsTableForeignColumnName(foreignTableName),
        int,
        isForeignKey: true,
        foreignTableName: foreignTableName,
        onDeleteCascade: true,
      )..tableName = joinsTableName;
      final table = [
        InsertTable(joinsTableName),
        joinsColumnLocal.toCommand(),
        joinsColumnForeign.toCommand(),
      ];

      test('migrates', () async {
        // setup
        for (var command in oldTable) {
          await provider.rawExecute(command.statement);
        }
        await provider.rawInsert('INSERT INTO `$foreignTableName` (name) VALUES ("Bowler")');
        await provider.rawInsert('INSERT INTO `$foreignTableName` (name) VALUES ("Big")');
        await provider.rawInsert(
            'INSERT OR IGNORE INTO `$localTableName` ($columnName) VALUES (?)', ['[1,2,3]']);
        for (var command in table) {
          await provider.rawExecute(command.statement);
        }

        // ignore: deprecated_member_use_from_same_package
        await provider.migrateFromStringToJoinsTable(columnName, localTableName, foreignTableName);

        final joinsResults = await provider.rawQuery('SELECT * FROM `$joinsTableName`');
        // only two becuase the third foreign key does not exist and therefore wasn't inserted
        expect(joinsResults, hasLength(2));
      });
    });
  });

  group('SqliteModel', () {
    test('#primaryKey', () {
      final m = DemoModel('Thomas');
      expect(m.primaryKey, NEW_RECORD_ID);

      m.primaryKey = 2;
      expect(m.primaryKey, 2);
    });

    test('#isNewRecord', () {
      final m = DemoModel('Thomas');
      expect(m.isNewRecord, isTrue);
    });

    test('#beforeSave', () {}, skip: 'add test');
    test('#afterSave', () {}, skip: 'add test');
  });

  group('SqliteAdapter', () {
    final a = DemoModelAdapter();

    test('#tableName', () {
      expect(a.tableName, sqliteTableName);
    });
  });
}
