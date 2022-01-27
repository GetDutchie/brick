import 'package:brick_sqlite_generators/src/builders/sqlite_base_builder.dart';
import 'package:source_gen/source_gen.dart';
import 'package:build/build.dart';

/// Write a [Schema] from existing migrations. Outputs to brick/db/schema.g.dart
class SchemaBuilder<_ClassAnnotation> extends SqliteBaseBuilder<_ClassAnnotation> {
  @override
  final outputExtension = '.schema_builder.dart';

  SchemaBuilder();

  @override
  Future<void> build(BuildStep buildStep) async {
    final stopwatch = Stopwatch();
    stopwatch.start();

    final libraryReader = LibraryReader(await buildStep.inputLibrary);
    final fieldses = await sqliteFieldsFromBuildStep(buildStep);
    final output = schemaGenerator.generate(libraryReader, fieldses);

    await manuallyUpsertAppFile('db/schema.g.dart', output);
    await buildStep.writeAsString(buildStep.inputId.changeExtension(outputExtension), output);
    logStopwatch('Generated db/schema.g.dart', stopwatch);
  }
}
