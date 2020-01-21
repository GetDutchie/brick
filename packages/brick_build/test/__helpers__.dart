export 'package:brick_build/testing.dart';

import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/generators.dart';
import 'package:brick_core/field_serializable.dart';

class FieldAnnotation extends FieldSerializable {
  get defaultValue => null;
  String get fromGenerator => null;
  String get toGenerator => null;
  bool get ignore => null;
  String get name => null;
  bool get nullable => null;

  FieldAnnotation();
}

/// Find `@Rest` given a field
class FieldAnnotationFinder extends AnnotationFinder<FieldAnnotation> {
  FieldAnnotationFinder();

  @override
  FieldAnnotation from(element) => FieldAnnotation();
}

/// Converts all fields to [Rest]s for later consumption
class TestFields extends FieldsForClass<FieldAnnotation> {
  @override
  final FieldAnnotationFinder finder;

  TestFields(ClassElement element)
      : finder = FieldAnnotationFinder(),
        super(element: element);
}
