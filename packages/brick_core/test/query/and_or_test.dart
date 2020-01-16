import 'package:brick_core/src/query/where.dart';
import 'package:brick_core/src/query/and_or.dart';
import "package:test/test.dart";

void main() {
  group("WhereConvenienceInterface", () {
    test("#isExactly", () {
      expect(And('id').isExactly(1), Where('id', 1, compare: Compare.exact, required: true));
      expect(Or('id').isExactly(1), Where('id', 1, compare: Compare.exact, required: false));
    });

    test("#isBetween", () {
      expect(And('id').isBetween(1, 42),
          Where('id', [1, 42], compare: Compare.between, required: true));
      expect(Or('id').isBetween(1, 42),
          Where('id', [1, 42], compare: Compare.between, required: false));
    });

    test("#contains", () {
      expect(And('id').contains(1), Where('id', 1, compare: Compare.contains, required: true));
      expect(Or('id').contains(1), Where('id', 1, compare: Compare.contains, required: false));
    });

    test("#isLessThan", () {
      expect(And('id').isLessThan(1), Where('id', 1, compare: Compare.lessThan, required: true));
      expect(Or('id').isLessThan(1), Where('id', 1, compare: Compare.lessThan, required: false));
    });

    test("#isLessThanOrEqualTo", () {
      expect(And('id').isLessThanOrEqualTo(1),
          Where('id', 1, compare: Compare.lessThanOrEqualTo, required: true));
      expect(Or('id').isLessThanOrEqualTo(1),
          Where('id', 1, compare: Compare.lessThanOrEqualTo, required: false));
    });

    test("#isGreaterThan", () {
      expect(
          And('id').isGreaterThan(1), Where('id', 1, compare: Compare.greaterThan, required: true));
      expect(
          Or('id').isGreaterThan(1), Where('id', 1, compare: Compare.greaterThan, required: false));
    });

    test("#isGreaterThanOrEqualTo", () {
      expect(And('id').isGreaterThanOrEqualTo(1),
          Where('id', 1, compare: Compare.greaterThanOrEqualTo, required: true));
      expect(Or('id').isGreaterThanOrEqualTo(1),
          Where('id', 1, compare: Compare.greaterThanOrEqualTo, required: false));
    });

    test("#isNot", () {
      expect(And('id').isNot(1), Where('id', 1, compare: Compare.notEqual, required: true));
      expect(Or('id').isNot(1), Where('id', 1, compare: Compare.notEqual, required: false));
    });
  });

  test("AndPhrase", () {
    expect(AndPhrase([]), WherePhrase([], required: true));
  });

  test("OrPhrase", () {
    expect(OrPhrase([]), WherePhrase([], required: false));
  });
}
