import 'package:source_gen/source_gen.dart';
import 'package:brick_build/testing.dart';
import 'package:brick_build_test/brick_build_test.dart';

class TestGenerator extends GeneratorForAnnotation {
  TestGenerator();
}

final _generator = TestGenerator();
final folder = 'provider_serializable_generator';
final generateReader = generateLibraryForFolder(folder);

Future<String> generateExpectation(
  String filename, {
  required TestGenerator generator,
}) async {
  final reader = await generateReader(filename);
  final generated = await generator.generate(reader, MockBuildStep());
  return generated.trim();
}
// => final generated = await generateExpectation('file_in_test_folder')
// => expect(generated, expectedOutput);

Future<String> generateAdapterExpectation(String filename) async {
  final annotation = await annotationForFile<AnnotationSuperGenerator>(folder, filename);
  final generated = _generator.generateAdapter(
    annotation.element,
    annotation.annotation,
    null,
  );
  return generated.trim();
}
// => final generated = await generateAdapterExpectation('file_in_test_folder')
// => expect(generated, expectedOutput);
