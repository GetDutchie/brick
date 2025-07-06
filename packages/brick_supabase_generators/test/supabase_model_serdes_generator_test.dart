import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/generators.dart';
import 'package:brick_build_test/brick_build_test.dart';
import 'package:brick_supabase/brick_supabase.dart';
import 'package:brick_supabase_generators/supabase_model_serdes_generator.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import 'supabase_model_serdes_generator/test_constructor_member_field_mismatch.dart'
    as constructor_member_field_mismatch;
import 'supabase_model_serdes_generator/test_enum_as_string.dart' as enum_as_string;
import 'supabase_model_serdes_generator/test_ignore_from_to.dart' as ignore_from_to;
import 'supabase_model_serdes_generator/test_runtime_supabase_column_definition.dart'
    as runtime_supabase_column_definition;
import 'supabase_model_serdes_generator/test_unique.dart' as unique;
import 'supabase_model_serdes_generator/test_unserializable_field_with_generator.dart'
    as unserializable_field_with_generator;

final _generator = TestGenerator();
const folder = 'supabase_model_serdes_generator';
final generateReader = generateLibraryForFolder(folder);

void main() {
  group('SupabaseModelSerdesGenerator', () {
    group('@Supabase', () {
      test('enumAsString', () async {
        await generateExpectation('enum_as_string', enum_as_string.output);
      });

      test('ignoreFrom ignoreTo', () async {
        await generateExpectation('ignore_from_to', ignore_from_to.output);
      });

      test('unique', () async {
        await generateAdapterExpectation('unique', unique.output);
      });

      test('fromGenerator toGenerator', () async {
        await generateExpectation(
          'unserializable_field_with_generator',
          unserializable_field_with_generator.output,
        );
      });

      test('SupabaseConstructorMemberFieldMismatch', () async {
        await generateExpectation(
          'constructor_member_field_mismatch',
          constructor_member_field_mismatch.output,
        );
      });
    });

    test('runtime associations', () async {
      await generateAdapterExpectation(
        'runtime_supabase_column_definition',
        runtime_supabase_column_definition.output,
      );
    });
  });
}

/// Output serializing code for all models with the @[SupabaseSerializable] annotation.
/// [SupabaseSerializable] **does not** produce code.
/// A `const` class is required from an non-relative import,
/// and [SupabaseSerializable] was arbitrarily chosen for this test.
/// This will do nothing outside of this exact test suite.
class TestGenerator extends AnnotationSuperGenerator<SupabaseSerializable> {
  @override
  final superAdapterName = 'SupabaseFirst';
  final repositoryName = 'SupabaseFirst';

  TestGenerator();

  /// Given an [element] and an [annotation], scaffold generators
  @override
  List<SerdesGenerator> buildGenerators(Element element, ConstantReader annotation) {
    final serializableGenerator =
        SupabaseModelSerdesGenerator(element, annotation, repositoryName: repositoryName);
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
  final annotation = await annotationForFile<SupabaseSerializable>(folder, filename);
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
