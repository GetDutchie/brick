import 'package:build/build.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';
import 'package:source_gen_test/source_gen_test.dart';

/// In the test directory, filename prefix `test_`, suffix `.dart`
Future<LibraryReader> _libraryForFolder(String folder, String filename) async {
  return await initializeLibraryReaderForDirectory(
    p.join('test', folder),
    'test_$filename.dart',
  );
}

///
typedef LibraryGenerator = Future<LibraryReader> Function(String filename);

/// Thunks a reader generator that assumes the filename is prefixed `test_`
/// and suffixed `.dart` and nested in [folder] in the `test` folder.
LibraryGenerator generateLibraryForFolder(String folder) {
  return (String filename) {
    return _libraryForFolder(folder, filename);
  };
}

/// The first annotation in a file
///
/// [_Annotation] should reflect the class-level annotation, e.g. `@ConnectOfflineFirstWithRest`
Future<AnnotatedElement> annotationForFile<_Annotation>(String folder, String filename) async {
  final annotationChecker = TypeChecker.fromRuntime(_Annotation);
  final reader = await _libraryForFolder(folder, filename);
  return reader.annotatedWith(annotationChecker).first;
}

// ignore: subtype_of_sealed_class
///
class MockBuildStep extends BuildStep {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
