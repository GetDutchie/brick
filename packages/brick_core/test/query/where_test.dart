import 'package:brick_core/src/query/where.dart';
import 'package:test/test.dart';

void main() {
  group('Where', () {
    test('#isExactly', () {
      expect(
        const Where('id').isExactly(1),
        const Where('id', value: 1, compare: Compare.exact, isRequired: true),
      );
    });

    test('#isBetween', () {
      expect(
        const Where('id').isBetween(1, 42),
        const Where('id', value: [1, 42], compare: Compare.between, isRequired: true),
      );
    });

    test('#contains', () {
      expect(
        const Where('id').contains(1),
        const Where('id', value: 1, compare: Compare.contains, isRequired: true),
      );
    });

    test('#doesNotContain', () {
      expect(
        const Where('id').doesNotContain(1),
        const Where('id', value: 1, compare: Compare.doesNotContain, isRequired: true),
      );
    });

    test('#isLessThan', () {
      expect(
        const Where('id').isLessThan(1),
        const Where('id', value: 1, compare: Compare.lessThan, isRequired: true),
      );
    });

    test('#isLessThanOrEqualTo', () {
      expect(
        const Where('id').isLessThanOrEqualTo(1),
        const Where('id', value: 1, compare: Compare.lessThanOrEqualTo, isRequired: true),
      );
    });

    test('#isGreaterThan', () {
      expect(
        const Where('id').isGreaterThan(1),
        const Where('id', value: 1, compare: Compare.greaterThan, isRequired: true),
      );
    });

    test('#isGreaterThanOrEqualTo', () {
      expect(
        const Where('id').isGreaterThanOrEqualTo(1),
        const Where('id', value: 1, compare: Compare.greaterThanOrEqualTo, isRequired: true),
      );
    });

    test('#isNot', () {
      expect(
        const Where('id').isNot(1),
        const Where('id', value: 1, compare: Compare.notEqual, isRequired: true),
      );
    });

    test('#isIn', () {
      expect(
        const Where('id').isIn([1, 2, 3]),
        const Where('id', value: [1, 2, 3], compare: Compare.inIterable, isRequired: true),
      );
    });

    test('#isIn with String', () {
      expect(
        const Where('name').isIn(['Alice', 'Bob']),
        const Where('name', value: ['Alice', 'Bob'], compare: Compare.inIterable, isRequired: true),
      );
    });
  });

  group('.byField', () {
    test('single field', () {
      final conditions = [const Where('id', value: 1), const Where('name', value: 'Thomas')];
      final result = Where.byField('id', conditions);
      expect(result, [const Where('id', value: 1)]);
    });

    test('nested fields', () {
      final conditions = <WhereCondition>[
        const WherePhrase([
          Where('id', value: 1),
          WherePhrase([
            Where('name', value: 'Thomas'),
          ]),
          Where('age', value: 42),
        ]),
        const Where('lastName', value: 'Guy'),
      ];
      expect(Where.byField('id', conditions).first.value, 1);
      expect(Where.byField('name', conditions).first.value, 'Thomas');
      expect(Where.byField('age', conditions).first.value, 42);
    });
  });

  group('.firstByField', () {
    test('single field', () {
      final conditions = [const Where.exact('id', 1), const Where.exact('name', 'Thomas')];
      final result = Where.firstByField('id', conditions);
      expect(result, conditions.first);
    });

    test('nested field', () {
      final conditions = [const Where('id', value: Where('name', value: 'Thomas'))];
      final topLevelResult = Where.firstByField('id', conditions);
      final result = Where.firstByField('name', [topLevelResult!.value]);
      expect(result!.value, 'Thomas');
    });
  });

  group('WhereCondition', () {
    test('#toJson', () {
      const where = Where('id', value: 1);
      expect(where.toJson(), {
        'subclass': 'Where',
        'evaluatedField': 'id',
        'compare': 0,
        'required': true,
        'value': 1,
      });

      const phrase = WherePhrase([Where('id', value: 1)]);
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
        'required': false,
      });
    });
  });
}
