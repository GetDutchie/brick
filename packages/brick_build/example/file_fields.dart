import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/generators.dart';
import 'package:brick_core/field_serializable.dart';

// in a real-world equivalent, this is an annotation
class File implements FieldSerializable {
  final String? path;

  @override
  final String name;

  @override
  final String? defaultValue;

  @override
  final bool enumAsString;

  @override
  final bool ignore;

  @override
  final bool ignoreFrom;

  @override
  final bool ignoreTo;

  @override
  final String? fromGenerator;

  @override
  final String? toGenerator;

  @override
  final bool nullable;

  const File({
    this.path,
    required this.name,
    this.defaultValue,
    this.enumAsString = false,
    this.ignore = false,
    this.ignoreFrom = false,
    this.ignoreTo = false,
    this.fromGenerator,
    this.toGenerator,
    this.nullable = false,
  });
}

/// Convert `@File` annotations into digestible code
class _FileSerdesFinder extends AnnotationFinder<File> {
  _FileSerdesFinder();

  @override
  File from(FieldElement element) {
    final obj = objectForField(element);

    if (obj == null) {
      return const File(name: '');
    }

    return File(
      name: '',
      path: obj.getField('path')?.toStringValue(),
    );
  }
}

/// Discover all fields with `@File`
class FileFields extends FieldsForClass<File> {
  @override
  final finder = _FileSerdesFinder();

  FileFields(ClassElement element) : super(element: element);
}
