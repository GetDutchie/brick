import 'package:brick_build/generators.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import '__helpers__.dart';

final _generator = TestGenerator();
const folder = 'provider_serializable_generator';
final generateReader = generateLibraryForFolder(folder);

void main() {
  group('ProviderSerializableGenerator', () {
    group('incorrect', () {
      test('annotatedMethod', () async {
        final reader = await generateReader('annotated_method');
        expect(
          () async => await _generator.generate(reader, MockBuildStep()),
          throwsA(const TypeMatcher<InvalidGenerationSourceError>()),
        );
      });

      test('annotatedTopLevelVariable', () async {
        final reader = await generateReader('annotated_top_level_variable');
        expect(
          () async => await _generator.generate(reader, MockBuildStep()),
          throwsA(const TypeMatcher<InvalidGenerationSourceError>()),
        );
      });

      test('FutureIterableFuture', () async {
        final reader = await generateReader('future_iterable_future');
        expect(
          () async => await _generator.generate(reader, MockBuildStep()),
          throwsA(const TypeMatcher<InvalidGenerationSourceError>()),
        );
      });
    });
  });
}

Future<void> generateExpectation(
  String filename,
  String output, {
  required TestGenerator generator,
}) async {
  final reader = await generateReader(filename);
  final generated = await generator.generate(reader, MockBuildStep());
  expect(generated.trim(), output.trim());
}

Future<void> generateAdapterExpectation(String filename, String output) async {
  final annotation = await annotationForFile<AnnotationSuperGenerator>(folder, filename);
  final generated = _generator.generateAdapter(
    annotation.element,
    annotation.annotation,
    null,
  );
  expect(generated.trim(), output.trim());
}
