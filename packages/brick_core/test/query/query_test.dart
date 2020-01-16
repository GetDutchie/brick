import 'package:test/test.dart';
import 'package:brick_core/src/query/query.dart';
import 'package:brick_core/src/query/where.dart';

void main() {
  group('Query', () {
    group('properties', () {
      test('#action', () {
        final q = Query(action: QueryAction.delete);
        expect(q.action, QueryAction.delete);
      });

      group('#params', () {
        test('#params.page and #params.sort', () {
          final q = Query(params: {'page': 1, 'sort': 'by_user_asc'});

          expect(q.params['page'], 1);
          expect(q.params['sort'], 'by_user_asc');
        });

        test('#params.limit', () {
          final q0 = Query(params: {'limit': 0});
          expect(q0.params['limit'], 0);

          final q10 = Query(params: {'limit': 10});
          expect(q10.params['limit'], 10);

          final q18 = Query(params: {'limit': 18});
          expect(q18.params['limit'], 18);

          expect(() => Query(params: {'limit': -1}), throwsA(TypeMatcher<AssertionError>()));
        });

        test('#params.offset', () {
          final q0 = Query(params: {'limit': 10, 'offset': 0});
          expect(q0.params['offset'], 0);

          final q10 = Query(params: {'limit': 10, 'offset': 10});
          expect(q10.params['offset'], 10);

          final q18 = Query(params: {'limit': 10, 'offset': 18});
          expect(q18.params['offset'], 18);

          expect(() => Query(params: {'offset': -1}), throwsA(TypeMatcher<AssertionError>()));

          expect(() => Query(params: {'offset': 1}), throwsA(TypeMatcher<AssertionError>()));
        });
      });

      test('#where', () {
        final q = Query(where: [
          Where('name', ofValue: 'Thomas'),
        ]);

        expect(q.where.first.evaluatedField, 'name');
        expect(q.where.first.value, 'Thomas');
      });
    });

    group('==', () {
      test('properties are the same', () {
        final q1 = Query(
          action: QueryAction.delete,
          params: {
            'limit': 3,
            'offset': 3,
          },
        );
        final q2 = Query(
          action: QueryAction.delete,
          params: {
            'limit': 3,
            'offset': 3,
          },
        );

        expect(q1, q2);
      });

      test('params are the same', () {
        final q1 = Query(params: {'name': 'Guy'});
        final q2 = Query(params: {'name': 'Guy'});

        expect(q1, q2);
      });

      test('params have different values', () {
        final q1 = Query(params: {'name': 'Thomas'});
        final q2 = Query(params: {'name': 'Guy'});

        expect(q1, isNot(q2));
      });

      test('params have different keys', () {
        final q1 = Query(params: {'email': 'guy@guy.com'});
        final q2 = Query(params: {'name': 'Guy'});

        expect(q1, isNot(q2));
      });

      test('params are null', () {
        final q1 = Query();
        final q2 = Query(params: {'name': 'Guy'});
        expect(q1, isNot(q2));

        final q3 = Query();
        expect(q1, q3);
      });
    });

    group('#copyWith', () {
      test('overrides', () {
        final q1 = Query(action: QueryAction.insert, params: {'limit': 10, 'offset': 10});
        final q2 = q1.copyWith(params: {'limit': 20});
        expect(q2.action, QueryAction.insert);
        expect(q2.params['limit'], 20);
        expect(q2.params['offset'], null);

        final q3 = q1.copyWith(params: {'limit': 50, 'offset': 20});
        expect(q3.action, QueryAction.insert);
        expect(q3.params['limit'], 50);
        expect(q3.params['offset'], 20);
      });

      test('appends', () {
        final q1 = Query(action: QueryAction.insert);
        final q2 = q1.copyWith(params: {'limit': 20});

        expect(q1.params['limit'], null);
        expect(q2.action, QueryAction.insert);
        expect(q2.params['limit'], 20);
      });
    });

    test('#toJson', () {
      final source = Query(
        action: QueryAction.update,
        params: {
          'limit': 3,
          'offset': 3,
        },
      );

      expect(
        source.toJson(),
        {
          'action': 2,
          'params': {
            'limit': 3,
            'offset': 3,
          },
        },
      );
    });

    group("factories", () {
      test('.fromJson', () {
        final json = {
          'action': 2,
          'params': {
            'limit': 3,
            'offset': 3,
          },
        };

        final result = Query.fromJson(json);
        expect(
          result,
          Query(
            action: QueryAction.update,
            params: {
              'limit': 3,
              'offset': 3,
            },
          ),
        );
      });

      group('.where', () {
        test("required arguments", () {
          final expandedQuery = Query(where: [Where('id', ofValue: 2)]);
          final factoried = Query.where('id', 2);
          expect(factoried, expandedQuery);
          expect(Where.firstByField('id', factoried.where).value, 2);
          expect(factoried.unlimited, isTrue);
        });

        test("limit1:true", () {
          final expandedQuery = Query(where: [Where('id', ofValue: 2)], params: {'limit': 1});
          final factoried = Query.where('id', 2, limit1: true);
          expect(factoried, expandedQuery);
          expect(factoried.unlimited, isFalse);
        });
      });
    });
  });
}
