import 'package:brick_core/src/query/and_or.dart';
import 'package:brick_core/src/query/where.dart';
import 'package:test/test.dart';

void main() {
  group('WhereConvenienceInterface', () {
    test('#isExactly', () {
      expect(
        const And('id').isExactly(1),
        const Where('id', value: 1, compare: Compare.exact, isRequired: true),
      );
      expect(
        const Or('id').isExactly(1),
        const Where('id', value: 1, compare: Compare.exact, isRequired: false),
      );
    });

    test('#isBetween', () {
      expect(
        const And('id').isBetween(1, 42),
        const Where('id', value: [1, 42], compare: Compare.between, isRequired: true),
      );
      expect(
        const Or('id').isBetween(1, 42),
        const Where('id', value: [1, 42], compare: Compare.between, isRequired: false),
      );
    });

    test('#contains', () {
      expect(
        const And('id').contains(1),
        const Where('id', value: 1, compare: Compare.contains, isRequired: true),
      );
      expect(
        const Or('id').contains(1),
        const Where('id', value: 1, compare: Compare.contains, isRequired: false),
      );
    });

    test('#doesNotContain', () {
      expect(
        const And('id').doesNotContain(1),
        const Where('id', value: 1, compare: Compare.doesNotContain, isRequired: true),
      );
      expect(
        const Or('id').doesNotContain(1),
        const Where('id', value: 1, compare: Compare.doesNotContain, isRequired: false),
      );
    });

    test('#isLessThan', () {
      expect(
        const And('id').isLessThan(1),
        const Where('id', value: 1, compare: Compare.lessThan, isRequired: true),
      );
      expect(
        const Or('id').isLessThan(1),
        const Where('id', value: 1, compare: Compare.lessThan, isRequired: false),
      );
    });

    test('#isLessThanOrEqualTo', () {
      expect(
        const And('id').isLessThanOrEqualTo(1),
        const Where('id', value: 1, compare: Compare.lessThanOrEqualTo, isRequired: true),
      );
      expect(
        const Or('id').isLessThanOrEqualTo(1),
        const Where('id', value: 1, compare: Compare.lessThanOrEqualTo, isRequired: false),
      );
    });

    test('#isGreaterThan', () {
      expect(
        const And('id').isGreaterThan(1),
        const Where('id', value: 1, compare: Compare.greaterThan, isRequired: true),
      );
      expect(
        const Or('id').isGreaterThan(1),
        const Where('id', value: 1, compare: Compare.greaterThan, isRequired: false),
      );
    });

    test('#isGreaterThanOrEqualTo', () {
      expect(
        const And('id').isGreaterThanOrEqualTo(1),
        const Where('id', value: 1, compare: Compare.greaterThanOrEqualTo, isRequired: true),
      );
      expect(
        const Or('id').isGreaterThanOrEqualTo(1),
        const Where('id', value: 1, compare: Compare.greaterThanOrEqualTo, isRequired: false),
      );
    });

    test('#isNot', () {
      expect(
        const And('id').isNot(1),
        const Where('id', value: 1, compare: Compare.notEqual, isRequired: true),
      );
      expect(
        const Or('id').isNot(1),
        const Where('id', value: 1, compare: Compare.notEqual, isRequired: false),
      );
    });
  });
}
