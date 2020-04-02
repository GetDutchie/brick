import 'package:brick_sqlite_abstract/annotations.dart';
import 'package:brick_sqlite_generators/src/sqlite_schema/sqlite_schema_generator.dart';
import 'package:brick_sqlite_generators/src/sqlite_fields.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';
import 'package:brick_build/testing.dart';

import 'sqlite_schema/test_simple.dart' as _$simple;
import 'sqlite_schema/test_nullable.dart' as _$nullable;
import 'sqlite_schema/test_sqlite_column_type.dart' as _$sqliteColumnType;
import 'sqlite_schema/test_one_to_one_association.dart' as _$oneToOneAssociation;
import 'sqlite_schema/test_all_field_types.dart' as _$allFieldTypes;

const generator = SqliteSchemaGenerator();
final generateReader = generateLibraryForFolder('sqlite_schema');

void main() {
  group("SqliteSchemaGenerator", () {
    group("#generate", () {
      test("AllFieldTypes", () async {
        final input = await generateInput('all_field_types');
        expect(input, _$allFieldTypes.output);
      });

      test("ColumnType", () async {
        final input = await generateInput('sqlite_column_type');
        expect(input, _$sqliteColumnType.output);
      });

      test("Nullable", () async {
        final input = await generateInput('nullable');
        expect(input, _$nullable.output);
      });

      test("OneToOneAssociation", () async {
        final input = await generateInput('one_to_one_association');
        expect(input, _$oneToOneAssociation.output);
      });

      test("Simple", () async {
        final input = await generateInput('simple');
        expect(input, _$simple.output);
      });
    });

    test("#createMigration", () async {
      final map = await generateSchemaMap('simple');
      final reader = map.keys.first;
      final fieldses = map.values.first;

      final output = generator.createMigration(reader, fieldses, version: 1);
      expect(output, contains(_$simple.migrationOutput));
    });
  });
}

final annotationChecker = TypeChecker.fromRuntime(SqliteSerializable);
Future<Map<LibraryReader, List<SqliteFields>>> generateSchemaMap(String filename) async {
  final reader = await generateReader(filename);

  final annotatedElements = reader.annotatedWith(annotationChecker);
  final classes = annotatedElements.map((e) => SqliteFields(e.element)).toList();

  return {reader: classes};
}

Future<String> generateInput(String filename) async {
  final map = await generateSchemaMap(filename);

  return generator.generate(map.keys.first, map.values.first);
}
