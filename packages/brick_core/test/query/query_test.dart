// ignore_for_file: deprecated_member_use_from_same_package

import 'package:brick_core/src/query/query.dart';
import 'package:brick_core/src/query/where.dart';
import 'package:test/test.dart';

void main() {
  group('Query', () {
    test('#action', () {
      const q = Query(action: QueryAction.delete);
      expect(q.action, QueryAction.delete);
    });

    test('#limit', () {
      const q0 = Query(limit: 0);
      expect(q0.limit, 0);

      const q10 = Query(limit: 10);
      expect(q10.limit, 10);

      const q18 = Query(limit: 18);
      expect(q18.limit, 18);
    });

    test('#offset', () {
      const q0 = Query(limit: 10, offset: 0);
      expect(q0.offset, 0);

      const q10 = Query(limit: 10, offset: 10);
      expect(q10.offset, 10);

      const q18 = Query(limit: 10, offset: 18);
      expect(q18.offset, 18);
    });

    test('#where', () {
      const q = Query(
        where: [
          Where('name', value: 'Thomas'),
        ],
      );

      expect(q.where!.first.evaluatedField, 'name');
      expect(q.where!.first.value, 'Thomas');
    });
  });

  group('==', () {
    test('properties are the same', () {
      const q1 = Query(
        action: QueryAction.delete,
        limit: 3,
        offset: 3,
      );
      const q2 = Query(
        action: QueryAction.delete,
        limit: 3,
        offset: 3,
      );

      expect(q1, q2);
    });

    test('where args are the same', () {
      final q1 = Query.where('name', 'Guy');
      final q2 = Query.where('name', 'Guy');

      expect(q1, q2);
    });

    test('where args have different values', () {
      final q1 = Query.where('name', 'Thomas');
      final q2 = Query.where('name', 'Guy');

      expect(q1, isNot(q2));
    });

    test('where args have different keys', () {
      final q1 = Query.where('email', 'guy@guy.com');
      final q2 = Query.where('name', 'Guy');

      expect(q1, isNot(q2));
    });

    test('where args are null', () {
      const q1 = Query();
      final q2 = Query.where('name', 'Guy');
      expect(q1, isNot(q2));

      const q3 = Query();
      expect(q1, q3);
    });
  });

  group('#copyWith', () {
    test('overrides', () {
      const q1 = Query(action: QueryAction.insert, limit: 10);
      final q2 = q1.copyWith(limit: 20);
      expect(q2.action, QueryAction.insert);
      expect(q2.limit, 20);
      expect(q2.offset, null);

      final q3 = q1.copyWith(limit: 50, offset: 20);
      expect(q3.action, QueryAction.insert);
      expect(q3.limit, 50);
      expect(q3.offset, 20);
    });

    test('appends', () {
      const q1 = Query(action: QueryAction.insert);
      final q2 = q1.copyWith(limit: 20);

      expect(q1.limit, null);
      expect(q2.action, QueryAction.insert);
      expect(q2.limit, 20);
    });
  });

  test('#toJson', () {
    const source = Query(
      action: QueryAction.update,
      limit: 3,
      offset: 3,
    );

    expect(
      source.toJson(),
      {
        'action': 2,
        'limit': 3,
        'offset': 3,
      },
    );
  });

  test('.fromJson', () {
    final json = {
      'action': 2,
      'limit': 3,
      'offset': 3,
    };

    final result = Query.fromJson(json);
    expect(
      result,
      const Query(
        action: QueryAction.update,
        limit: 3,
        offset: 3,
      ),
    );
  });

  group('.where', () {
    test('required arguments', () {
      const expandedQuery = Query(where: [Where('id', value: 2)]);
      final factoried = Query.where('id', 2);
      expect(factoried, expandedQuery);
      expect(Where.firstByField('id', factoried.where)!.value, 2);
      expect(factoried.unlimited, isTrue);
    });

    test('limit1:true', () {
      const expandedQuery = Query(where: [Where('id', value: 2)], limit: 1);
      final factoried = Query.where('id', 2, limit1: true);
      expect(factoried, expandedQuery);
      expect(factoried.unlimited, isFalse);
    });
  });
}
