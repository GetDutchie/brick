import 'package:test/test.dart';

import '__mocks__/demo_model_adapter.dart';

void main() {
  group('SqliteAdapter', () {
    final a = DemoModelAdapter();

    test('#tableName', () {
      expect(a.tableName, 'DemoModel');
    });
  });
}
