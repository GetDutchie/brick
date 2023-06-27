import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:test/test.dart';

import 'helpers/__mocks__.dart';

void main() {
  sqfliteFfiInit();

  group('OfflineFirstModel', () {
    test('instantiates', () {
      final m = Mounty(name: 'Thomas');
      expect(m, const TypeMatcher<Mounty>());
    });
  });
}
