import 'package:brick_core/src/query/where.dart';
import "package:test/test.dart";

void main() {
  group("Where", () {
    group("subclass shortcuts", () {
      test("And", () {
        expect(
          And('id', 1),
          Where('id', 1, required: true),
        );
      });

      test("Or", () {
        expect(
          Or('id', 1),
          Where('id', 1, required: false),
        );
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
