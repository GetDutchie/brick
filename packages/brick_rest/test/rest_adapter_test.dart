import 'package:brick_rest/src/rest_adapter.dart';
import 'package:test/test.dart';

void main() {
  group('RestAdapter', () {
    test('.firstWhereOrNull', () {
      final items = ['a', 'b', 'c', 'd'];
      expect(RestAdapter.firstWhereOrNull<String>(items, (i) => i == 'c'), 'c');
      expect(RestAdapter.firstWhereOrNull<String>(items, (i) => i == 'e'), isNull);
    });
  });
}
