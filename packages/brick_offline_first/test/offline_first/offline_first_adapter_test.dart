import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:test/test.dart';

import 'helpers/__mocks__.dart';

void main() {
  sqfliteFfiInit();

  group('OfflineFirstAdapter', () {
    test('instantiates', () {
      final m = MountyAdapter();
      expect(m, const TypeMatcher<MountyAdapter>());
      expect(m.tableName, 'Mounty');
    });
  });
}
