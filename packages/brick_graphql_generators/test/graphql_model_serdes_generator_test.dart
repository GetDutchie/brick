import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/generators.dart';
import 'package:brick_graphql/graphql.dart';
import 'package:brick_graphql_generators/graphql_model_serdes_generator.dart';
import 'package:test/test.dart';
import 'package:source_gen/source_gen.dart';
import 'package:brick_build_test/brick_build_test.dart';

import 'graphql_model_serdes_generator/test_enum_as_string.dart' as enum_as_string;
import 'graphql_model_serdes_generator/test_ignore_from_to.dart' as ignore_from_to;
import 'graphql_model_serdes_generator/test_unserializable_field_with_generator.dart'
    as unserializable_field_with_generator;
import 'graphql_model_serdes_generator/test_constructor_member_field_mismatch.dart'
    as constructor_member_field_mismatch;

final _generator = TestGenerator();
final folder = 'graphql_model_serdes_generator';
final generateReader = generateLibraryForFolder(folder);

void main() {
  group('GraphqlModelSerdesGenerator', () {
    group('@Graphql', () {
      test('enum_as_string', () async {
        await generateExpectation('enum_as_string', enum_as_string.output);
      });

      test('ignoreFrom ignoreTo', () async {
        await generateExpectation('ignore_from_to', ignore_from_to.output);
      });

      test('fromGenerator toGenerator', () async {
        await generateExpectation(
            'unserializable_field_with_generator', unserializable_field_with_generator.output);
      });

      test('GraphqlConstructorMemberFieldMismatch', () async {
        await generateExpectation(
            'constructor_member_field_mismatch', constructor_member_field_mismatch.output);
      });
    });
  });
}

/// Output serializing code for all models with the @[GraphqlSerializable] annotation.
/// [GraphqlSerializable] **does not** produce code.
/// A `const` class is required from an non-relative import,
/// and [GraphqlSerializable] was arbitrarily chosen for this test.
/// This will do nothing outside of this exact test suite.
class TestGenerator extends AnnotationSuperGenerator<GraphqlSerializable> {
  @override
  final superAdapterName = 'GraphqlFirst';
  final repositoryName = 'GraphqlFirst';

  TestGenerator();

  /// Given an [element] and an [annotation], scaffold generators
  @override
  List<SerdesGenerator> buildGenerators(Element element, ConstantReader annotation) {
    final serializableGenerator =
        GraphqlModelSerdesGenerator(element, annotation, repositoryName: repositoryName);
    return serializableGenerator.generators;
  }
}

Future<void> generateExpectation(String filename, String output, {TestGenerator? generator}) async {
  final reader = await generateReader(filename);
  final generated = await (generator ?? _generator).generate(reader, MockBuildStep());
  expect(generated.trim(), output.trim());
}

Future<void> generateAdapterExpectation(String filename, String output) async {
  final annotation = await annotationForFile<GraphqlSerializable>(folder, filename);
  final generated = _generator.generateAdapter(
    annotation.element,
    annotation.annotation,
    null,
  );
  expect(generated.trim(), output.trim());
}
