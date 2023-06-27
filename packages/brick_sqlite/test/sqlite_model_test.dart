import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:test/test.dart';

import '__mocks__.dart';

void main() {
  sqfliteFfiInit();

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
}
