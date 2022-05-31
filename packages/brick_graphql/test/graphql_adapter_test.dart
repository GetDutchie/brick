import 'package:brick_graphql/src/graphql_adapter.dart';
import 'package:test/test.dart';

void main() {
  group('GraphqlAdapter', () {
    test('.firstWhereOrNull', () {
      final items = ['a', 'b', 'c', 'd'];
      expect(GraphqlAdapter.firstWhereOrNull<String>(items, (i) => i == 'c'), 'c');
      expect(GraphqlAdapter.firstWhereOrNull<String>(items, (i) => i == 'e'), isNull);
    });
  });
}
