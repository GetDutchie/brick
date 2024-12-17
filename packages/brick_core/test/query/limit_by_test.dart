import 'package:brick_core/src/query/limit_by.dart';
import 'package:test/test.dart';

void main() {
  group('LimitBy', () {
    test('equality', () {
      expect(
        const LimitBy(2, model: num),
        LimitBy.fromJson(const {'amount': 2, 'model': num}),
      );
    });

    test('#toJson', () {
      expect(
        const LimitBy(2, model: int).toJson(),
        {'amount': 2, 'model': int},
      );
      expect(
        const LimitBy(2, model: String).toJson(),
        {'amount': 2, 'model': String},
      );
    });

    test('.fromJson', () {
      expect(
        LimitBy.fromJson(const {'amount': 2, 'model': String}),
        const LimitBy(2, model: String),
      );
    });
  });
}
