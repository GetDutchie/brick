import 'package:brick_rest/src/rest_adapter.dart';
import 'package:test/test.dart';

enum _MockEnum { a, b, c, d }

void main() {
  group('RestAdapter', () {
    test('.firstWhereOrNull', () {
      final items = ['a', 'b', 'c', 'd'];
      expect(RestAdatper.firstWhereOrNull<String>(items, (i) => i == 'c'), 'c');
      expect(RestAdatper.firstWhereOrNull<String>(items, (i) => i == 'e'), isNull);
    });

    test('.enumValueFromName', () {
      expect(RestAdatper.enumValueFromName<_MockEnum>(_MockEnum.values, 'b'), _MockEnum.b);
      expect(RestAdatper.enumValueFromName<_MockEnum>(_MockEnum.values, 'e'), isNull);
    });
  });
}
