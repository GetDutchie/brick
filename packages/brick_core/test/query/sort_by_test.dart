// ignore_for_file: deprecated_member_use_from_same_package

import 'package:brick_core/src/query/sort_by.dart';
import 'package:test/test.dart';

void main() {
  group('SortBy', () {
    test('equality', () {
      expect(
        const SortBy('name', ascending: true),
        SortBy.fromJson({'evaluatedField': 'name', 'ascending': true}),
      );
      expect(
        const SortBy('name', ascending: false),
        SortBy.fromJson({'evaluatedField': 'name', 'ascending': false}),
      );
    });

    test('#toJson', () {
      expect(
        const SortBy('name', ascending: true).toJson(),
        {'evaluatedField': 'name', 'ascending': true},
      );
      expect(
        const SortBy('name', ascending: false).toJson(),
        {'evaluatedField': 'name', 'ascending': false},
      );
    });

    test('#toString', () {
      expect(
        const SortBy('name', ascending: true).toString(),
        'evaluatedField ASC',
      );
      expect(
        const SortBy('name', ascending: false).toString(),
        'evaluatedField DESC',
      );
    });

    test('.fromJson', () {
      expect(
        SortBy.fromJson({'evaluatedField': 'name', 'ascending': true}),
        const SortBy('name', ascending: true),
      );
      expect(
        SortBy.fromJson({'evaluatedField': 'name', 'ascending': false}),
        const SortBy('name', ascending: false),
      );
    });
  });
}
