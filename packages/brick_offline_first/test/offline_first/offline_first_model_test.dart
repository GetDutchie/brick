import 'package:flutter_test/flutter_test.dart';
import 'package:test/test.dart' show TypeMatcher;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'helpers/__mocks__.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  group('OfflineFirstModel', () {
    test('instantiates', () {
      final m = Mounty(name: 'Thomas');
      expect(m, const TypeMatcher<Mounty>());
    });
  });
}
