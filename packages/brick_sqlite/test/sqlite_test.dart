import 'package:brick_sqlite_abstract/db.dart';
import 'package:brick_sqlite_abstract/sqlite_model.dart';
import 'package:brick_sqlite/sqlite.dart';
import 'package:brick_sqlite/testing.dart';
import 'package:test/test.dart';
import 'package:flutter_test/flutter_test.dart' as ft;

import '__mocks__.dart';

void main() {
  ft.TestWidgetsFlutterBinding.ensureInitialized();

  group("SqliteProvider", () {
    final provider = SqliteProvider('db.sqlite', modelDictionary: dictionary);
    final List<Map<String, dynamic>> responses = [
      {InsertTable.PRIMARY_KEY_COLUMN: 1, 'name': 'Thomas'},
      {InsertTable.PRIMARY_KEY_COLUMN: 2, 'name': 'Guy'},
      {'name': 'John'}
    ];

    setUpAll(() {
      StubSqlite(provider, responses: {
        DemoModel: responses,
      });
    });

    test("#get", () async {
      final models = await provider.get<DemoModel>();
      expect(models, hasLength(3));
    });

    group("#upsert", () {
      test("insert", () async {
        final newModel = DemoModel("John");

        final newPrimaryKey = await provider.upsert<DemoModel>(newModel);
        expect(newPrimaryKey, responses.length + 1);
      });

      test("update", () async {
        final newModel = DemoModel("Guy")..primaryKey = 2;

        final primaryKey = await provider.upsert<DemoModel>(newModel);
        expect(primaryKey, 2);
      });
    });

    test("#delete", () {}, skip: "Write delete test");

    test('#migrate', () {}, skip: 'Write test');

    test("#exists", () {}, skip: 'Write test');
  });

  group("SqliteModel", () {
    test("#primaryKey", () {
      final m = DemoModel('Thomas');
      expect(m.primaryKey, NEW_RECORD_ID);

      m.primaryKey = 2;
      expect(m.primaryKey, 2);
    });

    test("#isNewRecord", () {
      final m = DemoModel('Thomas');
      expect(m.isNewRecord, isTrue);
    });

    test("#beforeSave", () {}, skip: "add test");
    test("#afterSave", () {}, skip: "add test");
  });

  group("SqliteAdapter", () {
    final a = DemoModelAdapter();

    test("#tableName", () {
      expect(a.tableName, sqliteTableName);
    });
  });
}
