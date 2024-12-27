import 'package:brick_core/src/query/order_by.dart';
import 'package:test/test.dart';

void main() {
  group('OrderBy', () {
    test('equality', () {
      expect(
        const OrderBy('name', associationField: 'assoc'),
        OrderBy.fromJson(
          const {'evaluatedField': 'name', 'ascending': true, 'associationField': 'assoc'},
        ),
      );
      expect(
        const OrderBy('name', ascending: false, associationField: 'assoc'),
        OrderBy.fromJson(
          const {'evaluatedField': 'name', 'ascending': false, 'associationField': 'assoc'},
        ),
      );
    });

    test('#toJson', () {
      expect(
        const OrderBy('name').toJson(),
        {'evaluatedField': 'name', 'ascending': true},
      );
      expect(
        const OrderBy('name', ascending: false, associationField: 'assoc').toJson(),
        {'evaluatedField': 'name', 'ascending': false, 'associationField': 'assoc'},
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
      expect(
        const OrderBy('name', ascending: false, associationField: 'assoc').toString(),
        'name DESC',
      );
    });

    test('.asc', () {
      expect(const OrderBy.asc('name'), const OrderBy('name'));
      expect(
        const OrderBy.asc('name', associationField: 'assoc'),
        const OrderBy('name', associationField: 'assoc'),
      );
    });

    test('.desc', () {
      expect(const OrderBy.desc('name'), const OrderBy('name', ascending: false));
      expect(
        const OrderBy.desc('name', associationField: 'assoc'),
        const OrderBy('name', ascending: false, associationField: 'assoc'),
      );
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
      expect(
        OrderBy.fromJson(
          const {'evaluatedField': 'name', 'ascending': false, 'associationField': 'assoc'},
        ),
        const OrderBy('name', ascending: false, associationField: 'assoc'),
      );
    });
  });
}
