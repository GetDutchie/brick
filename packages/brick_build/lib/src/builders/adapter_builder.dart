import 'package:brick_build/src/builders/base.dart';
import 'package:brick_build/src/utils/string_helpers.dart';
import 'package:build/build.dart';

/// Writes adapter code (model serialization/deserialization).
/// Outputs to brick/adapters/{MODEL}_adapter.g.dart
class AdapterBuilder<_ClassAnnotation> extends BaseBuilder<_ClassAnnotation> {
  ///
  final AnnotationSuperGenerator generator;

  @override
  final outputExtension = '.adapter_builder.dart';

  /// Writes adapter code (model serialization/deserialization).
  /// Outputs to brick/adapters/{MODEL}_adapter.g.dart
  AdapterBuilder(this.generator);

  @override
  Future<void> build(BuildStep buildStep) async {
    final annotatedElements = await getAnnotatedElements(buildStep);

    final allOutputs = <String>[];
    for (final annotatedElement in annotatedElements) {
      final stopwatch = Stopwatch()..start();

      final output = generator.generateAdapter(
        annotatedElement.element,
        annotatedElement.annotation,
        buildStep,
      );

      // Since the generator must be aware of all classes and LibraryElement only targets
      // a single file, this must expand the serialization output into its own file.
      final snakedName = StringHelpers.snakeCase(annotatedElement.element.name!);
      await manuallyUpsertBrickFile('adapters/${snakedName}_adapter.g.dart', output);
      allOutputs.add(output);
      logStopwatch(
        'Generated ${snakedName}_adapter.g.dart (${annotatedElement.element.name})',
        stopwatch,
      );
    }

    await buildStep.writeAsString(
      buildStep.inputId.changeExtension(outputExtension),
      allOutputs.join('\n'),
    );
  }

  @override
  Map<String, List<String>> get buildExtensions => {
        '.dart': [outputExtension],
      };
}
