import 'package:brick_graphql/src/graphql_adapter.dart';
import 'package:test/test.dart';

enum _MockEnum { a, b, c, d }

void main() {
  group('GraphqlAdapter', () {
    test('.firstWhereOrNull', () {
      final items = ['a', 'b', 'c', 'd'];
      expect(GraphqlAdapter.firstWhereOrNull<String>(items, (i) => i == 'c'), 'c');
      expect(GraphqlAdapter.firstWhereOrNull<String>(items, (i) => i == 'e'), isNull);
    });

    test('.enumValueFromName', () {
      expect(GraphqlAdapter.enumValueFromName<_MockEnum>(_MockEnum.values, 'b'), _MockEnum.b);
      expect(GraphqlAdapter.enumValueFromName<_MockEnum>(_MockEnum.values, 'e'), isNull);
    });
  });
}
