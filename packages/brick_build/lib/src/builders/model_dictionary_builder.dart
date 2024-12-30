import 'package:brick_build/src/builders/aggregate_builder.dart';
import 'package:brick_build/src/builders/base.dart';
import 'package:brick_build/src/model_dictionary_generator.dart';
import 'package:brick_core/core.dart';
import 'package:build/build.dart';
import 'package:glob/glob.dart';
import 'package:source_gen/source_gen.dart';

/// Writes [ModelDictionary] code to connect model and adapters. Outputs to brick/brick.g.dart
class ModelDictionaryBuilder<_ClassAnnotation> extends BaseBuilder<_ClassAnnotation> {
  /// Import files to clean up from the final brick.g.dart file.
  /// For example, all annotations should be expanded into generated code, so their imports
  /// are no longer required by Brick.
  ///
  /// Include both single and double strings around package imports for safety. Regex is not supported.
  final List<String> expectedImportRemovals;

  ///
  final ModelDictionaryGenerator modelDictionaryGenerator;

  @override
  final outputExtension = '.model_dictionary_builder.dart';

  ///
  static final modelFiles = Glob('lib/**/*.model.dart');

  /// Writes [ModelDictionary] code to connect model and adapters. Outputs to brick/brick.g.dart
  ModelDictionaryBuilder(
    this.modelDictionaryGenerator, {
    this.expectedImportRemovals = const <String>[],
  });

  @override
  Future<void> build(BuildStep buildStep) async {
    final annotatedElements = await getAnnotatedElements(buildStep);
    final filesToContents = <String, String>{};
    await for (final asset in buildStep.findAssets(modelFiles)) {
      filesToContents[asset.path] = await buildStep.readAsString(asset);
    }

    final contents = await buildStep.readAsString(buildStep.inputId);
    final stopwatch = Stopwatch()..start();

    final allImports = AggregateBuilder.findAllImports(contents);
    final classNamesByFileNames = classFilePathsFromAnnotations(annotatedElements, filesToContents);
    final modelDictionaryOutput = modelDictionaryGenerator.generate(classNamesByFileNames);
    allImports
        .removeAll(["import 'dart:convert';", 'import "dart:convert";', ...expectedImportRemovals]);
    final analyzedImports = allImports
        .map((i) => '// ignore: unused_import, unused_shown_name, unnecessary_import\n$i')
        .join('\n');
    final output = analyzedImports + modelDictionaryOutput;

    await manuallyUpsertBrickFile('brick.g.dart', output);
    await buildStep.writeAsString(buildStep.inputId.changeExtension(outputExtension), output);
    logStopwatch('Generated brick.g.dart', stopwatch);
  }

  ///
  static Map<String, String> classFilePathsFromAnnotations(
    Iterable<AnnotatedElement> annotations,
    Map<String, String> filesToContents,
  ) =>
      {
        for (final annotation in annotations)
          '${annotation.element.name}': filesToContents.entries
              .firstWhere((entry) => entry.value.contains('class ${annotation.element.name} '))
              .key
              // Make relative from the `brick/` folder
              .replaceAll(RegExp('^lib/'), '../'),
      };
}
