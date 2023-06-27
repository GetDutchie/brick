import 'package:brick_core/src/query/where.dart';
import 'package:test/test.dart';

void main() {
  group('Where', () {
    test('#isExactly', () {
      expect(
        Where('id').isExactly(1),
        Where('id', value: 1, compare: Compare.exact, isRequired: true),
      );
    });

    test('#isBetween', () {
      expect(
        Where('id').isBetween(1, 42),
        Where('id', value: [1, 42], compare: Compare.between, isRequired: true),
      );
    });

    test('#contains', () {
      expect(
        Where('id').contains(1),
        Where('id', value: 1, compare: Compare.contains, isRequired: true),
      );
    });

    test('#doesNotContain', () {
      expect(
        Where('id').doesNotContain(1),
        Where('id', value: 1, compare: Compare.doesNotContain, isRequired: true),
      );
    });

    test('#isLessThan', () {
      expect(
        Where('id').isLessThan(1),
        Where('id', value: 1, compare: Compare.lessThan, isRequired: true),
      );
    });

    test('#isLessThanOrEqualTo', () {
      expect(
        Where('id').isLessThanOrEqualTo(1),
        Where('id', value: 1, compare: Compare.lessThanOrEqualTo, isRequired: true),
      );
    });

    test('#isGreaterThan', () {
      expect(
        Where('id').isGreaterThan(1),
        Where('id', value: 1, compare: Compare.greaterThan, isRequired: true),
      );
    });

    test('#isGreaterThanOrEqualTo', () {
      expect(
        Where('id').isGreaterThanOrEqualTo(1),
        Where('id', value: 1, compare: Compare.greaterThanOrEqualTo, isRequired: true),
      );
    });

    test('#isNot', () {
      expect(
        Where('id').isNot(1),
        Where('id', value: 1, compare: Compare.notEqual, isRequired: true),
      );
    });
  });

  group('.byField', () {
    test('single field', () {
      final conditions = [Where('id', value: 1), Where('name', value: 'Thomas')];
      final result = Where.byField('id', conditions);
      expect(result, [Where('id', value: 1)]);
    });

    test('nested fields', () {
      final conditions = <WhereCondition>[
        WherePhrase([
          Where('id', value: 1),
          WherePhrase([
            Where('name', value: 'Thomas'),
          ]),
          Where('age', value: 42),
        ]),
        Where('lastName', value: 'Guy'),
      ];
      expect(Where.byField('id', conditions).first.value, 1);
      expect(Where.byField('name', conditions).first.value, 'Thomas');
      expect(Where.byField('age', conditions).first.value, 42);
    });
  });

  group('.firstByField', () {
    test('single field', () {
      final conditions = [Where.exact('id', 1), Where.exact('name', 'Thomas')];
      final result = Where.firstByField('id', conditions);
      expect(result, conditions.first);
    });

    test('nested field', () {
      final conditions = [Where('id', value: Where('name', value: 'Thomas'))];
      final topLevelResult = Where.firstByField('id', conditions);
      final result = Where.firstByField('name', [topLevelResult!.value]);
      expect(result!.value, 'Thomas');
    });
  });

  group('WhereCondition', () {
    test('#toJson', () {
      final where = Where('id', value: 1);
      expect(where.toJson(), {
        'subclass': 'Where',
        'evaluatedField': 'id',
        'compare': 0,
        'required': true,
        'value': 1,
      });

      final phrase = WherePhrase([Where('id', value: 1)]);
      expect(phrase.toJson(), {
        'subclass': 'WherePhrase',
        'compare': 0,
        'conditions': [
          {
            'subclass': 'Where',
            'evaluatedField': 'id',
            'compare': 0,
            'required': true,
            'value': 1,
          }
        ],
        'required': false
      });
    });
  });
}
