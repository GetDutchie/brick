import 'package:flutter_test/flutter_test.dart';
import 'package:test/test.dart' show TypeMatcher;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'helpers/__mocks__.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  group('OfflineFirstAdapter', () {
    test('instantiates', () {
      final m = MountyAdapter();
      expect(m, const TypeMatcher<MountyAdapter>());
      expect(m.tableName, 'Mounty');
    });
  });
}
