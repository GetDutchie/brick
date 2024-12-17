import 'package:brick_sqlite/src/db/column.dart';
import 'package:test/test.dart';

void main() {
  group('Column', () {
    test('#definition', () {
      expect(Column.bigint.definition, 'BIGINT');
      expect(Column.blob.definition, 'BLOB');
      expect(Column.boolean.definition, 'BOOLEAN');
      expect(Column.date.definition, 'DATE');
      expect(Column.datetime.definition, 'DATETIME');
      expect(Column.Double.definition, 'DOUBLE');
      expect(Column.integer.definition, 'INTEGER');
      expect(Column.float.definition, 'FLOAT');
      expect(Column.num.definition, 'DOUBLE');
      expect(Column.text.definition, 'TEXT');
      expect(Column.varchar.definition, 'VARCHAR');
      expect(Column.undefined.definition, '');
    });

    test('.fromDartPrimitive', () {
      expect(Column.fromDartPrimitive(bool), Column.boolean);
      expect(Column.fromDartPrimitive(DateTime), Column.datetime);
      expect(Column.fromDartPrimitive(double), Column.Double);
      expect(Column.fromDartPrimitive(int), Column.integer);
      expect(Column.fromDartPrimitive(num), Column.num);
      expect(Column.fromDartPrimitive(String), Column.varchar);
      expect(
        () => Column.fromDartPrimitive(dynamic),
        throwsA(const TypeMatcher<ArgumentError>()),
      );
    });

    test('#dartType', () {
      expect(Column.bigint.dartType, num);
      expect(Column.blob.dartType, List);
      expect(Column.boolean.dartType, bool);
      expect(Column.date.dartType, DateTime);
      expect(Column.datetime.dartType, DateTime);
      expect(Column.Double.dartType, double);
      expect(Column.integer.dartType, int);
      expect(Column.float.dartType, num);
      expect(Column.num.dartType, num);
      expect(Column.text.dartType, String);
      expect(Column.varchar.dartType, String);
      expect(Column.undefined.dartType, dynamic);
    });
  });
}
