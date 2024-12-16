import 'package:brick_sqlite/db.dart';
import 'package:brick_sqlite_generators/src/builders/sqlite_base_builder.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

/// Create a new [Migration] from the contents of all `ConnectOfflineFirstWith` models
class NewMigrationBuilder<_ClassAnnotation> extends SqliteBaseBuilder<_ClassAnnotation> {
  @override
  final outputExtension = '.migration_builder.dart';

  /// Create a new [Migration] from the contents of all `ConnectOfflineFirstWith` models
  NewMigrationBuilder();

  @override
  Future<void> build(BuildStep buildStep) async {
    final libraryReader = LibraryReader(await buildStep.inputLibrary);
    final fieldses = await sqliteFieldsFromBuildStep(buildStep);
    final now = DateTime.now().toUtc();
    final timestamp =
        [now.month, now.day, now.hour, now.minute, now.second].map(_padToTwo).toList().join();
    final version = int.parse('${now.year}$timestamp');
    final output = schemaGenerator.createMigration(libraryReader, fieldses, version: version);

    if (output == null) return;

    final stopwatch = Stopwatch()..start();

    // in a perfect world, the schema would not be edited in such a brittle way
    // however, reruning the schema generator here doesn't pick up the new migration
    // because it uses the LibraryReader from before the migration is created.
    // this should be revisited in a few build versions to make this flow less brittle
    // and more predictable by using the same schema generator to do all the heavy lifting
    final newSetPiece = 'final migrations = <Migration>{\n  const Migration$version(),';
    final newPart = "brick_sqlite/db.dart';\npart '$version.migration.dart';";

    await replaceWithinFile(
      'db/schema.g.dart',
      'final migrations = <Migration>{',
      newSetPiece,
    );
    await replaceWithinFile(
      'db/schema.g.dart',
      "brick_sqlite/db.dart';",
      newPart,
    );

    await manuallyUpsertBrickFile('db/$version.migration.dart', output);
    await buildStep.writeAsString(buildStep.inputId.changeExtension(outputExtension), output);
    await replaceWithinFile(
      'db/schema.g.dart',
      RegExp(r'final schema =(?:\n\s+)? Schema\(([\d]+|null),'),
      'final schema = Schema($version,',
    );

    logStopwatch('Generated new migration (db/$version.migration.dart)', stopwatch);
  }
}

String _padToTwo(int value) => value.toString().padLeft(2, '0');
