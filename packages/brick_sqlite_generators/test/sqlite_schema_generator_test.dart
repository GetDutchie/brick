import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build_test/brick_build_test.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_sqlite_generators/src/sqlite_fields.dart';
import 'package:brick_sqlite_generators/src/sqlite_schema/sqlite_schema_generator.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import 'sqlite_schema/test_all_field_types.dart' as all_field_types;
import 'sqlite_schema/test_enum_as_string.dart' as enum_as_string;
import 'sqlite_schema/test_from_to_json.dart' as from_to_json;
import 'sqlite_schema/test_index_annotation.dart' as index_annotation;
import 'sqlite_schema/test_nullable.dart' as nullable;
import 'sqlite_schema/test_one_to_many_association.dart' as one_to_many_association;
import 'sqlite_schema/test_one_to_one_association.dart' as one_to_one_association;
import 'sqlite_schema/test_simple.dart' as simple;
import 'sqlite_schema/test_sqlite_column_type.dart' as sqlite_column_type;

const generator = SqliteSchemaGenerator();
final generateReader = generateLibraryForFolder('sqlite_schema');

void main() {
  group('SqliteSchemaGenerator', () {
    group('#generate', () {
      test('AllFieldTypes', () async {
        final input = await generateInput('all_field_types');
        expect(input, all_field_types.output);
      });

      test('ColumnType', () async {
        final input = await generateInput('sqlite_column_type');
        expect(input, sqlite_column_type.output);
      });

      test('EnumAsString', () async {
        final input = await generateInput('enum_as_string');
        expect(input, enum_as_string.output);
      });

      test('Nullable', () async {
        final input = await generateInput('nullable');
        expect(input, nullable.output);
      });

      test('OneToOneAssociation', () async {
        final input = await generateInput('one_to_one_association');
        expect(input, one_to_one_association.output);
      });

      test('OneToManyAssociation', () async {
        final input = await generateInput('one_to_many_association');
        expect(input, one_to_many_association.output);
      });

      test('IndexAnnotation', () async {
        final input = await generateInput('index_annotation');
        expect(input, index_annotation.output);
      });

      test('Simple', () async {
        final input = await generateInput('simple');
        expect(input, simple.output);
      });

      test('FromToJson', () async {
        final input = await generateInput('from_to_json');
        expect(input, from_to_json.output);
      });
    });

    test('#createMigration', () async {
      final map = await generateSchemaMap('simple');
      final reader = map.keys.first;
      final fieldses = map.values.first;

      final output = generator.createMigration(reader, fieldses, version: 1);
      expect(output, simple.migrationOutput);
    });
  });
}

const annotationChecker = TypeChecker.fromRuntime(SqliteSerializable);
Future<Map<LibraryReader, List<SqliteFields>>> generateSchemaMap(String filename) async {
  final reader = await generateReader(filename);

  final annotatedElements = reader.annotatedWith(annotationChecker);
  final classes = annotatedElements.map((e) => SqliteFields(e.element as ClassElement)).toList();

  return {reader: classes};
}

Future<String> generateInput(String filename) async {
  final map = await generateSchemaMap(filename);

  return generator.generate(map.keys.first, map.values.first);
}
