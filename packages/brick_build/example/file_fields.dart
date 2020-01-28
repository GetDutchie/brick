import 'package:analyzer/dart/element/element.dart';
import 'package:brick_core/field_serializable.dart';
import '../lib/src/annotation_finder.dart';
import '../lib/src/utils/fields_for_class.dart';

// in a real-world equivalent, this is an annotation
class File extends FieldSerializable {
  final String path;

  const File({
    this.path,
  });
}

/// Convert `@File` annotations into digestible code
class _FileSerdesFinder extends AnnotationFinder<File> {
  _FileSerdesFinder();

  @override
  File from(element) {
    final obj = objectForField(element);

    if (obj == null) {
      return const File();
    }

    return File(
      path: obj.getField('path').toStringValue(),
    );
  }
}

/// Discover all fields with `@File`
class FileFields extends FieldsForClass<File> {
  @override
  final finder = _FileSerdesFinder();

  FileFields(ClassElement element) : super(element: element);
}
