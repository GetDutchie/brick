import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/generators.dart';
import 'package:brick_build_test/brick_build_test.dart';
import 'package:brick_graphql/brick_graphql.dart';
import 'package:brick_graphql_generators/graphql_model_serdes_generator.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import 'graphql_model_serdes_generator/test_annotation_subfields.dart' as annotation_subfields;
import 'graphql_model_serdes_generator/test_constructor_member_field_mismatch.dart'
    as constructor_member_field_mismatch;
import 'graphql_model_serdes_generator/test_enum_as_string.dart' as enum_as_string;
import 'graphql_model_serdes_generator/test_from_json_to_json.dart' as from_json_to_json;
import 'graphql_model_serdes_generator/test_ignore_from_to.dart' as ignore_from_to;
import 'graphql_model_serdes_generator/test_runtime_association_definition.dart'
    as runtime_association_definition;
import 'graphql_model_serdes_generator/test_unserializable_field_with_generator.dart'
    as unserializable_field_with_generator;

final _generator = TestGenerator();
const folder = 'graphql_model_serdes_generator';
final generateReader = generateLibraryForFolder(folder);

void main() {
  group('GraphqlModelSerdesGenerator', () {
    test('RuntimeGraphqlDefinition#association', () async {
      await generateAdapterExpectation(
        'runtime_association_definition',
        runtime_association_definition.output,
      );
    });

    group('@Graphql', () {
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

      test('GraphqlConstructorMemberFieldMismatch', () async {
        await generateExpectation(
          'constructor_member_field_mismatch',
          constructor_member_field_mismatch.output,
        );
      });

      test('FromJsonToJson', () async {
        await generateAdapterExpectation('from_json_to_json', from_json_to_json.output);
      });

      test('subfields', () async {
        await generateAdapterExpectation('annotation_subfields', annotation_subfields.output);
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

  if (generated.trim() != output.trim()) {
    // ignore: avoid_print
    print(generated);
  }

  expect(generated.trim(), output.trim());
}

Future<void> generateAdapterExpectation(String filename, String output) async {
  final annotation = await annotationForFile<GraphqlSerializable>(folder, filename);
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
