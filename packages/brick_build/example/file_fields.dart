import 'package:analyzer/dart/element/element.dart';
import 'package:brick_core/field_serializable.dart';
import 'package:brick_build/generators.dart';

// in a real-world equivalent, this is an annotation
class File implements FieldSerializable {
  final String path;

  @override
  final String name;

  @override
  final String defaultValue;

  @override
  final bool ignore;

  @override
  final String fromGenerator;

  @override
  final String toGenerator;

  @override
  final bool nullable;

  const File({
    this.path,
    this.name,
    this.defaultValue,
    this.ignore,
    this.fromGenerator,
    this.toGenerator,
    this.nullable,
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
