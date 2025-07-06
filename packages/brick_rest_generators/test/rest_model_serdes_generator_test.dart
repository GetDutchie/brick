import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/generators.dart';
import 'package:brick_build_test/brick_build_test.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:brick_rest_generators/rest_model_serdes_generator.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import 'rest_model_serdes_generator/test_constructor_member_field_mismatch.dart'
    as constructor_member_field_mismatch;
import 'rest_model_serdes_generator/test_enum_as_string.dart' as enum_as_string;
import 'rest_model_serdes_generator/test_ignore_from_to.dart' as ignore_from_to;
import 'rest_model_serdes_generator/test_unserializable_field_with_generator.dart'
    as unserializable_field_with_generator;

final _generator = TestGenerator();
const folder = 'rest_model_serdes_generator';
final generateReader = generateLibraryForFolder(folder);

void main() {
  group('RestModelSerdesGenerator', () {
    group('@Rest', () {
      test('enum_as_string', () async {
        await generateExpectation('enum_as_string', enum_as_string.output);
      });

      test('ignoreFrom ignoreTo', () async {
        await generateExpectation('ignore_from_to', ignore_from_to.output);
      });

      test('fromGenerator toGenerator', () async {
        await generateExpectation(
          'unserializable_field_with_generator',
          unserializable_field_with_generator.output,
        );
      });

      test('RestConstructorMemberFieldMismatch', () async {
        await generateExpectation(
          'constructor_member_field_mismatch',
          constructor_member_field_mismatch.output,
        );
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
  @override
  final superAdapterName = 'RestFirst';
  final repositoryName = 'RestFirst';

  TestGenerator();

  /// Given an [element] and an [annotation], scaffold generators
  @override
  List<SerdesGenerator> buildGenerators(Element element, ConstantReader annotation) {
    final serializableGenerator =
        RestModelSerdesGenerator(element, annotation, repositoryName: repositoryName);
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
  final annotation = await annotationForFile<RestSerializable>(folder, filename);
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
