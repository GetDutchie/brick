import 'package:brick_core/src/query/limit_by.dart';
import 'package:test/test.dart';

void main() {
  group('LimitBy', () {
    test('equality', () {
      expect(
        const LimitBy(2, evaluatedField: 'name'),
        LimitBy.fromJson(const {'amount': 2, 'evaluatedField': 'name'}),
      );
    });

    test('#toJson', () {
      expect(
        const LimitBy(2, evaluatedField: 'name').toJson(),
        {'amount': 2, 'evaluatedField': 'name'},
      );
    });

    test('.fromJson', () {
      expect(
        LimitBy.fromJson(const {'amount': 2, 'evaluatedField': 'longerName'}),
        const LimitBy(2, evaluatedField: 'longerName'),
      );
    });
  });
}
