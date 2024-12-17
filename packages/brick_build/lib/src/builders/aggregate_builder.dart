import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/src/builders/base.dart';
import 'package:build/build.dart';
import 'package:glob/glob.dart';
import 'package:source_gen/source_gen.dart';

/// Combine all `@ConnectOfflineFirstWithRest` and `@Migratable` classes and annotations
///
/// Since [LibraryElement] only reads from one file and not an entire directory, all relevant
/// classes and annotation are inserted into copies of all input files. If there is ever a
/// performance concern with build times, start here. Only one file is needed, but it is impossible
/// to access [LibraryReader]s outside the build step of the created asset, and this was the only
/// successful way amongst dozens.
/// This does **not** output a file used by Brick in the app implementation.
///
/// See the
/// [`build` docs](https://github.com/dart-lang/build/blob/master/docs/writing_an_aggregate_builder.md#defining-your-builder)
/// example for more.
class AggregateBuilder implements Builder {
  /// A list of packages that must be included for adapters and models to build:
  /// field-level annotation imports, helper classes, etc.
  /// For example: `['import 'package:brick_sqlite/db.dart';']`
  final List<String> requiredImports;

  ///
  static final adapterFiles = Glob('lib/brick/adapters/*.g.dart');

  ///
  static final importRegex = RegExp(r'(^import\s.*;)', multiLine: true);

  ///
  static final migrationFiles = Glob('lib/brick/db/*.migration.dart');

  ///
  static final modelFiles = Glob('lib/**/*.model.dart');

  ///
  static const outputFileName = 'models_and_migrations${BaseBuilder.aggregateExtension}.dart';

  /// Combine all `@ConnectOfflineFirstWithRest` and `@Migratable` classes and annotations
  ///
  /// Since [LibraryElement] only reads from one file and not an entire directory, all relevant
  /// classes and annotation are inserted into copies of all input files. If there is ever a
  /// performance concern with build times, start here. Only one file is needed, but it is impossible
  /// to access [LibraryReader]s outside the build step of the created asset, and this was the only
  /// successful way amongst dozens.
  /// This does **not** output a file used by Brick in the app implementation.
  ///
  /// See the
  /// [`build` docs](https://github.com/dart-lang/build/blob/master/docs/writing_an_aggregate_builder.md#defining-your-builder)
  /// example for more.
  const AggregateBuilder({this.requiredImports = const <String>[]});

  @override
  Future<void> build(BuildStep buildStep) async {
    brickLogger.info('Aggregating models and migrations...');

    final imports = <String>{
      'library big_messy_models_migrations_file;',
      ...requiredImports,
    };

    final files = <String>[];
    for (final glob in [migrationFiles, modelFiles]) {
      await for (final input in buildStep.findAssets(glob)) {
        final contents = await buildStep.readAsString(input);
        imports.addAll(findAllImports(contents));
        final newContents = contents
            .replaceAll(importRegex, '')
            .replaceAll(RegExp("part of '.*';"), '')
            .replaceAll(RegExp(r"^part\s'.*';", multiLine: true), '')
            .replaceAll(RegExp(r'^export\s.*;', multiLine: true), '');
        files.add(newContents);
      }
    }

    final contents = '${imports.join('\n')}\n${files.join('\n')}';
    await buildStep.writeAsString(
      AssetId(buildStep.inputId.package, 'lib/$outputFileName'),
      contents,
    );
  }

  /// All unique `import:package` within a large body of text
  static Set<String> findAllImports(String contents) =>
      importRegex.allMatches(contents).map((m) => m[0]!).toSet();

  @override
  Map<String, List<String>> get buildExtensions => const {
        r'$lib$': [outputFileName],
      };
}
