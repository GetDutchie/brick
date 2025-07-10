import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/generators.dart';
import 'package:brick_build_test/brick_build_test.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_sqlite_generators/sqlite_model_serdes_generator.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import 'sqlite_model_serdes_generator/test_after_save_with_association.dart'
    as after_save_with_association;
import 'sqlite_model_serdes_generator/test_all_field_types.dart' as all_field_types;
import 'sqlite_model_serdes_generator/test_boolean_fields.dart' as boolean_fields;
import 'sqlite_model_serdes_generator/test_field_with_type_argument.dart'
    as field_with_type_argument;
import 'sqlite_model_serdes_generator/test_sqlite_column_type.dart' as sqlite_column_type;
import 'sqlite_model_serdes_generator/test_sqlite_enum_as_string.dart' as sqlite_enum_as_string;
import 'sqlite_model_serdes_generator/test_sqlite_unique.dart' as sqlite_unique;
import 'sqlite_model_serdes_generator/test_to_json_from_json.dart' as to_json_from_json;

final _generator = TestGenerator();
const folder = 'sqlite_model_serdes_generator';
final generateReader = generateLibraryForFolder(folder);

void main() {
  group('SqliteModelSerdesGenerator', () {
    group('incorrect', () {
      test('IdField', () async {
        final reader = await generateReader('id_field');
        expect(
          () async => await _generator.generate(reader, MockBuildStep()),
          throwsA(const TypeMatcher<InvalidGenerationSourceError>()),
        );
      });

      test('PrimaryKeyField', () async {
        final reader = await generateReader('primary_key_field');
        expect(
          () async => await _generator.generate(reader, MockBuildStep()),
          throwsA(const TypeMatcher<InvalidGenerationSourceError>()),
        );
      });

      test('ColumnTypeWithoutFrom', () async {
        final reader = await generateReader('column_type_without_generator');
        expect(
          () async => await _generator.generate(reader, MockBuildStep()),
          throwsA(const TypeMatcher<InvalidGenerationSourceError>()),
        );
      });
    });

    group('@Sqlite', () {
      test('columnType', () async {
        await generateAdapterExpectation('sqlite_column_type', sqlite_column_type.output);
      });

      test('unique', () async {
        await generateAdapterExpectation('sqlite_unique', sqlite_unique.output);
      });

      test('enumAsString', () async {
        await generateAdapterExpectation('sqlite_enum_as_string', sqlite_enum_as_string.output);
      });
    });

    test('FieldWithTypeArgument', () async {
      await generateAdapterExpectation('field_with_type_argument', field_with_type_argument.output);
    });

    test('BooleanFields', () async {
      await generateAdapterExpectation('boolean_fields', boolean_fields.output);
    });

    test('AfterSaveWithAssociation', () async {
      await generateAdapterExpectation(
        'after_save_with_association',
        after_save_with_association.output,
      );
    });

    test('AllFieldTypes', () async {
      await generateAdapterExpectation('all_field_types', all_field_types.output);
    });

    test('ToJsonFromJson', () async {
      await generateAdapterExpectation('to_json_from_json', to_json_from_json.output);
    });
  });
}

/// Output serializing code for all models with the @[SqliteSerializable] annotation.
/// [SqliteSerializable] **does not** produce code.
/// A `const` class is required from an non-relative import,
/// and [SqliteSerializable] was arbitrarily chosen for this test.
/// This will do nothing outside of this exact test suite.
class TestGenerator extends AnnotationSuperGenerator<SqliteSerializable> {
  @override
  final superAdapterName = 'Sqlite';
  final repositoryName = 'SqliteFirst';

  TestGenerator();

  /// Given an [element] and an [annotation], scaffold generators
  @override
  List<SerdesGenerator> buildGenerators(Element element, ConstantReader annotation) {
    final serializableGenerator =
        SqliteModelSerdesGenerator(element, annotation, repositoryName: repositoryName);
    return serializableGenerator.generators;
  }
}

Future<void> generateExpectation(String filename, String output, {TestGenerator? generator}) async {
  final reader = await generateReader(filename);
  final generated = await (generator ?? _generator).generate(reader, MockBuildStep());

  if (generated.trim() != output.trim()) {
    // ignore: avoid_print
    print(generated);
  }

  expect(generated.trim(), output.trim());
}

Future<void> generateAdapterExpectation(String filename, String output) async {
  final annotation = await annotationForFile<SqliteSerializable>(folder, filename);
  final generated = _generator.generateAdapter(
    annotation.element,
    annotation.annotation,
    null,
  );

  if (generated.trim() != output.trim()) {
    // ignore: avoid_print
    print(generated);
  }

  expect(generated.trim(), output.trim());
}
