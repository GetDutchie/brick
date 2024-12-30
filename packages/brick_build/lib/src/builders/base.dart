import 'dart:io';

import 'package:build/build.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';

export 'package:brick_build/src/annotation_super_generator.dart';

///
final brickLogger = Logger('Brick');

///
abstract class BaseBuilder<_ClassAnnotation> implements Builder {
  ///
  Logger get logger => brickLogger;

  @override
  Map<String, List<String>> get buildExtensions => {
        '$aggregateExtension.dart': ['${BaseBuilder.aggregateExtension}$outputExtension'],
      };

  /// The cached file this will produce
  String get outputExtension;

  ///
  final typeChecker = TypeChecker.fromRuntime(_ClassAnnotation);

  ///
  static const aggregateExtension = '.brick_aggregate';

  /// Classes with the class-level annotation. For example, `ConnectOfflineFirstWithRest`.
  Future<Iterable<AnnotatedElement>> getAnnotatedElements(BuildStep buildStep) async {
    final libraryReader = LibraryReader(await buildStep.inputLibrary);
    return libraryReader.annotatedWith(typeChecker);
  }

  /// After a task has completed, log time to completion.
  void logStopwatch(String task, Stopwatch stopwatch) {
    final elapsedSeconds = stopwatchToSeconds(stopwatch);
    logger.info('$task, took $elapsedSeconds');
  }

  /// Create or write to file.
  Future<File> manuallyUpsertBrickFile(String path, String contents) async {
    final dirName = path.split('/').first;

    if (!dirName.contains('.dart')) {
      final dir = Directory(p.join('lib', 'brick', dirName));
      final dirExists = dir.existsSync();
      if (!dirExists) {
        await dir.create();
      }
    }

    final newFile = File(p.join('lib', 'brick', path));
    final fileExists = newFile.existsSync();
    if (!fileExists) {
      await newFile.create();
    }
    final writtenFile = await newFile.writeAsString(contents);
    return writtenFile;
  }

  /// Replace contents of file
  Future<File?> replaceWithinFile(String path, Pattern from, String to) async {
    final file = File(p.join('lib', 'brick', path));
    final fileExists = file.existsSync();
    if (!fileExists) return null;

    final contents = await file.readAsString();
    final replacedContents = contents.replaceAll(from, to);
    return await file.writeAsString(replacedContents);
  }

  /// Stop stopwatch and conditionally format elapsed time as seconds or ms
  String stopwatchToSeconds(Stopwatch stopwatch) {
    stopwatch.stop();
    final milliseconds = stopwatch.elapsedMilliseconds;

    if (milliseconds > 1000) {
      final roundedMilliseconds = (milliseconds / 1000).toStringAsFixed(2);
      return '${roundedMilliseconds}s';
    } else {
      return '${milliseconds}ms';
    }
  }
}
