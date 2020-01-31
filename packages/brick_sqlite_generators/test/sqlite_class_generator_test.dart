import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/generators.dart';
import 'package:brick_sqlite_abstract/annotations.dart';
import 'package:brick_sqlite_generators/sqlite_class_generator.dart';
import 'package:test/test.dart';
import 'package:source_gen/source_gen.dart';
import 'package:brick_build/testing.dart';

import 'sqlite_class_generator/test_sqlite_unique.dart' as _$sqliteUnique;

final _generator = TestGenerator();
final folder = 'sqlite_class_generator';
final generateReader = generateLibraryForFolder(folder);

void main() {
  group('SqliteClassGenerator', () {
    group('incorrect', () {
      test('IdField', () async {
        final reader = await generateReader('id_field');
        expect(
          () async => await _generator.generate(reader, null),
          throwsA(TypeMatcher<InvalidGenerationSourceError>()),
        );
      });

      test('PrimaryKeyField', () async {
        final reader = await generateReader('primary_key_field');
        expect(
          () async => await _generator.generate(reader, null),
          throwsA(TypeMatcher<InvalidGenerationSourceError>()),
        );
      });
    });

    group('@Sqlite', () {
      test('unique', () async {
        await generateAdapterExpectation('sqlite_unique', _$sqliteUnique.output);
      });
    });
  });
}

/// Output serializing code for all models with the @[SqliteSerializable] annotation.
/// [SqliteSerializable] **does not** produce code.
/// A `const` class is required from an non-relative import,
/// and [SqliteSerializable] was arbitrarily chosen for this test.
/// This will do nothing outside of this exact test suite.
class TestGenerator extends AnnotationSuperGenerator<SqliteSerializable> {
  final superAdapterName = 'Sqlite';
  final repositoryName = 'SqliteFirst';

  TestGenerator();

  /// Given an [element] and an [annotation], scaffold generators
  List<SerdesGenerator> buildGenerators(Element element, ConstantReader annotation) {
    final serializableGenerator =
        SqliteClassGenerator(element, annotation, repositoryName: repositoryName);
    return serializableGenerator.generators;
  }
}

Future<void> generateExpectation(String filename, String output, {TestGenerator generator}) async {
  final reader = await generateReader(filename);
  final generated = await (generator ?? _generator).generate(reader, null);
  expect(generated.trim(), output.trim());
}

Future<void> generateAdapterExpectation(String filename, String output) async {
  final annotation = await annotationForFile<SqliteSerializable>(folder, filename);
  final generated = await _generator.generateAdapter(
    annotation?.element,
    annotation?.annotation,
    null,
  );
  expect(generated.trim(), output.trim());
}
