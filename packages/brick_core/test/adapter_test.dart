import 'package:test/test.dart';
import '__mocks__.dart';

enum _MockEnum { a, b, c, d }

void main() {
  group('Adapter', () {
    test('.firstWhereOrNull', () {
      final items = ['a', 'b', 'c', 'd'];
      expect(Adapter.firstWhereOrNull<String>(items, (i) => i == 'c'), 'c');
      expect(Adapter.firstWhereOrNull<String>(items, (i) => i == 'e'), isNull);
    });

    test('.enumValueFromName', () {
      expect(Adapter.enumValueFromName<_MockEnum>(_MockEnum.values, 'b'), _MockEnum.b);
      expect(Adapter.enumValueFromName<_MockEnum>(_MockEnum.values, 'e'), isNull);
    });
  });
}
