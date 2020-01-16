import 'package:brick_core/src/query/where.dart';
import 'package:brick_core/src/query/and_or.dart';
import "package:test/test.dart";

void main() {
  group("Where", () {
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
        expect(And('id').isGreaterThan(1),
            Where('id', 1, compare: Compare.greaterThan, required: true));
        expect(Or('id').isGreaterThan(1),
            Where('id', 1, compare: Compare.greaterThan, required: false));
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

    group(".byField", () {
      test("single field", () {
        final conditions = [Where("id", 1), Where("name", "Thomas")];
        final result = Where.byField("id", conditions);
        expect(result, [Where("id", 1)]);
      });

      test("nested fields", () {
        final conditions = <WhereCondition>[
          WherePhrase([
            Where("id", 1),
            WherePhrase([
              Where("name", "Thomas"),
            ]),
            Where("age", 42),
          ]),
          Where("lastName", "Guy"),
        ];
        expect(Where.byField("id", conditions).first.value, 1);
        expect(Where.byField("name", conditions).first.value, "Thomas");
        expect(Where.byField("age", conditions).first.value, 42);
      });
    });

    group(".firstByField", () {
      test("single field", () {
        final conditions = [Where("id", 1), Where("name", "Thomas")];
        final result = Where.firstByField("id", conditions);
        expect(result, conditions.first);
      });

      test("nested field", () {
        final conditions = [Where("id", Where("name", "Thomas"))];
        final topLevelResult = Where.firstByField("id", conditions);
        final result = Where.firstByField("name", [topLevelResult.value]);
        expect(result.value, "Thomas");
      });
    });
  });

  group("WhereCondition", () {
    test("#toJson", () {
      final where = Where("id", 1);
      expect(where.toJson(), {
        "subclass": "Where",
        "evaluatedField": "id",
        "compare": 0,
        "required": true,
        "value": 1,
      });

      final phrase = WherePhrase([Where("id", 1)]);
      expect(phrase.toJson(), {
        "subclass": "WherePhrase",
        "compare": 0,
        "conditions": [
          {
            "subclass": "Where",
            "evaluatedField": "id",
            "compare": 0,
            "required": true,
            "value": 1,
          }
        ],
        "required": false
      });
    });
  });
}
