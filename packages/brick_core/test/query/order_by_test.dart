import 'package:brick_core/src/query/order_by.dart';
import 'package:test/test.dart';

void main() {
  group('OrderBy', () {
    test('equality', () {
      expect(
        const OrderBy('name'),
        OrderBy.fromJson(const {'evaluatedField': 'name', 'ascending': true}),
      );
      expect(
        const OrderBy('name', ascending: false),
        OrderBy.fromJson(const {'evaluatedField': 'name', 'ascending': false}),
      );
    });

    test('#toJson', () {
      expect(
        const OrderBy('name').toJson(),
        {'evaluatedField': 'name', 'ascending': true},
      );
      expect(
        const OrderBy('name', ascending: false).toJson(),
        {'evaluatedField': 'name', 'ascending': false},
      );
    });

    test('#toString', () {
      expect(
        const OrderBy('name').toString(),
        'name ASC',
      );
      expect(
        const OrderBy('name', ascending: false).toString(),
        'name DESC',
      );
    });

    test('.asc', () {
      expect(OrderBy.asc('name'), const OrderBy('name'));
    });

    test('.desc', () {
      expect(OrderBy.asc('name'), const OrderBy('name', ascending: false));
    });

    test('.fromJson', () {
      expect(
        OrderBy.fromJson(const {'evaluatedField': 'name', 'ascending': true}),
        const OrderBy('name'),
      );
      expect(
        OrderBy.fromJson(const {'evaluatedField': 'name', 'ascending': false}),
        const OrderBy('name', ascending: false),
      );
    });
  });
}
