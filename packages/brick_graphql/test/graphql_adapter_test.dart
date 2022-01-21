import 'package:brick_graphql/src/graphql_adapter.dart';
import 'package:test/test.dart';

enum _MockEnum { a, b, c, d }

void main() {
  group('GraphQLAdapter', () {
    test('.firstWhereOrNull', () {
      final items = ['a', 'b', 'c', 'd'];
      expect(GraphQLAdapter.firstWhereOrNull<String>(items, (i) => i == 'c'), 'c');
      expect(GraphQLAdapter.firstWhereOrNull<String>(items, (i) => i == 'e'), isNull);
    });

    test('.enumValueFromName', () {
      expect(GraphQLAdapter.enumValueFromName<_MockEnum>(_MockEnum.values, 'b'), _MockEnum.b);
      expect(GraphQLAdapter.enumValueFromName<_MockEnum>(_MockEnum.values, 'e'), isNull);
    });
  });
}
