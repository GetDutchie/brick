import 'package:brick_core/src/query/where.dart';
import 'package:brick_core/src/query/and_or.dart';
import 'package:test/test.dart';

void main() {
  group('WhereConvenienceInterface', () {
    test('#isExactly', () {
      expect(
          And('id').isExactly(1), Where('id', value: 1, compare: Compare.exact, isRequired: true));
      expect(
          Or('id').isExactly(1), Where('id', value: 1, compare: Compare.exact, isRequired: false));
    });

    test('#isBetween', () {
      expect(And('id').isBetween(1, 42),
          Where('id', value: [1, 42], compare: Compare.between, isRequired: true));
      expect(Or('id').isBetween(1, 42),
          Where('id', value: [1, 42], compare: Compare.between, isRequired: false));
    });

    test('#contains', () {
      expect(And('id').contains(1),
          Where('id', value: 1, compare: Compare.contains, isRequired: true));
      expect(Or('id').contains(1),
          Where('id', value: 1, compare: Compare.contains, isRequired: false));
    });

    test('#doesNotContain', () {
      expect(And('id').doesNotContain(1),
          Where('id', value: 1, compare: Compare.doesNotContain, isRequired: true));
      expect(Or('id').doesNotContain(1),
          Where('id', value: 1, compare: Compare.doesNotContain, isRequired: false));
    });

    test('#isLessThan', () {
      expect(And('id').isLessThan(1),
          Where('id', value: 1, compare: Compare.lessThan, isRequired: true));
      expect(Or('id').isLessThan(1),
          Where('id', value: 1, compare: Compare.lessThan, isRequired: false));
    });

    test('#isLessThanOrEqualTo', () {
      expect(And('id').isLessThanOrEqualTo(1),
          Where('id', value: 1, compare: Compare.lessThanOrEqualTo, isRequired: true));
      expect(Or('id').isLessThanOrEqualTo(1),
          Where('id', value: 1, compare: Compare.lessThanOrEqualTo, isRequired: false));
    });

    test('#isGreaterThan', () {
      expect(And('id').isGreaterThan(1),
          Where('id', value: 1, compare: Compare.greaterThan, isRequired: true));
      expect(Or('id').isGreaterThan(1),
          Where('id', value: 1, compare: Compare.greaterThan, isRequired: false));
    });

    test('#isGreaterThanOrEqualTo', () {
      expect(And('id').isGreaterThanOrEqualTo(1),
          Where('id', value: 1, compare: Compare.greaterThanOrEqualTo, isRequired: true));
      expect(Or('id').isGreaterThanOrEqualTo(1),
          Where('id', value: 1, compare: Compare.greaterThanOrEqualTo, isRequired: false));
    });

    test('#isNot', () {
      expect(
          And('id').isNot(1), Where('id', value: 1, compare: Compare.notEqual, isRequired: true));
      expect(
          Or('id').isNot(1), Where('id', value: 1, compare: Compare.notEqual, isRequired: false));
    });
  });
}
