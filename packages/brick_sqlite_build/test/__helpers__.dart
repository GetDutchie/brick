import 'package:path/path.dart' as p;
import 'package:source_gen_test/source_gen_test.dart';
import 'package:source_gen/source_gen.dart';

class ConnectAnnotation {
  const ConnectAnnotation();
}

/// In the test directory, filename prefix `test_`, suffix `.dart`
Future<LibraryReader> _libraryForFolder(String folder, String filename) async {
  return await initializeLibraryReaderForDirectory(
    p.join('test', folder),
    'test_$filename.dart',
  );
}

typedef LibraryGenerator = Future<LibraryReader> Function(String filename);

/// Thunks a reader generator that assumes the filename is prefixed `test_`
/// and suffixed `.dart` and nested in [folder] in the `test` folder.
LibraryGenerator generateLibraryForFolder(String folder) {
  return (String filename) async {
    return _libraryForFolder(folder, filename);
  };
}

/// The first annotation in a file
Future<AnnotatedElement> annotationForFile(String folder, String filename) async {
  final reader = await _libraryForFolder(folder, filename);
  return reader.annotatedWith(offlineFirstChecker)?.first;
}

const offlineFirstChecker = TypeChecker.fromRuntime(ConnectAnnotation);
