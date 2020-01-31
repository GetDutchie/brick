import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/generators.dart';
import 'package:brick_rest/rest.dart';
import 'package:brick_rest_generators/rest_class_generator.dart';
import 'package:test/test.dart';
import 'package:source_gen/source_gen.dart';
import 'package:brick_build/testing.dart';

import 'rest_class_generator/test_enum_as_string.dart' as _$enumAsString;
import 'rest_class_generator/test_ignore_from_to.dart' as _$ignoreFromTo;

final _generator = TestGenerator();
final folder = 'rest_class_generator';
final generateReader = generateLibraryForFolder(folder);

void main() {
  group('RestClassGenerator', () {
    group('@Rest', () {
      test('enumAsString', () async {
        await generateExpectation('enum_as_string', _$enumAsString.output);
      });

      test('ignoreFrom ignoreTo', () async {
        await generateExpectation('ignore_from_to', _$ignoreFromTo.output);
      });
    });
  });
}

/// Output serializing code for all models with the @[RestSerializable] annotation.
/// [RestSerializable] **does not** produce code.
/// A `const` class is required from an non-relative import,
/// and [RestSerializable] was arbitrarily chosen for this test.
/// This will do nothing outside of this exact test suite.
class TestGenerator extends AnnotationSuperGenerator<RestSerializable> {
  final superAdapterName = 'RestFirst';
  final repositoryName = 'RestFirst';

  TestGenerator();

  /// Given an [element] and an [annotation], scaffold generators
  List<SerdesGenerator> buildGenerators(Element element, ConstantReader annotation) {
    final serializableGenerator =
        RestClassGenerator(element, annotation, repositoryName: repositoryName);
    return serializableGenerator.generators;
  }
}

Future<void> generateExpectation(String filename, String output, {TestGenerator generator}) async {
  final reader = await generateReader(filename);
  final generated = await (generator ?? _generator).generate(reader, null);
  expect(generated.trim(), output.trim());
}

Future<void> generateAdapterExpectation(String filename, String output) async {
  final annotation = await annotationForFile<RestSerializable>(folder, filename);
  final generated = await _generator.generateAdapter(
    annotation?.element,
    annotation?.annotation,
    null,
  );
  expect(generated.trim(), output.trim());
}
